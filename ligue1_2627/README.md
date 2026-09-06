# Ligue 1 2026/27 Monte Carlo Simulation & Brest SB 29 Report

A high-performance Monte Carlo simulation engine written in Rust to forecast the complete **2026/2027 Ligue 1 McDonald's** season.

**Authors:** Stéphane Leon & Gemini (Google DeepMind)

---

## Overview

- **Official 18 Clubs**: Updated for the 2026/2027 campaign including promoted clubs (ESTAC Troyes, Le Mans FC, Paris FC, FC Lorient) and excluding relegated teams (FC Nantes, FC Metz, AS Saint-Étienne, Montpellier HSC).
- **Exact 306-Match Calendar**: Full official schedule across Matchdays 1 to 34 (each club plays 17 home and 17 away matches).
- **Multi-Factor Strength Model**:
  - **2025/2026 Performance** ($w_p = 0.35$): Points per game (PPG), win rate, and goal differential per game.
  - **2026 UEFA Club Coefficients** ($w_u = 0.25$): Official 5-year UEFA coefficient.
  - **Transfermarkt Squad Market Value** ($w_m = 0.40$): Log-transformed valuation ($\ln(\text{MV})$).
- **Poisson Match Engine**: Expected goals ($\lambda_{\text{home}}, \lambda_{\text{away}}$) with calibrated home advantage ($\text{HA} = +0.22$) and disparity sensitivity ($\beta = 1.20$).
- **Official LFP Tiebreakers**: Points $\to$ Goal Difference $\to$ Goals Scored $\to$ Away Goals $\to$ Wins $\to$ Away Wins $\to$ UEFA coefficient.
- **Publication-Grade PDF Report**: Automated 4-page Typst report containing the full classification table and the exact 34-game schedule for **Stade Brestois 29 (Brest SB 29)** with **simulated median scores** and outcome probabilities.
- **High Performance**: Parallelized with Rayon — simulates 100,000 seasons (30,600,000 matches) in **~2.4 seconds** (~12.75M matches/sec).

---

## Project Structure

```
ligue1_2627/
├── Cargo.toml
├── Cargo.lock
├── data/
│   ├── teams.json                    # 18 clubs with stats, valuations & coefficients
│   └── fixtures.json                 # 306 official fixtures across 34 matchdays
├── ligue1_fixtures_2026_2027.csv     # Official 306 fixtures in CSV format
├── ligue1_2627_standings.csv         # Standings & probabilities export dataset
├── ligue1_2627_summary.pdf           # 4-page publication PDF report (Typst)
├── ligue1_2627_summary.typ           # Typst source code
├── brest_positions.png               # High-res finishing position distribution chart
├── src/
│   ├── main.rs                       # CLI entry point, reporting & comfy-table
│   ├── model.rs                      # Multi-factor strength model & Poisson engine
│   ├── sim.rs                        # Rayon parallel Monte Carlo fold/reduce engine
│   ├── table.rs                      # Ligue 1 standings & tiebreaker hierarchy
│   └── report.rs                     # Plotters chart & Typst PDF compiler
└── README.md
```

---

## Build & Run

```bash
# Build optimized release binary
cargo build --release

# Run 100,000 simulations (default)
./target/release/ligue1_simulation -n 100000

# Run 1,000,000 simulations and export to CSV & PDF
./target/release/ligue1_simulation -n 1000000 --csv ligue1_2627_standings.csv --pdf ligue1_2627_summary.pdf
```

---

## Key Projections (100,000 Simulations)

- **Champion Title**: Paris Saint-Germain dominates with > 85% probability (~82.1 points).
- **UEFA Champions League (Top 3 Direct + 4th Play-off)**: Fierce battle between LOSC Lille, Olympique de Marseille, RC Lens, Olympique Lyonnais, and AS Monaco. Cutoff for Top 4 is ~58–61 points.
- **Stade Brestois 29 Focus**:
  - Projected Points: **35.9 pts** (Median: **36 pts**).
  - Direct Survival (Top 15): **81.5%**.
  - Relegation Play-off (16th): **8.0%**.
  - Direct Relegation (17th–18th): **10.4%**.
  - Strong home fortress at Stade Francis-Le Blé with expected positive goal difference.
