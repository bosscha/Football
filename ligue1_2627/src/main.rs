mod model;
mod report;
mod sim;
mod table;

use clap::Parser;
use comfy_table::presets::UTF8_FULL;
use comfy_table::{Cell, Color, ContentArrangement, Table};
use model::{compute_team_ratings, expected_goals, Fixture, IndexedFixture, ModelWeights, Team};
use report::{generate_brest_pdf_report, generate_typst_report, plot_brest_positions};
use sim::run_monte_carlo;
use std::collections::HashMap;
use std::fs::File;
use std::io::BufReader;
use std::time::Instant;

#[derive(Parser, Debug)]
#[command(name = "ligue1_simulation")]
#[command(about = "Simulation Monte-Carlo de la saison de Ligue 1 2026/2027")]
struct Args {
    #[arg(short = 'n', long, default_value_t = 100_000)]
    simulations: usize,

    #[arg(long, default_value = "data/teams.json")]
    teams: String,

    #[arg(long, default_value = "data/fixtures.json")]
    fixtures: String,

    #[arg(long, default_value = "Stade brestois 29")]
    target_team: String,

    #[arg(long, default_value = "ligue1_2627_standings.csv")]
    csv: String,

    #[arg(long, default_value = "brest_positions.png")]
    plot: String,

    #[arg(long, default_value = "ligue1_2627_summary.typ")]
    typst: String,

    #[arg(long, default_value = "ligue1_2627_summary.pdf")]
    pdf: String,

    #[arg(long, default_value = "brest_sb29_report.typ")]
    brest_typst: String,

    #[arg(long, default_value = "brest_sb29_simulation_report.pdf")]
    brest_pdf: String,
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let args = Args::parse();

    println!("===============================================================================");
    println!("     SIMULATION MONTE-CARLO LIGUE 1 2026/2027 (CALENDRIER OFFICIEL)            ");
    println!("===============================================================================");

    // 1. Load teams
    let teams_file = File::open(&args.teams)
        .unwrap_or_else(|e| panic!("Impossible d'ouvrir {}: {}", args.teams, e));
    let teams: Vec<Team> = serde_json::from_reader(BufReader::new(teams_file))?;
    println!("Chargement de {} équipes depuis {}", teams.len(), args.teams);

    let team_index_map: HashMap<String, usize> = teams
        .iter()
        .enumerate()
        .map(|(i, t)| (t.name.clone(), i))
        .collect();

    let target_idx = team_index_map
        .get(&args.target_team)
        .copied()
        .unwrap_or_else(|| panic!("Équipe cible '{}' non trouvée dans la liste des clubs", args.target_team));

    // 2. Load fixtures
    let fixtures_file = File::open(&args.fixtures)
        .unwrap_or_else(|e| panic!("Impossible d'ouvrir {}: {}", args.fixtures, e));
    let fixtures: Vec<Fixture> = serde_json::from_reader(BufReader::new(fixtures_file))?;
    println!("Chargement de {} matchs officiels depuis {}", fixtures.len(), args.fixtures);

    // Build indexed fixtures
    let indexed_fixtures: Vec<IndexedFixture> = fixtures
        .iter()
        .enumerate()
        .map(|(f_idx, f)| {
            let h = *team_index_map.get(&f.home_team).unwrap_or_else(|| {
                panic!("Équipe à domicile inconnue: {}", f.home_team)
            });
            let a = *team_index_map.get(&f.away_team).unwrap_or_else(|| {
                panic!("Équipe à l'extérieur inconnue: {}", f.away_team)
            });
            IndexedFixture {
                fixture_idx: f_idx,
                matchday: f.matchday,
                home_idx: h,
                away_idx: a,
            }
        })
        .collect();

    // 3. Compute strength ratings
    let weights = ModelWeights::default();
    let ratings = compute_team_ratings(&teams, &weights);

    println!("\nIndicateurs de force des clubs (Poids: 35% Bilan 25/26, 25% UEFA, 40% Valeur TM):");
    println!("{:-<78}", "");
    println!("{:<24} | {:>10} | {:>12} | {:>10} | {:>8}", "Club", "Bilan (PPG)", "Valeur (M€)", "UEFA Coeff", "Note (R)");
    println!("{:-<78}", "");
    for (i, t) in teams.iter().enumerate() {
        println!(
            "{:<24} | {:>7.2} pts | {:>10.1}M€ | {:>10.1} | {:>8.3}",
            t.name, t.prev_season.ppg, t.market_value_eur, t.uefa_coeff, ratings[i]
        );
    }
    println!("{:-<78}", "");

    // 4. Run simulations
    println!("\nLancement de {} simulations Monte-Carlo en parallèle...", args.simulations);
    let start_time = Instant::now();
    let sim_result = run_monte_carlo(&teams, &indexed_fixtures, &ratings, &weights, args.simulations);
    let duration = start_time.elapsed();
    println!("Simulation terminée en {:.2?} ({:.1} saisons/sec)", duration, args.simulations as f64 / duration.as_secs_f64());

    // 5. Display Terminal Table
    let mut ranked_team_indices: Vec<usize> = (0..teams.len()).collect();
    ranked_team_indices.sort_by(|&a, &b| {
        sim_result.team_stats[b].total_points.partial_cmp(&sim_result.team_stats[a].total_points).unwrap()
    });

    let mut table = Table::new();
    table
        .load_preset(UTF8_FULL)
        .set_content_arrangement(ContentArrangement::Dynamic)
        .set_header(vec![
            Cell::new("Pos").fg(Color::Cyan),
            Cell::new("Club").fg(Color::Cyan),
            Cell::new("Pts Moy").fg(Color::Cyan),
            Cell::new("Méd").fg(Color::Cyan),
            Cell::new("V - N - D").fg(Color::Cyan),
            Cell::new("Diff").fg(Color::Cyan),
            Cell::new("Titre %").fg(Color::Yellow),
            Cell::new("Top 3 UCL").fg(Color::Blue),
            Cell::new("4e UCL").fg(Color::Blue),
            Cell::new("C3/C4 %").fg(Color::Green),
            Cell::new("Barrage 16e").fg(Color::DarkYellow),
            Cell::new("Descente").fg(Color::Red),
        ]);

    let n = args.simulations as f64;
    for (rank, &tidx) in ranked_team_indices.iter().enumerate() {
        let t = &teams[tidx];
        let st = &sim_result.team_stats[tidx];

        let mean_pts = st.total_points / n;
        let std_pts = ((st.total_points_sq / n) - (mean_pts * mean_pts)).max(0.0).sqrt();
        let med_pts = st.median_points(args.simulations);
        let mean_w = st.total_wins / n;
        let mean_d = st.total_draws / n;
        let mean_l = st.total_losses / n;
        let mean_gd = st.total_gd / n;

        let p_title = (st.title_count as f64 / n) * 100.0;
        let p_ucl_dir = (st.ucl_direct_count as f64 / n) * 100.0;
        let p_ucl_play = (st.ucl_playoff_count as f64 / n) * 100.0;
        let p_europe = ((st.europa_count + st.conf_count) as f64 / n) * 100.0;
        let p_barrage = (st.playoff_count as f64 / n) * 100.0;
        let p_relegation = (st.relegation_count as f64 / n) * 100.0;

        let name_cell = if tidx == target_idx {
            Cell::new(format!("⚓ {}", t.name)).fg(Color::Red)
        } else {
            Cell::new(&t.name)
        };

        table.add_row(vec![
            Cell::new((rank + 1).to_string()),
            name_cell,
            Cell::new(format!("{:.1} ± {:.1}", mean_pts, std_pts)),
            Cell::new(med_pts.to_string()),
            Cell::new(format!("{:.0} - {:.0} - {:.0}", mean_w, mean_d, mean_l)),
            Cell::new(format!("{:+.1}", mean_gd)),
            Cell::new(format!("{:.1}%", p_title)),
            Cell::new(format!("{:.1}%", p_ucl_dir)),
            Cell::new(format!("{:.1}%", p_ucl_play)),
            Cell::new(format!("{:.1}%", p_europe)),
            Cell::new(format!("{:.1}%", p_barrage)),
            Cell::new(format!("{:.1}%", p_relegation)),
        ]);
    }
    println!("\n{}\n", table);

    // 6. Display Brest SB 29 Schedule & Median Scores
    println!("Calendrier officiel et Scores Médians pour {} (34 matchs) :", args.target_team);
    let mut brest_table = Table::new();
    brest_table
        .load_preset(UTF8_FULL)
        .set_content_arrangement(ContentArrangement::Dynamic)
        .set_header(vec![
            Cell::new("Journée").fg(Color::Cyan),
            Cell::new("Date").fg(Color::Cyan),
            Cell::new("Affiche").fg(Color::Cyan),
            Cell::new("Lieu").fg(Color::Cyan),
            Cell::new("xG D - E").fg(Color::Cyan),
            Cell::new("Score Méd. Match").fg(Color::Yellow),
            Cell::new("Score Mode (%)").fg(Color::Blue),
            Cell::new("P(Victoire)").fg(Color::Green),
            Cell::new("P(Nul)").fg(Color::Yellow),
            Cell::new("P(Défaite)").fg(Color::Red),
        ]);

    let mut brest_fixtures: Vec<(usize, &IndexedFixture)> = indexed_fixtures
        .iter()
        .enumerate()
        .filter(|(_, f)| f.home_idx == target_idx || f.away_idx == target_idx)
        .collect();
    brest_fixtures.sort_by_key(|(_, f)| f.matchday);

    for (fix_global_idx, fix) in &brest_fixtures {
        let is_home = fix.home_idx == target_idx;
        let opp_idx = if is_home { fix.away_idx } else { fix.home_idx };
        let opp = &teams[opp_idx];

        let f_meta = &fixtures[*fix_global_idx];
        let f_stat = &sim_result.fixture_stats[fix.fixture_idx];

        let (med_b, med_o, med_diff) = f_stat.median_match_score(args.simulations, is_home);
        let (med_h, med_a) = if is_home { (med_b, med_o) } else { (med_o, med_b) };
        let outcome_tag = if med_diff > 0 { " (V)" } else if med_diff == 0 { " (N)" } else { " (D)" };
        let score_med_str = format!("{} - {}{}", med_h, med_a, outcome_tag);

        let (mod_h, mod_a, mod_pct) = f_stat.most_frequent_score(args.simulations);
        let score_mod_str = format!("{} - {} ({:.1}%)", mod_h, mod_a, mod_pct);

        let (xg_h, xg_a) = expected_goals(fix.home_idx, fix.away_idx, &ratings, &weights);

        let p_hw = (f_stat.home_wins as f64 / n) * 100.0;
        let p_dr = (f_stat.draws as f64 / n) * 100.0;
        let p_aw = (f_stat.away_wins as f64 / n) * 100.0;

        let (match_str, venue_str, p_w, p_d, p_l) = if is_home {
            (
                format!("Brest vs {}", opp.name),
                "Francis-Le Blé",
                p_hw,
                p_dr,
                p_aw,
            )
        } else {
            (
                format!("{} vs Brest", opp.name),
                opp.stadium.as_str(),
                p_aw,
                p_dr,
                p_hw,
            )
        };

        brest_table.add_row(vec![
            Cell::new(format!("J{:02}", fix.matchday)),
            Cell::new(&f_meta.date),
            Cell::new(match_str),
            Cell::new(venue_str),
            Cell::new(format!("{:.2} - {:.2}", xg_h, xg_a)),
            Cell::new(score_med_str).fg(Color::Yellow),
            Cell::new(score_mod_str).fg(Color::Blue),
            Cell::new(format!("{:.1}%", p_w)),
            Cell::new(format!("{:.1}%", p_d)),
            Cell::new(format!("{:.1}%", p_l)),
        ]);
    }
    println!("{}\n", brest_table);

    // 7. Save CSV standings
    {
        use std::io::Write;
        let mut csv_file = File::create(&args.csv)?;
        writeln!(csv_file, "rank,name,mean_points,std_points,median_points,mean_wins,mean_draws,mean_losses,mean_gd,title_pct,ucl_direct_pct,ucl_playoff_pct,europe_pct,playoff_16th_pct,relegation_pct")?;
        for (rank, &tidx) in ranked_team_indices.iter().enumerate() {
            let t = &teams[tidx];
            let st = &sim_result.team_stats[tidx];
            let mean_pts = st.total_points / n;
            let std_pts = ((st.total_points_sq / n) - (mean_pts * mean_pts)).max(0.0).sqrt();
            let med_pts = st.median_points(args.simulations);
            let mean_w = st.total_wins / n;
            let mean_d = st.total_draws / n;
            let mean_l = st.total_losses / n;
            let mean_gd = st.total_gd / n;
            let p_title = (st.title_count as f64 / n) * 100.0;
            let p_ucl_dir = (st.ucl_direct_count as f64 / n) * 100.0;
            let p_ucl_play = (st.ucl_playoff_count as f64 / n) * 100.0;
            let p_europe = ((st.europa_count + st.conf_count) as f64 / n) * 100.0;
            let p_barrage = (st.playoff_count as f64 / n) * 100.0;
            let p_relegation = (st.relegation_count as f64 / n) * 100.0;

            writeln!(
                csv_file,
                "{},\"{}\",{:.2},{:.2},{},{:.2},{:.2},{:.2},{:.2},{:.2},{:.2},{:.2},{:.2},{:.2},{:.2}",
                rank + 1, t.name, mean_pts, std_pts, med_pts, mean_w, mean_d, mean_l, mean_gd,
                p_title, p_ucl_dir, p_ucl_play, p_europe, p_barrage, p_relegation
            )?;
        }
        println!("Classement complet exporté dans {}", args.csv);
    }

    // 8. Generate Plot
    plot_brest_positions(
        &sim_result.team_stats[target_idx].position_counts,
        args.simulations,
        &args.plot,
    )?;

    // 9. Generate Typst and compile PDF (Global Summary)
    generate_typst_report(
        &teams,
        &fixtures,
        &indexed_fixtures,
        &ratings,
        &weights,
        &sim_result,
        target_idx,
        &args.typst,
        &args.pdf,
    )?;

    // 10. Generate Dedicated Typst and compile PDF for Brest SB 29
    generate_brest_pdf_report(
        &teams,
        &fixtures,
        &indexed_fixtures,
        &ratings,
        &weights,
        &sim_result,
        target_idx,
        &args.brest_typst,
        &args.brest_pdf,
    )?;

    println!("===============================================================================");
    println!("Simulation et génération des rapports PDF terminées avec succès !");
    println!("===============================================================================");

    Ok(())
}
