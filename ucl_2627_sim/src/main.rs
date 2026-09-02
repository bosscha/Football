mod model;
mod sim;
mod table;

use clap::Parser;
use comfy_table::modifiers::UTF8_ROUND_CORNERS;
use comfy_table::presets::UTF8_FULL;
use comfy_table::{Cell, CellAlignment, Color, ContentArrangement, Row, Table};
use model::{compute_team_ratings, Fixture, IndexedFixture, ModelWeights, Team};
use sim::{run_monte_carlo, simulate_single_season};
use std::collections::HashMap;
use std::fs::File;
use std::io::Write;
use std::path::PathBuf;

const DEFAULT_TEAMS_JSON: &str = include_str!("../data/teams.json");
const DEFAULT_FIXTURES_JSON: &str = include_str!("../data/fixtures.json");

#[derive(Parser, Debug)]
#[command(
    name = "ucl_2627_sim",
    author = "Stephane / Antigravity",
    version = "1.0.0",
    about = "Simulate the 36-team UEFA Champions League 2026/27 League Phase classification based on real fixtures, UEFA rankings, Transfermarkt values, and YTD form."
)]
struct Cli {
    /// Number of Monte Carlo simulations to run
    #[arg(short = 'n', long = "simulations", default_value_t = 100_000)]
    simulations: usize,

    /// Weight for UEFA Club Coefficient
    #[arg(long = "w-uefa", default_value_t = 0.25)]
    w_uefa: f64,

    /// Weight for Transfermarkt total squad value
    #[arg(long = "w-market", default_value_t = 0.50)]
    w_market: f64,

    /// Weight for YTD season results & form
    #[arg(long = "w-ytd", default_value_t = 0.25)]
    w_ytd: f64,

    /// Home advantage factor
    #[arg(long = "home-adv", default_value_t = 0.25)]
    home_adv: f64,

    /// Rating sensitivity factor (beta)
    #[arg(long = "beta", default_value_t = 1.25)]
    beta: f64,

    /// Optional target team name to highlight with detailed position distribution (e.g. 'Lens', 'Como', 'Arsenal')
    #[arg(long = "target-team")]
    target_team: Option<String>,

    /// Path to export classification results as CSV
    #[arg(long = "csv")]
    csv_path: Option<PathBuf>,

    /// Path to export target team distribution chart as PNG image
    #[arg(long = "plot")]
    plot_path: Option<String>,

    /// Simulate and display a single realistic season outcome
    #[arg(long = "single-season")]
    single_season: bool,

    /// Print the full official 144 fixture list
    #[arg(long = "show-fixtures")]
    show_fixtures: bool,

    /// Path to custom teams JSON file
    #[arg(long = "teams-path")]
    teams_path: Option<PathBuf>,

    /// Path to custom fixtures JSON file
    #[arg(long = "fixtures-path")]
    fixtures_path: Option<PathBuf>,
}

fn load_teams(path: Option<&PathBuf>) -> Result<Vec<Team>, Box<dyn std::error::Error>> {
    let content = match path {
        Some(p) => std::fs::read_to_string(p)?,
        None => DEFAULT_TEAMS_JSON.to_string(),
    };
    let teams: Vec<Team> = serde_json::from_str(&content)?;
    Ok(teams)
}

fn load_fixtures(path: Option<&PathBuf>) -> Result<Vec<Fixture>, Box<dyn std::error::Error>> {
    let content = match path {
        Some(p) => std::fs::read_to_string(p)?,
        None => DEFAULT_FIXTURES_JSON.to_string(),
    };
    let fixtures: Vec<Fixture> = serde_json::from_str(&content)?;
    Ok(fixtures)
}

fn build_indexed_fixtures(
    fixtures: &[Fixture],
    team_name_to_idx: &HashMap<String, usize>,
) -> Result<Vec<IndexedFixture>, Box<dyn std::error::Error>> {
    let mut indexed = Vec::with_capacity(fixtures.len());
    for f in fixtures {
        let home_idx = *team_name_to_idx.get(&f.home_team).ok_or_else(|| {
            format!("Home team '{}' not found in teams list", f.home_team)
        })?;
        let away_idx = *team_name_to_idx.get(&f.away_team).ok_or_else(|| {
            format!("Away team '{}' not found in teams list", f.away_team)
        })?;
        indexed.push(IndexedFixture {
            matchday: f.matchday,
            home_idx,
            away_idx,
        });
    }
    Ok(indexed)
}

fn print_fixtures(fixtures: &[Fixture]) {
    println!("\n=== UEFA CHAMPIONS LEAGUE 2026/27 OFFICIAL LEAGUE PHASE FIXTURES (144 Matches) ===\n");
    for md in 1..=8 {
        let md_matches: Vec<_> = fixtures.iter().filter(|f| f.matchday == md).collect();
        println!("┌────────────────────────────────────────────────────────────────────────┐");
        println!("│ Matchday {:<2} ({:<2} matches)                                                 │", md, md_matches.len());
        println!("├────────────┬────────────────────────┬────────────────────────┬─────────┤");
        for m in md_matches {
            println!(
                "│ {:<10} │ {:<22} │ vs. {:<18} │ {:<7} │",
                m.date, m.home_team, m.away_team, m.venue
            );
        }
        println!("└────────────┴────────────────────────┴────────────────────────┴─────────┘\n");
    }
}

fn print_single_season(
    teams: &[Team],
    fixtures: &[IndexedFixture],
    ratings: &[f64],
    weights: &ModelWeights,
) {
    let standings = simulate_single_season(teams, fixtures, ratings, weights);

    let mut table = Table::new();
    table
        .load_preset(UTF8_FULL)
        .apply_modifier(UTF8_ROUND_CORNERS)
        .set_width(140)
        .set_content_arrangement(ContentArrangement::Dynamic)
        .set_header(vec![
            Cell::new("Pos").set_alignment(CellAlignment::Center),
            Cell::new("Team").set_alignment(CellAlignment::Left),
            Cell::new("Country").set_alignment(CellAlignment::Center),
            Cell::new("Pot").set_alignment(CellAlignment::Center),
            Cell::new("P").set_alignment(CellAlignment::Center),
            Cell::new("W").set_alignment(CellAlignment::Center),
            Cell::new("D").set_alignment(CellAlignment::Center),
            Cell::new("L").set_alignment(CellAlignment::Center),
            Cell::new("GF:GA").set_alignment(CellAlignment::Center),
            Cell::new("GD").set_alignment(CellAlignment::Center),
            Cell::new("Pts").set_alignment(CellAlignment::Center),
            Cell::new("Status").set_alignment(CellAlignment::Left),
        ]);

    for (pos, entry) in standings.iter().enumerate() {
        let team = &teams[entry.team_idx];
        let rank = pos + 1;
        let (status_str, color) = match rank {
            1..=8 => ("Round of 16 (Top 8 Bye)", Color::Green),
            9..=24 => ("Knockout Play-offs", Color::Cyan),
            _ => ("Eliminated", Color::Red),
        };

        table.add_row(Row::from(vec![
            Cell::new(rank).fg(color).set_alignment(CellAlignment::Center),
            Cell::new(&team.name).fg(color),
            Cell::new(&team.country).set_alignment(CellAlignment::Center),
            Cell::new(team.pot).set_alignment(CellAlignment::Center),
            Cell::new(8).set_alignment(CellAlignment::Center),
            Cell::new(entry.wins).set_alignment(CellAlignment::Center),
            Cell::new(entry.draws).set_alignment(CellAlignment::Center),
            Cell::new(entry.losses).set_alignment(CellAlignment::Center),
            Cell::new(format!("{}:{}", entry.goals_for, entry.goals_against)).set_alignment(CellAlignment::Center),
            Cell::new(format!("{:+}", entry.goal_diff)).set_alignment(CellAlignment::Right),
            Cell::new(entry.points).fg(color).set_alignment(CellAlignment::Right),
            Cell::new(status_str).fg(color),
        ]));
    }

    println!("\n=== SAMPLE SINGLE SEASON SIMULATION (2026/27 LEAGUE PHASE) ===\n");
    println!("{table}\n");
}

fn print_target_team_distribution(stats: &sim::TeamSimStats, total_sims: usize) {
    println!("\n==================================================================================");
    println!("  DETAILED POSITION DISTRIBUTION: {} ({}, Pot {})", stats.name, stats.country, stats.pot);
    println!("  Squad Value: €{:.1}M | UEFA Coeff: {:.1} | Exp Pts: {:.2}", stats.market_value_eur, stats.uefa_coeff, stats.mean_points(total_sims));
    println!("==================================================================================");

    println!(
        "{:>4} | {:>7} | {:>6} | {}",
        "Rank", "Count", "Prob %", "Distribution"
    );
    println!("----------------------------------------------------------------------------------");

    let max_count = stats.position_counts.iter().cloned().max().unwrap_or(1).max(1);

    for (pos_idx, &count) in stats.position_counts.iter().enumerate() {
        let rank = pos_idx + 1;
        let pct = (count as f64 / total_sims as f64) * 100.0;
        let bar_len = ((count as f64 / max_count as f64) * 40.0).round() as usize;
        let bar = "█".repeat(bar_len);

        let tag = match rank {
            1..=8 => "[Top 8 - R16 Bye]",
            9..=24 => "[Play-offs 9-24]",
            _ => "[Eliminated]",
        };

        println!(
            "{:>4} | {:>7} | {:>5.2}% | {:<40} {}",
            rank, count, pct, bar, tag
        );
    }
    println!("----------------------------------------------------------------------------------\n");
}

fn plot_team_distribution(
    team_name: &str,
    position_counts: &[usize; 36],
    total_sims: usize,
    filename: &str,
) -> Result<(), Box<dyn std::error::Error>> {
    use plotters::prelude::*;

    let root = BitMapBackend::new(filename, (1200, 650)).into_drawing_area();
    root.fill(&WHITE)?;

    let percentages: Vec<(u32, f64)> = position_counts
        .iter()
        .enumerate()
        .map(|(pos, &count)| ((pos + 1) as u32, (count as f64 / total_sims as f64) * 100.0))
        .collect();

    let max_pct = percentages.iter().map(|(_, p)| *p).fold(0.0, f64::max) * 1.20;

    let mut chart = ChartBuilder::on(&root)
        .caption(
            format!("UEFA Champions League 2026/27 - Final Standing Distribution: {} ({} sims)", team_name, total_sims),
            ("sans-serif", 22).into_font(),
        )
        .margin(25)
        .x_label_area_size(45)
        .y_label_area_size(55)
        .build_cartesian_2d(0.5f64..36.5f64, 0.0..max_pct.max(5.0))?;

    chart
        .configure_mesh()
        .disable_x_mesh()
        .x_labels(36)
        .x_label_formatter(&|x| {
            let val = x.round() as u32;
            if (1..=36).contains(&val) && (*x - val as f64).abs() < 0.05 {
                format!("{}", val)
            } else {
                "".to_string()
            }
        })
        .x_desc("Final League Phase Position (1 to 36)")
        .y_desc("Probability (%)")
        .axis_desc_style(("sans-serif", 15))
        .draw()?;

    chart.draw_series(
        percentages.iter().map(|&(pos, pct)| {
            let x = pos as f64;
            let color = match pos {
                1..=8 => RGBColor(46, 117, 182),   // Blue: Top 8 (R16 Bye)
                9..=24 => RGBColor(112, 173, 71), // Green: Play-offs
                _ => RGBColor(192, 0, 0),         // Red: Eliminated
            };
            Rectangle::new(
                [(x - 0.38, 0.0), (x + 0.38, pct)],
                color.filled(),
            )
        }),
    )?;

    chart.draw_series(
        percentages.iter().filter(|&&(_, pct)| pct > 1.0).map(|&(pos, pct)| {
            let x = pos as f64;
            EmptyElement::at((x, pct))
                + Text::new(
                    format!("{:.1}%", pct),
                    (-12, -14),
                    ("sans-serif", 10).into_font().color(&BLACK),
                )
        }),
    )?;

    root.present()?;
    println!("Generated position distribution chart: {}", filename);
    Ok(())
}

fn export_csv(
    path: &PathBuf,
    summary: &sim::SimulationSummary,
) -> Result<(), Box<dyn std::error::Error>> {
    let mut file = File::create(path)?;
    writeln!(
        file,
        "Rank,Team,Country,Pot,MarketValue_M_Eur,UEFA_Coeff,Exp_Points,Std_Points,Exp_GD,Exp_GF,Exp_GA,Top8_Pct,Playoff_Pct,Eliminated_Pct,Title_Pct,Mean_Position"
    )?;

    for (pos, s) in summary.team_stats.iter().enumerate() {
        let n = summary.simulations;
        writeln!(
            file,
            "{},\"{}\",{},{},{:.2},{:.3},{:.2},{:.2},{:.2},{:.2},{:.2},{:.2},{:.2},{:.2},{:.2},{:.2}",
            pos + 1,
            s.name,
            s.country,
            s.pot,
            s.market_value_eur,
            s.uefa_coeff,
            s.mean_points(n),
            s.std_points(n),
            s.mean_goal_diff(n),
            s.mean_goals_for(n),
            s.mean_goals_against(n),
            s.top8_pct(n),
            s.playoff_pct(n),
            s.eliminated_pct(n),
            s.title_pct(n),
            s.mean_position(n),
        )?;
    }
    println!("Exported simulation results to CSV: {}", path.display());
    Ok(())
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let cli = Cli::parse();

    let teams = load_teams(cli.teams_path.as_ref())?;
    let fixtures = load_fixtures(cli.fixtures_path.as_ref())?;

    if teams.len() != 36 {
        return Err(format!("Expected 36 teams, found {}", teams.len()).into());
    }
    if fixtures.len() != 144 {
        return Err(format!("Expected 144 fixtures, found {}", fixtures.len()).into());
    }

    if cli.show_fixtures {
        print_fixtures(&fixtures);
        if !cli.single_season && cli.simulations == 0 {
            return Ok(());
        }
    }

    let team_name_to_idx: HashMap<String, usize> = teams
        .iter()
        .map(|t| (t.name.clone(), t.id))
        .collect();

    let indexed_fixtures = build_indexed_fixtures(&fixtures, &team_name_to_idx)?;

    let weights = ModelWeights {
        w_uefa: cli.w_uefa,
        w_market: cli.w_market,
        w_ytd: cli.w_ytd,
        home_advantage: cli.home_adv,
        base_goals: 1.35,
        beta: cli.beta,
    };

    let ratings = compute_team_ratings(&teams, &weights);

    if cli.single_season {
        print_single_season(&teams, &indexed_fixtures, &ratings, &weights);
    }

    println!("\n==========================================================================================");
    println!("  UEFA CHAMPIONS LEAGUE 2026/27 — LEAGUE PHASE MONTE CARLO SIMULATION");
    println!("  Simulations : {:>10}  | Multi-core parallel engine (Rayon)", cli.simulations);
    println!("  Weights     : UEFA Coeff: {:.2} | Market Value: {:.2} | YTD Form: {:.2}", weights.w_uefa, weights.w_market, weights.w_ytd);
    println!("  Home Adv    : {:+.2} goals   | Sensitivity Beta: {:.2}", weights.home_advantage, weights.beta);
    println!("==========================================================================================\n");

    let summary = run_monte_carlo(&teams, &indexed_fixtures, &weights, cli.simulations);

    println!("Simulation completed in {:.3} seconds ({:.0} matches simulated/sec)\n",
        summary.duration_secs,
        (cli.simulations as f64 * 144.0) / summary.duration_secs.max(1e-6)
    );

    let mut table = Table::new();
    table
        .load_preset(UTF8_FULL)
        .apply_modifier(UTF8_ROUND_CORNERS)
        .set_width(140)
        .set_content_arrangement(ContentArrangement::Dynamic)
        .set_header(vec![
            Cell::new("Rk").set_alignment(CellAlignment::Center),
            Cell::new("Team").set_alignment(CellAlignment::Left),
            Cell::new("Pot").set_alignment(CellAlignment::Center),
            Cell::new("Coeff").set_alignment(CellAlignment::Right),
            Cell::new("Value (€)").set_alignment(CellAlignment::Right),
            Cell::new("Exp Pts").set_alignment(CellAlignment::Right),
            Cell::new("Exp GD").set_alignment(CellAlignment::Right),
            Cell::new("Exp GF:GA").set_alignment(CellAlignment::Center),
            Cell::new("Mean Pos").set_alignment(CellAlignment::Right),
            Cell::new("Top 8 %").set_alignment(CellAlignment::Right),
            Cell::new("Playoffs %").set_alignment(CellAlignment::Right),
            Cell::new("Elim %").set_alignment(CellAlignment::Right),
        ]);

    for (pos, s) in summary.team_stats.iter().enumerate() {
        let rank = pos + 1;
        let is_target = cli.target_team.as_ref().map_or(false, |t| {
            s.name.to_lowercase().contains(&t.to_lowercase())
        });

        let (row_color, status_color) = match rank {
            1..=8 => (Color::Green, Color::Green),
            9..=24 => (Color::Cyan, Color::Cyan),
            _ => (Color::DarkGrey, Color::Red),
        };

        let team_cell = if is_target {
            Cell::new(format!("★ {}", s.name)).fg(Color::Yellow)
        } else {
            Cell::new(&s.name).fg(row_color)
        };

        let n = summary.simulations;
        let exp_pts_str = format!("{:.1} ±{:.1}", s.mean_points(n), s.std_points(n));
        let exp_gd_str = format!("{:+5.1}", s.mean_goal_diff(n));
        let gf_ga_str = format!("{:.1}:{:.1}", s.mean_goals_for(n), s.mean_goals_against(n));

        let top8_cell = Cell::new(format!("{:.1}%", s.top8_pct(n))).fg(
            if s.top8_pct(n) >= 50.0 { Color::Green } else { Color::White }
        ).set_alignment(CellAlignment::Right);

        let playoff_cell = Cell::new(format!("{:.1}%", s.playoff_pct(n))).fg(
            if s.playoff_pct(n) >= 50.0 { Color::Cyan } else { Color::White }
        ).set_alignment(CellAlignment::Right);

        let elim_cell = Cell::new(format!("{:.1}%", s.eliminated_pct(n))).fg(
            if s.eliminated_pct(n) >= 50.0 { Color::Red } else { Color::White }
        ).set_alignment(CellAlignment::Right);

        table.add_row(Row::from(vec![
            Cell::new(rank).fg(status_color).set_alignment(CellAlignment::Center),
            team_cell,
            Cell::new(s.pot).set_alignment(CellAlignment::Center),
            Cell::new(format!("{:.1}", s.uefa_coeff)).set_alignment(CellAlignment::Right),
            Cell::new(format!("€{:.0}M", s.market_value_eur)).set_alignment(CellAlignment::Right),
            Cell::new(exp_pts_str).fg(status_color).set_alignment(CellAlignment::Right),
            Cell::new(exp_gd_str).set_alignment(CellAlignment::Right),
            Cell::new(gf_ga_str).set_alignment(CellAlignment::Center),
            Cell::new(format!("{:.1}", s.mean_position(n))).set_alignment(CellAlignment::Right),
            top8_cell,
            playoff_cell,
            elim_cell,
        ]));
    }

    println!("{table}");

    println!("\n------------------------------------------------------------------------------------------");
    println!("  QUALIFICATION CUTOFF THRESHOLDS (Expected Points Needed Across {} Simulations):", cli.simulations);
    println!("  • TOP 8 (Direct R16 Bye)     : Mean = {:.2} pts  |  50% Median = {} pts  |  90% Safe = {} pts",
        summary.cutoff_top8_mean, summary.cutoff_top8_p50, summary.cutoff_top8_p90
    );
    println!("  • TOP 24 (Play-off Cutoff)   : Mean = {:.2} pts  |  50% Median = {} pts  |  90% Safe = {} pts",
        summary.cutoff_top24_mean, summary.cutoff_top24_p50, summary.cutoff_top24_p90
    );
    println!("------------------------------------------------------------------------------------------\n");

    if let Some(target) = &cli.target_team {
        if let Some(s) = summary.team_stats.iter().find(|t| {
            t.name.to_lowercase().contains(&target.to_lowercase())
        }) {
            print_target_team_distribution(s, summary.simulations);

            if let Some(ref p) = cli.plot_path {
                plot_team_distribution(&s.name, &s.position_counts, summary.simulations, p)?;
            }
        } else {
            eprintln!("Warning: Target team '{}' not found in participants.", target);
        }
    } else if let Some(ref p) = cli.plot_path {
        // If plot requested without target team, plot the top ranked team by default
        if let Some(s) = summary.team_stats.first() {
            plot_team_distribution(&s.name, &s.position_counts, summary.simulations, p)?;
        }
    }

    if let Some(csv_path) = &cli.csv_path {
        export_csv(csv_path, &summary)?;
    }

    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_embedded_data_integrity() {
        let teams = load_teams(None).expect("Failed to load embedded teams");
        let fixtures = load_fixtures(None).expect("Failed to load embedded fixtures");

        assert_eq!(teams.len(), 36, "Must have exactly 36 teams");
        assert_eq!(fixtures.len(), 144, "Must have exactly 144 fixtures");

        let team_name_to_idx: HashMap<String, usize> = teams
            .iter()
            .map(|t| (t.name.clone(), t.id))
            .collect();

        assert_eq!(team_name_to_idx.len(), 36, "All team names must be unique");

        let mut home_counts = HashMap::new();
        let mut away_counts = HashMap::new();

        for f in &fixtures {
            assert!(
                team_name_to_idx.contains_key(&f.home_team),
                "Home team '{}' not recognized",
                f.home_team
            );
            assert!(
                team_name_to_idx.contains_key(&f.away_team),
                "Away team '{}' not recognized",
                f.away_team
            );

            *home_counts.entry(f.home_team.clone()).or_insert(0) += 1;
            *away_counts.entry(f.away_team.clone()).or_insert(0) += 1;
        }

        for t in &teams {
            assert_eq!(
                home_counts.get(&t.name).copied().unwrap_or(0),
                4,
                "Team {} must have exactly 4 home matches",
                t.name
            );
            assert_eq!(
                away_counts.get(&t.name).copied().unwrap_or(0),
                4,
                "Team {} must have exactly 4 away matches",
                t.name
            );
        }
    }
}
