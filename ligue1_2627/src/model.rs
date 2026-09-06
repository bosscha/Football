use rand::Rng;
use rand_distr::{Distribution, Poisson};
use serde::{Deserialize, Serialize};

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct PrevSeasonStats {
    pub league: String,
    pub played: u32,
    pub won: u32,
    pub drawn: u32,
    pub lost: u32,
    pub gf: i32,
    pub ga: i32,
    pub gd: i32,
    pub points: i32,
    pub ppg: f64,
    pub win_rate: f64,
    pub gd_pg: f64,
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct Team {
    pub id: usize,
    pub name: String,
    pub short_name: String,
    pub stadium: String,
    pub uefa_coeff: f64,
    pub market_value_eur: f64,
    pub prev_season: PrevSeasonStats,
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct Fixture {
    pub match_id: String,
    pub matchday: u8,
    pub date: String,
    pub home_team: String,
    pub away_team: String,
    pub venue: String,
}

#[derive(Clone, Copy, Debug)]
pub struct IndexedFixture {
    pub fixture_idx: usize,
    pub matchday: u8,
    pub home_idx: usize,
    pub away_idx: usize,
}

#[derive(Clone, Debug)]
pub struct ModelWeights {
    pub w_prev: f64,
    pub w_uefa: f64,
    pub w_market: f64,
    pub home_advantage: f64,
    pub base_goals: f64,
    pub beta: f64,
}

impl Default for ModelWeights {
    fn default() -> Self {
        Self {
            w_prev: 0.35,
            w_uefa: 0.25,
            w_market: 0.40,
            home_advantage: 0.22,
            base_goals: 1.35,
            beta: 1.20,
        }
    }
}

/// Compute normalized composite strength rating [0.0, 1.0] for each team
pub fn compute_team_ratings(teams: &[Team], weights: &ModelWeights) -> Vec<f64> {
    let n = teams.len();
    if n == 0 {
        return Vec::new();
    }

    // 1. Min/max for previous season performance composite score
    let prev_scores: Vec<f64> = teams
        .iter()
        .map(|t| {
            let ppg_score = (t.prev_season.ppg / 3.0).clamp(0.0, 1.0);
            let wr_score = t.prev_season.win_rate.clamp(0.0, 1.0);
            let gd_score = ((t.prev_season.gd_pg + 1.5) / 4.0).clamp(0.0, 1.0);
            0.50 * ppg_score + 0.30 * wr_score + 0.20 * gd_score
        })
        .collect();

    let min_prev = prev_scores.iter().cloned().fold(f64::INFINITY, f64::min);
    let max_prev = prev_scores.iter().cloned().fold(f64::NEG_INFINITY, f64::max);
    let prev_range = (max_prev - min_prev).max(1e-6);

    // 2. Min/max for UEFA coefficient
    let min_uefa = teams.iter().map(|t| t.uefa_coeff).fold(f64::INFINITY, f64::min);
    let max_uefa = teams.iter().map(|t| t.uefa_coeff).fold(f64::NEG_INFINITY, f64::max);
    let uefa_range = (max_uefa - min_uefa).max(1e-6);

    // 3. Min/max for log(market_value)
    let min_ln_mv = teams.iter().map(|t| t.market_value_eur.ln()).fold(f64::INFINITY, f64::min);
    let max_ln_mv = teams.iter().map(|t| t.market_value_eur.ln()).fold(f64::NEG_INFINITY, f64::max);
    let ln_mv_range = (max_ln_mv - min_ln_mv).max(1e-6);

    // Normalized weights
    let total_w = (weights.w_prev + weights.w_uefa + weights.w_market).max(1e-6);
    let norm_w_prev = weights.w_prev / total_w;
    let norm_w_uefa = weights.w_uefa / total_w;
    let norm_w_market = weights.w_market / total_w;

    teams
        .iter()
        .enumerate()
        .map(|(i, t)| {
            let s_prev = (prev_scores[i] - min_prev) / prev_range;
            let s_uefa = (t.uefa_coeff - min_uefa) / uefa_range;
            let s_mv = (t.market_value_eur.ln() - min_ln_mv) / ln_mv_range;

            norm_w_prev * s_prev + norm_w_uefa * s_uefa + norm_w_market * s_mv
        })
        .collect()
}

/// Compute expected goals (lambda_home, lambda_away)
#[inline]
pub fn expected_goals(
    home_idx: usize,
    away_idx: usize,
    ratings: &[f64],
    weights: &ModelWeights,
) -> (f64, f64) {
    let r_home = ratings[home_idx];
    let r_away = ratings[away_idx];
    let diff = r_home - r_away;

    let lambda_home = (weights.base_goals * (weights.home_advantage + weights.beta * diff).exp()).clamp(0.1, 7.0);
    let lambda_away = (weights.base_goals * (-weights.beta * diff).exp()).clamp(0.1, 7.0);

    (lambda_home, lambda_away)
}

/// Simulate a match between home and away team using Poisson distribution
#[inline]
pub fn simulate_match<R: Rng>(
    home_idx: usize,
    away_idx: usize,
    ratings: &[f64],
    weights: &ModelWeights,
    rng: &mut R,
) -> (u32, u32) {
    let (lambda_home, lambda_away) = expected_goals(home_idx, away_idx, ratings, weights);

    let home_dist = Poisson::new(lambda_home).unwrap();
    let away_dist = Poisson::new(lambda_away).unwrap();

    (home_dist.sample(rng) as u32, away_dist.sample(rng) as u32)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_ratings_in_bounds() {
        let teams = vec![
            Team {
                id: 0,
                name: "PSG".into(),
                short_name: "PSG".into(),
                stadium: "Parc".into(),
                uefa_coeff: 132.0,
                market_value_eur: 1360.0,
                prev_season: PrevSeasonStats {
                    league: "L1".into(),
                    played: 34, won: 24, drawn: 4, lost: 6,
                    gf: 74, ga: 29, gd: 45, points: 76,
                    ppg: 2.24, win_rate: 0.706, gd_pg: 1.32
                },
            },
            Team {
                id: 1,
                name: "Auxerre".into(),
                short_name: "AJA".into(),
                stadium: "Abbe".into(),
                uefa_coeff: 14.1,
                market_value_eur: 50.0,
                prev_season: PrevSeasonStats {
                    league: "L1".into(),
                    played: 34, won: 8, drawn: 10, lost: 16,
                    gf: 34, ga: 44, gd: -10, points: 34,
                    ppg: 1.00, win_rate: 0.235, gd_pg: -0.29
                },
            },
        ];
        let weights = ModelWeights::default();
        let ratings = compute_team_ratings(&teams, &weights);
        assert_eq!(ratings.len(), 2);
        assert!(ratings[0] > ratings[1]);
        assert!(ratings[0] <= 1.0 && ratings[0] >= 0.0);
        assert!(ratings[1] <= 1.0 && ratings[1] >= 0.0);
    }
}
