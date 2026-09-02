# UEFA Champions League 2026/27 League Phase Simulation

A high-performance Monte Carlo simulation engine written in Rust to forecast the final 36-team single league phase standings of the **2026/27 UEFA Champions League**.

**Authors:** Stéphane Leon & Gemini (Google DeepMind)

---

## Overview

- **36 Teams**: Official participating clubs across Seeding Pots 1 to 4.
- **144 Fixtures**: Full official schedule across Matchdays 1 to 8 (each team plays 4 home and 4 away matches against 2 teams from each pot).
- **Multi-Factor Strength Model**:
  - 2026 UEFA Club Coefficients ($w_u = 0.25$)
  - Transfermarkt squad market valuations ($w_m = 0.50$, log-scaled)
  - 2026 Year-to-Date (YTD) form ($w_y = 0.25$, PPG, win rate, goal differential)
- **Poisson Goal Model**: Expected goals with calibrated home field advantage (+0.25) and rating disparity sensitivity.
- **Official UEFA Tiebreaker Hierarchy**: Points $\to$ Goal Difference $\to$ Goals Scored $\to$ Away Goals $\to$ Wins $\to$ Away Wins $\to$ UEFA Coefficient.
- **High Performance**: Parallelized with Rayon — simulates 1,000,000 seasons (144,000,000 matches) in **~7.88 seconds** (~18.3M matches/sec).

---

## Project Structure

```
ucl_2627_sim/
├── Cargo.toml
├── Cargo.lock
├── src/
│   ├── main.rs        # CLI entry point, reporting, Comfy-Table & Plotters integration
│   ├── model.rs       # Team models, composite ratings & Poisson match simulator
│   ├── sim.rs         # Rayon parallel Monte Carlo fold/reduce simulation engine
│   └── table.rs       # League standings & official UEFA tiebreaker sorting
├── data/
│   ├── teams.json     # 36 clubs with pots, valuations, coefficients & YTD form
│   └── fixtures.json  # 144 official league phase matches with dates and venues
├── ucl_2627_simulation_report.pdf # Comprehensive 5-page publication report (Typst)
├── ucl_2627_standings_1M.csv      # Complete 1,000,000 simulations results dataset
├── french_teams_distribution.png  # Probability curves for French clubs (PSG, Lille, Lens)
├── spanish_teams_distribution.png # Probability curves for Spanish clubs (5 clubs)
├── italian_teams_distribution.png # Probability curves for Italian clubs (4 clubs)
└── README.md
```

---

## Build & Run

```bash
# Build optimized release binary
cargo build --release

# Run 1,000,000 simulations and export results to CSV
./target/release/ucl_2627_sim --simulations 1000000 --csv ucl_2627_standings_1M.csv

# Focus on a specific club with detailed distribution and PNG plot
./target/release/ucl_2627_sim -n 100000 --target-team "Inter Milan" --plot inter_dist.png

# Simulate a single season outcome
./target/release/ucl_2627_sim --single-season

# Display all 144 official fixtures
./target/release/ucl_2627_sim --show-fixtures
```

---

## Qualification Cutoff Findings (1,000,000 Simulations)

- **Top 8 Cutoff (Direct Round of 16 Bye)**:
  - Mean: **15.66 pts** | Median: **16 pts** | 90% Safe: **17 pts** (or 16 pts with $+6$ GD)
- **Top 24 Cutoff (Knockout Phase Play-offs)**:
  - Mean: **9.02 pts** | Median: **9 pts** | 90% Safe: **10 pts** (or 9 pts with neutral GD)
