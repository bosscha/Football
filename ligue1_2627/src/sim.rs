use crate::model::{simulate_match, IndexedFixture, ModelWeights, Team};
use crate::table::{compare_standings, StandingsEntry};
use rayon::prelude::*;

const MAX_GOALS_TRACK: usize = 16;
const MAX_SCORE_MATRIX: usize = 8;

#[derive(Clone, Debug, Default)]
pub struct FixtureSimStats {
    pub home_wins: usize,
    pub draws: usize,
    pub away_wins: usize,
    pub home_goals_dist: [usize; MAX_GOALS_TRACK],
    pub away_goals_dist: [usize; MAX_GOALS_TRACK],
    pub score_matrix: [[usize; MAX_SCORE_MATRIX]; MAX_SCORE_MATRIX],
    pub total_home_goals: usize,
    pub total_away_goals: usize,
}

impl FixtureSimStats {
    #[inline]
    pub fn record(&mut self, gh: u32, ga: u32) {
        self.total_home_goals += gh as usize;
        self.total_away_goals += ga as usize;

        let h_idx = (gh as usize).min(MAX_GOALS_TRACK - 1);
        let a_idx = (ga as usize).min(MAX_GOALS_TRACK - 1);
        self.home_goals_dist[h_idx] += 1;
        self.away_goals_dist[a_idx] += 1;

        let h_mat = (gh as usize).min(MAX_SCORE_MATRIX - 1);
        let a_mat = (ga as usize).min(MAX_SCORE_MATRIX - 1);
        self.score_matrix[h_mat][a_mat] += 1;

        if gh > ga {
            self.home_wins += 1;
        } else if gh == ga {
            self.draws += 1;
        } else {
            self.away_wins += 1;
        }
    }

    pub fn merge(&mut self, other: &FixtureSimStats) {
        self.home_wins += other.home_wins;
        self.draws += other.draws;
        self.away_wins += other.away_wins;
        self.total_home_goals += other.total_home_goals;
        self.total_away_goals += other.total_away_goals;

        for i in 0..MAX_GOALS_TRACK {
            self.home_goals_dist[i] += other.home_goals_dist[i];
            self.away_goals_dist[i] += other.away_goals_dist[i];
        }

        for i in 0..MAX_SCORE_MATRIX {
            for j in 0..MAX_SCORE_MATRIX {
                self.score_matrix[i][j] += other.score_matrix[i][j];
            }
        }
    }

    /// Compute empirical median goals (marginal)
    pub fn median_goals(&self, total_sims: usize) -> (u32, u32) {
        let med_h = compute_median_from_dist(&self.home_goals_dist, total_sims);
        let med_a = compute_median_from_dist(&self.away_goals_dist, total_sims);
        (med_h, med_a)
    }

    /// Compute the median score of the match from the perspective of Brest (or specified team).
    /// Determines the empirical median goal difference Δ = G_Brest - G_Opp, and selects the modal
    /// scoreline (G_Brest, G_Opp) matching this exact median goal difference.
    /// Returns (brest_goals, opp_goals, median_goal_diff).
    pub fn median_match_score(&self, total_sims: usize, is_home: bool) -> (u32, u32, i32) {
        let mut margin_counts = [0usize; 15]; // index 7 is diff 0 (-7 to +7)
        for h in 0..MAX_SCORE_MATRIX {
            for a in 0..MAX_SCORE_MATRIX {
                let diff = if is_home { h as i32 - a as i32 } else { a as i32 - h as i32 };
                let idx = (diff + 7).clamp(0, 14) as usize;
                margin_counts[idx] += self.score_matrix[h][a];
            }
        }

        let mut cum = 0;
        let mut med_diff = 0i32;
        let mid = total_sims / 2;
        for (i, &c) in margin_counts.iter().enumerate() {
            cum += c;
            if cum >= mid {
                med_diff = i as i32 - 7;
                break;
            }
        }

        let mut best_count = 0;
        let mut best_score = if med_diff >= 0 {
            (med_diff as u32, 0)
        } else {
            (0, (-med_diff) as u32)
        };

        for h in 0..MAX_SCORE_MATRIX {
            for a in 0..MAX_SCORE_MATRIX {
                let diff = if is_home { h as i32 - a as i32 } else { a as i32 - h as i32 };
                if diff == med_diff {
                    let c = self.score_matrix[h][a];
                    if c > best_count {
                        best_count = c;
                        let (gb, go) = if is_home { (h as u32, a as u32) } else { (a as u32, h as u32) };
                        best_score = (gb, go);
                    }
                }
            }
        }

        (best_score.0, best_score.1, med_diff)
    }

    /// Most frequent exact score (mode) and its empirical probability percentage
    pub fn most_frequent_score(&self, total_sims: usize) -> (u32, u32, f64) {
        let mut best_gh = 0;
        let mut best_ga = 0;
        let mut max_c = 0;
        for i in 0..MAX_SCORE_MATRIX {
            for j in 0..MAX_SCORE_MATRIX {
                if self.score_matrix[i][j] > max_c {
                    max_c = self.score_matrix[i][j];
                    best_gh = i as u32;
                    best_ga = j as u32;
                }
            }
        }
        let pct = (max_c as f64 / total_sims as f64) * 100.0;
        (best_gh, best_ga, pct)
    }
}

fn compute_median_from_dist(dist: &[usize; MAX_GOALS_TRACK], total: usize) -> u32 {
    let mid = total / 2;
    let mut cum = 0;
    for (goals, &cnt) in dist.iter().enumerate() {
        cum += cnt;
        if cum >= mid {
            return goals as u32;
        }
    }
    0
}

#[derive(Clone, Debug, Default)]
pub struct TeamSimStats {
    pub title_count: usize,       // 1st
    pub ucl_direct_count: usize,  // Top 3 (1st, 2nd, 3rd)
    pub ucl_playoff_count: usize, // 4th
    pub europa_count: usize,      // 5th
    pub conf_count: usize,        // 6th
    pub playoff_count: usize,     // 16th (barrage)
    pub relegation_count: usize,  // 17th & 18th
    pub position_counts: [usize; 18],
    pub points_dist: Vec<usize>,  // Points from 0 to 110
    pub total_points: f64,
    pub total_points_sq: f64,
    pub total_wins: f64,
    pub total_draws: f64,
    pub total_losses: f64,
    pub total_gf: f64,
    pub total_ga: f64,
    pub total_gd: f64,

    // Home splits
    pub home_points: f64,
    pub home_wins: f64,
    pub home_draws: f64,
    pub home_losses: f64,
    pub home_gf: f64,
    pub home_ga: f64,

    // Away splits
    pub away_points: f64,
    pub away_wins: f64,
    pub away_draws: f64,
    pub away_losses: f64,
    pub away_gf: f64,
    pub away_ga: f64,
}

impl TeamSimStats {
    pub fn new() -> Self {
        Self {
            points_dist: vec![0; 110],
            ..Default::default()
        }
    }

    pub fn merge(&mut self, other: &TeamSimStats) {
        self.title_count += other.title_count;
        self.ucl_direct_count += other.ucl_direct_count;
        self.ucl_playoff_count += other.ucl_playoff_count;
        self.europa_count += other.europa_count;
        self.conf_count += other.conf_count;
        self.playoff_count += other.playoff_count;
        self.relegation_count += other.relegation_count;

        for i in 0..18 {
            self.position_counts[i] += other.position_counts[i];
        }
        for (p, &cnt) in other.points_dist.iter().enumerate() {
            if p < self.points_dist.len() {
                self.points_dist[p] += cnt;
            }
        }

        self.total_points += other.total_points;
        self.total_points_sq += other.total_points_sq;
        self.total_wins += other.total_wins;
        self.total_draws += other.total_draws;
        self.total_losses += other.total_losses;
        self.total_gf += other.total_gf;
        self.total_ga += other.total_ga;
        self.total_gd += other.total_gd;

        self.home_points += other.home_points;
        self.home_wins += other.home_wins;
        self.home_draws += other.home_draws;
        self.home_losses += other.home_losses;
        self.home_gf += other.home_gf;
        self.home_ga += other.home_ga;

        self.away_points += other.away_points;
        self.away_wins += other.away_wins;
        self.away_draws += other.away_draws;
        self.away_losses += other.away_losses;
        self.away_gf += other.away_gf;
        self.away_ga += other.away_ga;
    }

    pub fn median_points(&self, total_sims: usize) -> u32 {
        let mid = total_sims / 2;
        let mut cum = 0;
        for (pts, &cnt) in self.points_dist.iter().enumerate() {
            cum += cnt;
            if cum >= mid {
                return pts as u32;
            }
        }
        0
    }

    pub fn percentile_points(&self, total_sims: usize, pct: f64) -> u32 {
        let target = (total_sims as f64 * pct / 100.0).round() as usize;
        let mut cum = 0;
        for (pts, &cnt) in self.points_dist.iter().enumerate() {
            cum += cnt;
            if cum >= target {
                return pts as u32;
            }
        }
        0
    }
}

pub struct SimulationResult {
    pub team_stats: Vec<TeamSimStats>,
    pub fixture_stats: Vec<FixtureSimStats>,
    pub total_simulations: usize,
}

pub fn run_monte_carlo(
    teams: &[Team],
    fixtures: &[IndexedFixture],
    ratings: &[f64],
    weights: &ModelWeights,
    total_sims: usize,
) -> SimulationResult {
    let num_teams = teams.len();
    let num_fixtures = fixtures.len();

    let (final_team_stats, final_fixture_stats) = (0..total_sims)
        .into_par_iter()
        .fold(
            || {
                let team_stats = (0..num_teams).map(|_| TeamSimStats::new()).collect::<Vec<_>>();
                let fixture_stats = vec![FixtureSimStats::default(); num_fixtures];
                (team_stats, fixture_stats)
            },
            |(mut acc_teams, mut acc_fixtures), _| {
                let mut rng = rand::thread_rng();

                let mut table: Vec<StandingsEntry> = teams
                    .iter()
                    .enumerate()
                    .map(|(i, t)| StandingsEntry::new(i, t.uefa_coeff))
                    .collect();

                // Play all fixtures of the season
                for fix in fixtures {
                    let (gh, ga) = simulate_match(fix.home_idx, fix.away_idx, ratings, weights, &mut rng);
                    table[fix.home_idx].record_match(true, gh, ga);
                    table[fix.away_idx].record_match(false, ga, gh);
                    acc_fixtures[fix.fixture_idx].record(gh, ga);
                }

                // Rank the standings
                table.sort_by(compare_standings);

                for (pos, entry) in table.iter().enumerate() {
                    let tidx = entry.team_idx;
                    acc_teams[tidx].position_counts[pos] += 1;

                    let pts = entry.points.clamp(0, 109) as usize;
                    acc_teams[tidx].points_dist[pts] += 1;

                    let pts_f = entry.points as f64;
                    acc_teams[tidx].total_points += pts_f;
                    acc_teams[tidx].total_points_sq += pts_f * pts_f;
                    acc_teams[tidx].total_wins += entry.wins as f64;
                    acc_teams[tidx].total_draws += entry.draws as f64;
                    acc_teams[tidx].total_losses += entry.losses as f64;
                    acc_teams[tidx].total_gf += entry.goals_for as f64;
                    acc_teams[tidx].total_ga += entry.goals_against as f64;
                    acc_teams[tidx].total_gd += entry.goal_diff as f64;

                    acc_teams[tidx].home_points += entry.home_points as f64;
                    acc_teams[tidx].home_wins += entry.home_wins as f64;
                    acc_teams[tidx].home_draws += entry.home_draws as f64;
                    acc_teams[tidx].home_losses += entry.home_losses as f64;
                    acc_teams[tidx].home_gf += entry.home_goals_for as f64;
                    acc_teams[tidx].home_ga += entry.home_goals_against as f64;

                    acc_teams[tidx].away_points += entry.away_points as f64;
                    acc_teams[tidx].away_wins += entry.away_wins as f64;
                    acc_teams[tidx].away_draws += entry.away_draws as f64;
                    acc_teams[tidx].away_losses += entry.away_losses as f64;
                    acc_teams[tidx].away_gf += entry.away_goals_for as f64;
                    acc_teams[tidx].away_ga += entry.away_goals_against as f64;

                    match pos {
                        0 => {
                            acc_teams[tidx].title_count += 1;
                            acc_teams[tidx].ucl_direct_count += 1;
                        }
                        1..=2 => {
                            acc_teams[tidx].ucl_direct_count += 1;
                        }
                        3 => {
                            acc_teams[tidx].ucl_playoff_count += 1;
                        }
                        4 => {
                            acc_teams[tidx].europa_count += 1;
                        }
                        5 => {
                            acc_teams[tidx].conf_count += 1;
                        }
                        15 => {
                            acc_teams[tidx].playoff_count += 1; // 16th place
                        }
                        16..=17 => {
                            acc_teams[tidx].relegation_count += 1; // 17th and 18th place
                        }
                        _ => {}
                    }
                }

                (acc_teams, acc_fixtures)
            },
        )
        .reduce(
            || {
                let team_stats = (0..num_teams).map(|_| TeamSimStats::new()).collect::<Vec<_>>();
                let fixture_stats = vec![FixtureSimStats::default(); num_fixtures];
                (team_stats, fixture_stats)
            },
            |(mut t1, mut f1), (t2, f2)| {
                for i in 0..num_teams {
                    t1[i].merge(&t2[i]);
                }
                for i in 0..num_fixtures {
                    f1[i].merge(&f2[i]);
                }
                (t1, f1)
            },
        );

    SimulationResult {
        team_stats: final_team_stats,
        fixture_stats: final_fixture_stats,
        total_simulations: total_sims,
    }
}
