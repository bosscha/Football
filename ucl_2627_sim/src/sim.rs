use crate::model::{compute_team_ratings, simulate_match, IndexedFixture, ModelWeights, Team};
use crate::table::{compare_standings, StandingsEntry};
use rayon::prelude::*;
use std::time::Instant;

#[derive(Clone, Debug)]
#[allow(dead_code)]
pub struct TeamSimStats {
    pub team_idx: usize,
    pub name: String,
    pub country: String,
    pub pot: u8,
    pub market_value_eur: f64,
    pub uefa_coeff: f64,
    pub position_counts: [usize; 36],
    pub total_points: i64,
    pub total_points_sq: f64,
    pub total_goal_diff: i64,
    pub total_goals_for: i64,
    pub total_goals_against: i64,
    pub top8_count: usize,
    pub playoff_count: usize,
    pub eliminated_count: usize,
    pub first_place_count: usize,
}

impl TeamSimStats {
    pub fn new(team: &Team) -> Self {
        Self {
            team_idx: team.id,
            name: team.name.clone(),
            country: team.country.clone(),
            pot: team.pot,
            market_value_eur: team.market_value_eur,
            uefa_coeff: team.uefa_coeff,
            position_counts: [0; 36],
            total_points: 0,
            total_points_sq: 0.0,
            total_goal_diff: 0,
            total_goals_for: 0,
            total_goals_against: 0,
            top8_count: 0,
            playoff_count: 0,
            eliminated_count: 0,
            first_place_count: 0,
        }
    }

    pub fn mean_points(&self, total_sims: usize) -> f64 {
        self.total_points as f64 / total_sims as f64
    }

    pub fn std_points(&self, total_sims: usize) -> f64 {
        let n = total_sims as f64;
        let mean = self.mean_points(total_sims);
        let var = (self.total_points_sq / n) - (mean * mean);
        var.max(0.0).sqrt()
    }

    pub fn mean_goal_diff(&self, total_sims: usize) -> f64 {
        self.total_goal_diff as f64 / total_sims as f64
    }

    pub fn mean_goals_for(&self, total_sims: usize) -> f64 {
        self.total_goals_for as f64 / total_sims as f64
    }

    pub fn mean_goals_against(&self, total_sims: usize) -> f64 {
        self.total_goals_against as f64 / total_sims as f64
    }

    pub fn mean_position(&self, total_sims: usize) -> f64 {
        let sum_pos: usize = self.position_counts
            .iter()
            .enumerate()
            .map(|(pos, &count)| (pos + 1) * count)
            .sum();
        sum_pos as f64 / total_sims as f64
    }

    pub fn top8_pct(&self, total_sims: usize) -> f64 {
        (self.top8_count as f64 / total_sims as f64) * 100.0
    }

    pub fn playoff_pct(&self, total_sims: usize) -> f64 {
        (self.playoff_count as f64 / total_sims as f64) * 100.0
    }

    pub fn eliminated_pct(&self, total_sims: usize) -> f64 {
        (self.eliminated_count as f64 / total_sims as f64) * 100.0
    }

    pub fn title_pct(&self, total_sims: usize) -> f64 {
        (self.first_place_count as f64 / total_sims as f64) * 100.0
    }
}

pub struct SimulationSummary {
    pub simulations: usize,
    pub duration_secs: f64,
    pub team_stats: Vec<TeamSimStats>,
    pub cutoff_top8_mean: f64,
    pub cutoff_top8_p50: i32,
    pub cutoff_top8_p90: i32,
    pub cutoff_top24_mean: f64,
    pub cutoff_top24_p50: i32,
    pub cutoff_top24_p90: i32,
}

/// Simulate a single season and return the sorted final standings table
pub fn simulate_single_season(
    teams: &[Team],
    fixtures: &[IndexedFixture],
    ratings: &[f64],
    weights: &ModelWeights,
) -> Vec<StandingsEntry> {
    let mut rng = rand::thread_rng();
    let mut standings: Vec<StandingsEntry> = teams
        .iter()
        .map(|t| StandingsEntry::new(t.id, t.uefa_coeff))
        .collect();

    for f in fixtures {
        let (h_goals, a_goals) = simulate_match(f.home_idx, f.away_idx, ratings, weights, &mut rng);
        standings[f.home_idx].record_match(true, h_goals, a_goals);
        standings[f.away_idx].record_match(false, a_goals, h_goals);
    }

    standings.sort_by(compare_standings);
    standings
}

/// Run Monte Carlo parallel simulation
pub fn run_monte_carlo(
    teams: &[Team],
    fixtures: &[IndexedFixture],
    weights: &ModelWeights,
    simulations: usize,
) -> SimulationSummary {
    let n = teams.len();
    assert_eq!(n, 36, "Must have exactly 36 teams");

    let ratings = compute_team_ratings(teams, weights);
    let start_time = Instant::now();

    // Accumulate stats in parallel: (local_stats, top8_cutoffs, top24_cutoffs)
    let (mut aggregated_stats, mut top8_cuts, mut top24_cuts) = (0..simulations)
        .into_par_iter()
        .fold(
            || (
                teams.iter().map(|t| TeamSimStats::new(t)).collect::<Vec<_>>(),
                Vec::with_capacity(simulations / rayon::current_num_threads().max(1)),
                Vec::with_capacity(simulations / rayon::current_num_threads().max(1)),
            ),
            |(mut local_stats, mut top8_cuts, mut top24_cuts), _| {
                let mut rng = rand::thread_rng();
                let mut standings: Vec<StandingsEntry> = teams
                    .iter()
                    .map(|t| StandingsEntry::new(t.id, t.uefa_coeff))
                    .collect();

                for f in fixtures {
                    let (h_goals, a_goals) = simulate_match(f.home_idx, f.away_idx, &ratings, weights, &mut rng);
                    standings[f.home_idx].record_match(true, h_goals, a_goals);
                    standings[f.away_idx].record_match(false, a_goals, h_goals);
                }

                standings.sort_by(compare_standings);

                // Cutoffs (0-indexed: index 7 is 8th place, index 23 is 24th place)
                top8_cuts.push(standings[7].points);
                top24_cuts.push(standings[23].points);

                for (pos, entry) in standings.iter().enumerate() {
                    let t_idx = entry.team_idx;
                    let stat = &mut local_stats[t_idx];
                    stat.position_counts[pos] += 1;
                    stat.total_points += entry.points as i64;
                    stat.total_points_sq += (entry.points as f64) * (entry.points as f64);
                    stat.total_goal_diff += entry.goal_diff as i64;
                    stat.total_goals_for += entry.goals_for as i64;
                    stat.total_goals_against += entry.goals_against as i64;

                    match pos {
                        0 => {
                            stat.first_place_count += 1;
                            stat.top8_count += 1;
                        }
                        1..=7 => stat.top8_count += 1,
                        8..=23 => stat.playoff_count += 1,
                        _ => stat.eliminated_count += 1,
                    }
                }

                (local_stats, top8_cuts, top24_cuts)
            },
        )
        .reduce(
            || (
                teams.iter().map(|t| TeamSimStats::new(t)).collect::<Vec<_>>(),
                Vec::new(),
                Vec::new(),
            ),
            |(mut acc_stats, mut acc_top8, mut acc_top24), (local_stats, local_top8, local_top24)| {
                for i in 0..acc_stats.len() {
                    acc_stats[i].total_points += local_stats[i].total_points;
                    acc_stats[i].total_points_sq += local_stats[i].total_points_sq;
                    acc_stats[i].total_goal_diff += local_stats[i].total_goal_diff;
                    acc_stats[i].total_goals_for += local_stats[i].total_goals_for;
                    acc_stats[i].total_goals_against += local_stats[i].total_goals_against;
                    acc_stats[i].top8_count += local_stats[i].top8_count;
                    acc_stats[i].playoff_count += local_stats[i].playoff_count;
                    acc_stats[i].eliminated_count += local_stats[i].eliminated_count;
                    acc_stats[i].first_place_count += local_stats[i].first_place_count;
                    for p in 0..36 {
                        acc_stats[i].position_counts[p] += local_stats[i].position_counts[p];
                    }
                }
                acc_top8.extend(local_top8);
                acc_top24.extend(local_top24);
                (acc_stats, acc_top8, acc_top24)
            },
        );

    let duration_secs = start_time.elapsed().as_secs_f64();

    // Sort teams by mean position (1.0 = best)
    aggregated_stats.sort_by(|a, b| {
        a.mean_position(simulations)
            .partial_cmp(&b.mean_position(simulations))
            .unwrap()
    });

    // Compute cutoffs statistics
    top8_cuts.sort_unstable();
    top24_cuts.sort_unstable();

    let c8_mean = top8_cuts.iter().copied().map(|x| x as f64).sum::<f64>() / top8_cuts.len().max(1) as f64;
    let c24_mean = top24_cuts.iter().copied().map(|x| x as f64).sum::<f64>() / top24_cuts.len().max(1) as f64;

    let p50_idx = simulations / 2;
    let p90_idx = (simulations as f64 * 0.90) as usize;

    SimulationSummary {
        simulations,
        duration_secs,
        team_stats: aggregated_stats,
        cutoff_top8_mean: c8_mean,
        cutoff_top8_p50: top8_cuts.get(p50_idx).copied().unwrap_or(15),
        cutoff_top8_p90: top8_cuts.get(p90_idx).copied().unwrap_or(16),
        cutoff_top24_mean: c24_mean,
        cutoff_top24_p50: top24_cuts.get(p50_idx).copied().unwrap_or(9),
        cutoff_top24_p90: top24_cuts.get(p90_idx).copied().unwrap_or(10),
    }
}
