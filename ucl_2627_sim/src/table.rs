use std::cmp::Ordering;

#[derive(Clone, Debug, Default)]
pub struct StandingsEntry {
    pub team_idx: usize,
    pub points: i32,
    pub goal_diff: i32,
    pub goals_for: i32,
    pub goals_against: i32,
    pub away_goals_for: i32,
    pub wins: i32,
    pub draws: i32,
    pub losses: i32,
    pub away_wins: i32,
    pub uefa_coeff: f64,
}

impl StandingsEntry {
    pub fn new(team_idx: usize, uefa_coeff: f64) -> Self {
        Self {
            team_idx,
            uefa_coeff,
            ..Default::default()
        }
    }

    #[inline]
    pub fn record_match(&mut self, is_home: bool, scored: u32, conceded: u32) {
        let scored_i = scored as i32;
        let conceded_i = conceded as i32;

        self.goals_for += scored_i;
        self.goals_against += conceded_i;
        self.goal_diff += scored_i - conceded_i;

        if !is_home {
            self.away_goals_for += scored_i;
        }

        match scored.cmp(&conceded) {
            Ordering::Greater => {
                self.points += 3;
                self.wins += 1;
                if !is_home {
                    self.away_wins += 1;
                }
            }
            Ordering::Equal => {
                self.points += 1;
                self.draws += 1;
            }
            Ordering::Less => {
                self.losses += 1;
            }
        }
    }
}

/// Compare two entries according to official UEFA Champions League tiebreakers:
/// 1. Superior points
/// 2. Superior goal difference
/// 3. Higher number of goals scored (GF)
/// 4. Higher number of away goals scored
/// 5. Higher number of wins
/// 6. Higher number of away wins
/// 7. Higher UEFA club coefficient
pub fn compare_standings(a: &StandingsEntry, b: &StandingsEntry) -> Ordering {
    b.points.cmp(&a.points)
        .then_with(|| b.goal_diff.cmp(&a.goal_diff))
        .then_with(|| b.goals_for.cmp(&a.goals_for))
        .then_with(|| b.away_goals_for.cmp(&a.away_goals_for))
        .then_with(|| b.wins.cmp(&a.wins))
        .then_with(|| b.away_wins.cmp(&a.away_wins))
        .then_with(|| b.uefa_coeff.partial_cmp(&a.uefa_coeff).unwrap_or(Ordering::Equal))
        .then_with(|| a.team_idx.cmp(&b.team_idx))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_tiebreaker_priority() {
        let mut t1 = StandingsEntry::new(0, 100.0);
        let mut t2 = StandingsEntry::new(1, 90.0);

        t1.record_match(true, 2, 0); // Pts: 3, GD: +2, GF: 2
        t2.record_match(true, 1, 0); // Pts: 3, GD: +1, GF: 1

        assert_eq!(compare_standings(&t1, &t2), Ordering::Less); // t1 before t2

        // Equal GD, different GF
        let mut t3 = StandingsEntry::new(2, 80.0);
        let mut t4 = StandingsEntry::new(3, 80.0);
        t3.record_match(true, 3, 2); // Pts: 3, GD: +1, GF: 3
        t4.record_match(true, 2, 1); // Pts: 3, GD: +1, GF: 2
        assert_eq!(compare_standings(&t3, &t4), Ordering::Less); // t3 before t4
    }
}
