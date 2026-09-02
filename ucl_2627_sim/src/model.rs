use rand::Rng;
use rand_distr::{Distribution, Poisson};
use serde::{Deserialize, Serialize};

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct YtdStats {
    pub ppg: f64,
    pub win_rate: f64,
    pub gd_pg: f64,
    pub played: u32,
    pub won: u32,
    pub drawn: u32,
    pub lost: u32,
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct Team {
    pub id: usize,
    pub name: String,
    pub country: String,
    pub pot: u8,
    pub uefa_coeff: f64,
    pub market_value_eur: f64,
    pub ytd: YtdStats,
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct Fixture {
    pub matchday: u8,
    pub date: String,
    pub home_team: String,
    pub away_team: String,
    pub venue: String,
}

#[derive(Clone, Copy, Debug)]
#[allow(dead_code)]
pub struct IndexedFixture {
    pub matchday: u8,
    pub home_idx: usize,
    pub away_idx: usize,
}

#[derive(Clone, Debug)]
pub struct ModelWeights {
    pub w_uefa: f64,
    pub w_market: f64,
    pub w_ytd: f64,
    pub home_advantage: f64,
    pub base_goals: f64,
    pub beta: f64,
}

impl Default for ModelWeights {
    fn default() -> Self {
        Self {
            w_uefa: 0.25,
            w_market: 0.50,
            w_ytd: 0.25,
            home_advantage: 0.25,
            base_goals: 1.35,
            beta: 1.25,
        }
    }
}

/// Compute normalized composite rating [0.0, 1.0] for each team
pub fn compute_team_ratings(teams: &[Team], weights: &ModelWeights) -> Vec<f64> {
    let n = teams.len();
    if n == 0 {
        return Vec::new();
    }

    // 1. Min/max for UEFA coeff
    let min_coeff = teams.iter().map(|t| t.uefa_coeff).fold(f64::INFINITY, f64::min);
    let max_coeff = teams.iter().map(|t| t.uefa_coeff).fold(f64::NEG_INFINITY, f64::max);
    let coeff_range = (max_coeff - min_coeff).max(1e-6);

    // 2. Min/max for log(market_value)
    let min_ln_mv = teams.iter().map(|t| t.market_value_eur.ln()).fold(f64::INFINITY, f64::min);
    let max_ln_mv = teams.iter().map(|t| t.market_value_eur.ln()).fold(f64::NEG_INFINITY, f64::max);
    let ln_mv_range = (max_ln_mv - min_ln_mv).max(1e-6);

    // 3. YTD raw composite score = (PPG / 3.0) * 0.5 + win_rate * 0.3 + ((gd_pg + 1.0) / 4.0) * 0.2
    let ytd_scores: Vec<f64> = teams
        .iter()
        .map(|t| {
            let ppg_score = (t.ytd.ppg / 3.0).clamp(0.0, 1.0);
            let wr_score = t.ytd.win_rate.clamp(0.0, 1.0);
            let gd_score = ((t.ytd.gd_pg + 1.5) / 4.0).clamp(0.0, 1.0);
            0.50 * ppg_score + 0.30 * wr_score + 0.20 * gd_score
        })
        .collect();

    let min_ytd = ytd_scores.iter().cloned().fold(f64::INFINITY, f64::min);
    let max_ytd = ytd_scores.iter().cloned().fold(f64::NEG_INFINITY, f64::max);
    let ytd_range = (max_ytd - min_ytd).max(1e-6);

    // Normalize weights
    let total_w = (weights.w_uefa + weights.w_market + weights.w_ytd).max(1e-6);
    let norm_w_uefa = weights.w_uefa / total_w;
    let norm_w_market = weights.w_market / total_w;
    let norm_w_ytd = weights.w_ytd / total_w;

    teams
        .iter()
        .enumerate()
        .map(|(i, t)| {
            let s_uefa = (t.uefa_coeff - min_coeff) / coeff_range;
            let s_mv = (t.market_value_eur.ln() - min_ln_mv) / ln_mv_range;
            let s_ytd = (ytd_scores[i] - min_ytd) / ytd_range;

            norm_w_uefa * s_uefa + norm_w_market * s_mv + norm_w_ytd * s_ytd
        })
        .collect()
}

/// Simulate a match between home and away team
#[inline]
pub fn simulate_match<R: Rng>(
    home_idx: usize,
    away_idx: usize,
    ratings: &[f64],
    weights: &ModelWeights,
    rng: &mut R,
) -> (u32, u32) {
    let r_home = ratings[home_idx];
    let r_away = ratings[away_idx];
    let diff = r_home - r_away;

    // Expected goals
    let lambda_home = (weights.base_goals * (weights.home_advantage + weights.beta * diff).exp()).clamp(0.1, 8.0);
    let lambda_away = (weights.base_goals * (-weights.beta * diff).exp()).clamp(0.1, 8.0);

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
                name: "Team A".into(),
                country: "ENG".into(),
                pot: 1,
                uefa_coeff: 140.0,
                market_value_eur: 1200.0,
                ytd: YtdStats { ppg: 2.5, win_rate: 0.8, gd_pg: 1.8, played: 4, won: 3, drawn: 1, lost: 0 },
            },
            Team {
                id: 1,
                name: "Team B".into(),
                country: "SVK".into(),
                pot: 4,
                uefa_coeff: 20.0,
                market_value_eur: 30.0,
                ytd: YtdStats { ppg: 1.5, win_rate: 0.4, gd_pg: 0.2, played: 4, won: 1, drawn: 2, lost: 1 },
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
