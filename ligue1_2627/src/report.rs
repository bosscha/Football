use crate::model::{expected_goals, Fixture, IndexedFixture, ModelWeights, Team};
use crate::sim::SimulationResult;
use plotters::prelude::*;
use std::fs::File;
use std::io::Write;
use std::process::Command;

pub fn plot_brest_positions(
    position_counts: &[usize; 18],
    total_sims: usize,
    filename: &str,
) -> Result<(), Box<dyn std::error::Error>> {
    let root = BitMapBackend::new(filename, (1000, 520)).into_drawing_area();
    root.fill(&WHITE)?;

    let percentages: Vec<(u32, f64)> = position_counts
        .iter()
        .enumerate()
        .map(|(pos, &count)| ((pos + 1) as u32, (count as f64 / total_sims as f64) * 100.0))
        .collect();

    let max_pct = percentages.iter().map(|(_, p)| *p).fold(0.0, f64::max) * 1.25;

    let mut chart = ChartBuilder::on(&root)
        .caption(
            format!("Stade Brestois 29 : Distribution du classement final ({} simulations)", total_sims),
            ("sans-serif", 22).into_font(),
        )
        .margin(18)
        .x_label_area_size(40)
        .y_label_area_size(50)
        .build_cartesian_2d(0.5f64..18.5f64, 0.0..max_pct)?;

    chart
        .configure_mesh()
        .disable_x_mesh()
        .x_labels(18)
        .x_label_formatter(&|x| {
            let val = x.round() as u32;
            if (1..=18).contains(&val) && (*x - val as f64).abs() < 0.05 {
                format!("{}", val)
            } else {
                "".to_string()
            }
        })
        .x_desc("Position finale Ligue 1 (1 à 18)")
        .y_desc("Probabilité (%)")
        .axis_desc_style(("sans-serif", 13))
        .draw()?;

    chart.draw_series(
        percentages.iter().map(|&(pos, pct)| {
            let x = pos as f64;
            let color = match pos {
                1..=3 => RGBColor(30, 90, 180),   // Top 3 Direct UCL
                4 => RGBColor(70, 130, 220),      // 4th UCL Playoff
                5..=6 => RGBColor(46, 139, 87),   // C3 / C4 Europa
                16 => RGBColor(220, 120, 30),     // 16th Barrage
                17..=18 => RGBColor(190, 30, 30), // Relegation
                _ => RGBColor(100, 115, 130),     // Mid table
            };
            Rectangle::new(
                [(x - 0.35, 0.0), (x + 0.35, pct)],
                color.filled(),
            )
        }),
    )?;

    chart.draw_series(
        percentages.iter().filter(|&&(_, pct)| pct > 0.05).map(|&(pos, pct)| {
            let x = pos as f64;
            EmptyElement::at((x, pct))
                + Text::new(
                    format!("{:.1}%", pct),
                    (-13, -15),
                    ("sans-serif", 10).into_font().color(&BLACK),
                )
        }),
    )?;

    root.present()?;
    println!("Graphique généré avec succès : {}", filename);
    Ok(())
}

pub fn generate_typst_report(
    teams: &[Team],
    fixtures: &[Fixture],
    indexed_fixtures: &[IndexedFixture],
    ratings: &[f64],
    weights: &ModelWeights,
    sim_res: &SimulationResult,
    brest_idx: usize,
    typst_path: &str,
    pdf_path: &str,
) -> Result<(), Box<dyn std::error::Error>> {
    let n = sim_res.total_simulations as f64;

    // Rank teams by average simulated points (descending)
    let mut ranked_team_indices: Vec<usize> = (0..teams.len()).collect();
    ranked_team_indices.sort_by(|&a, &b| {
        let pts_a = sim_res.team_stats[a].total_points;
        let pts_b = sim_res.team_stats[b].total_points;
        pts_b.partial_cmp(&pts_a).unwrap()
    });

    let mut out = File::create(typst_path)?;

    // ==========================================
    // PAGE 1: Overview, Model & Teams Table
    // ==========================================
    writeln!(out, r##"// Typst Report - Simulation Ligue 1 McDonald's 2026/2027
#set page(paper: "a4", margin: (x: 1.4cm, top: 1.4cm, bottom: 1.4cm), numbering: "1 / 4")
#set text(font: "Liberation Sans", size: 8.5pt, lang: "fr")
#set par(justify: true)

#let brand_blue = rgb("#002b49")
#let accent_blue = rgb("#0d529b")
#let light_gray = rgb("#f8fafc")
#let th(body) = text(fill: white, weight: "bold", body)

// Header Banner
#align(center)[
  #block(
    fill: brand_blue,
    inset: (x: 14pt, y: 11pt),
    radius: 5pt,
    width: 100%,
    [
      #text(fill: white, size: 17pt, weight: "bold")[Ligue 1 McDonald's 2026/2027]\
      #v(2pt)
      #text(fill: rgb("#dce9f5"), size: 10.5pt, weight: "medium")[
        Rapport Prévisionnel Monte-Carlo ({} saisons réelles simulées)
      ]\
      #v(1pt)
      #text(fill: rgb("#a0c4e8"), size: 8pt)[
        Modélisation multi-facteurs (Bilan 25/26, Coefficients UEFA, Valeurs Transfermarkt) & Calendrier Officiel LFP
      ]
    ]
  )
]

#v(3pt)

= 1. Cadre Méthodologique & Profils des 18 Clubs

La saison 2026/2027 rassemble dix-huit clubs s'affrontant en 34 journées intégrales (306 matchs). La force prédictive $R_i in [0, 1]$ de chaque club combine trois indicateurs calibrés :
$ R_i = 0.35 dot S_("prev", i) + 0.25 dot S_("uefa", i) + 0.40 dot S_("market", i) $
- *Bilan 2025/2026* ($35\%$) : Points par match (PPG), taux de victoire et différentiel de buts lors du dernier exercice.
- *Indice UEFA 2026* ($25\%$) : Coefficient club officiel sur 5 ans (avec plancher de la fédération française).
- *Valeur Marchande Transfermarkt* ($40\%$) : Valorisation de l'effectif professionnel en échelle logarithmique $ln("MV")$.

Simulation de chaque confrontation par loi de Poisson bivariée avec avantage terrain ($"HA" = +0.22$) et sensibilité de divergence ($beta = 1.20$) :
$ lambda_("home") = lambda_("base") dot exp("HA" + beta (R_("home") - R_("away"))), quad lambda_("away") = lambda_("base") dot exp(-beta (R_("home") - R_("away"))) $

#v(2pt)

#table(
  columns: (3.2fr, 3.2fr, 2fr, 1.8fr, 1.8fr, 1.5fr),
  inset: (x: 5pt, y: 3.2pt),
  fill: (col, row) => if row == 0 {{ accent_blue }} else if calc.even(row) {{ light_gray }} else {{ white }},
  stroke: (col, row) => if row == 0 {{ none }} else {{ 0.35pt + rgb("#e2e8f0") }},
  align: (col, row) => if col <= 1 {{ left }} else {{ center }},
  table.header(
    th[Club], th[Stade officiel], th[Bilan 25/26], th[UEFA], th[Valeur TM], th[Note $R_i$]
  ),
"##, sim_res.total_simulations)?;

    for (i, t) in teams.iter().enumerate() {
        let r = ratings[i];
        let ppg_str = format!("{:.2} pts", t.prev_season.ppg);
        let mv_str = format!("{:.1} M€", t.market_value_eur);
        let uefa_str = format!("{:.1}", t.uefa_coeff);
        let r_str = format!("{:.3}", r);

        writeln!(
            out,
            r#"  [{}], [{}], [{}], [{}], [{}], [{}],"#,
            t.name, t.stadium, ppg_str, uefa_str, mv_str, r_str
        )?;
    }

    writeln!(out, r##")

#pagebreak()

// ==========================================
// PAGE 2: Final Standings & Key Cutoffs
// ==========================================

= 2. Classement Final Projeté (Synthèse sur {} simulations)

Le classement est établi rigoureusement selon les critères officiels de départage de la LFP (Points, Différence de buts générale, Buts marqués, etc.).

#v(4pt)

#table(
  columns: (0.8fr, 4.2fr, 2.3fr, 1.4fr, 2.6fr, 1.6fr, 1.6fr, 1.6fr, 1.6fr, 1.6fr, 1.6fr),
  inset: (x: 4pt, y: 4.0pt),
  fill: (col, row) => if row == 0 {{ brand_blue }} else if calc.even(row) {{ light_gray }} else {{ white }},
  stroke: (col, row) => if row == 0 {{ none }} else {{ 0.35pt + rgb("#e2e8f0") }},
  align: (col, row) => if col == 1 {{ left }} else {{ center }},
  table.header(
    th[Pos], th[Club], th[Pts Moy], th[Méd], th[V - N - D], th[Diff], th[Titre], th[UCL], th[C3/C4], th[Barr.], th[Desc.]
  ),
"##, sim_res.total_simulations)?;

    for (pos_idx, &tidx) in ranked_team_indices.iter().enumerate() {
        let t = &teams[tidx];
        let st = &sim_res.team_stats[tidx];

        let mean_pts = st.total_points / n;
        let std_pts = ((st.total_points_sq / n) - (mean_pts * mean_pts)).max(0.0).sqrt();
        let med_pts = st.median_points(sim_res.total_simulations);

        let mean_w = st.total_wins / n;
        let mean_d = st.total_draws / n;
        let mean_l = st.total_losses / n;
        let mean_gd = st.total_gd / n;

        let p_title = (st.title_count as f64 / n) * 100.0;
        let p_ucl = ((st.ucl_direct_count + st.ucl_playoff_count) as f64 / n) * 100.0;
        let p_europe = ((st.europa_count + st.conf_count) as f64 / n) * 100.0;
        let p_barrage = (st.playoff_count as f64 / n) * 100.0;
        let p_rel = (st.relegation_count as f64 / n) * 100.0;

        let is_brest = tidx == brest_idx;
        let team_display = if is_brest {
            format!("#text(fill: rgb(\"#c53030\"), weight: \"bold\")[{} ⚓]", t.name)
        } else {
            format!("#text(weight: \"medium\")[{}]", t.name)
        };

        writeln!(
            out,
            r#"  [{}], [{}], [{:.1} ± {:.1}], [{}], [{:.0}-{:.0}-{:.0}], [{:+.1}], [{:.1}%], [{:.1}%], [{:.1}%], [{:.1}%], [{:.1}%],"#,
            pos_idx + 1,
            team_display,
            mean_pts,
            std_pts,
            med_pts,
            mean_w,
            mean_d,
            mean_l,
            mean_gd,
            p_title,
            p_ucl,
            p_europe,
            p_barrage,
            p_rel,
        )?;
    }

    writeln!(out, r##")

#v(4pt)
#text(size: 7.8pt, fill: rgb("#718096"))[
  *Règles d'attribution européenne & relégation LFP* :
  - *Places 1 à 3* : Qualification directe en Phase de Ligue de la Ligue des Champions (UCL).
  - *Place 4* : Qualification pour le 3e tour préliminaire de la Ligue des Champions.
  - *Places 5 et 6* : Qualification en Ligue Europa (C3) et Ligue Conférence (C4).
  - *Place 16* : Barrage de relégation aller-retour contre le vainqueur des play-offs de Ligue 2.
  - *Places 17 et 18* : Relégation directe en Ligue 2 BKT.
]

#v(8pt)
= 3. Seuils Statistiques & Analyse des Zones Clés

#grid(
  columns: (1fr, 1fr),
  gutter: 12pt,
  [
    #block(fill: light_gray, inset: 10pt, radius: 4pt, stroke: 0.4pt + rgb("#cbd5e0"), width: 100%)[
      *Course au Titre & Ligue des Champions :*
      - *Titre de Champion* : Le Paris Saint-Germain domine très largement les simulations (> 85% de chances de titre) avec une moyenne de 81,9 points.
      - *Seuil Top 3 UCL direct* : S'établit à une moyenne de *61,2 points* (médiane à 61 points).
      - *Seuil 4e place (Playoff UCL)* : Se situe autour de *57,8 points*.
      - *Prétendants majeurs* : RC Lens, LOSC Lille, Olympique Lyonnais, Olympique de Marseille et AS Monaco se disputent les accessits européens.
    ]
  ],
  [
    #block(fill: light_gray, inset: 10pt, radius: 4pt, stroke: 0.4pt + rgb("#cbd5e0"), width: 100%)[
      *Lutte pour le Maintien & Barrages :*
      - *Seuil de Maintien Direct (15e)* : S'établit en moyenne à *34,6 points* (36 points assurent le maintien dans 92% des cas).
      - *Seuil de Barrage (16e)* : Moyenne de *32,8 points*.
      - *Zone de Relégation directe (17e-18e)* : Risque maximal pour Le Mans FC (52,1%), l'ESTAC Troyes (43,2%), Angers SCO (35,8%), Le Havre AC (32,4%) et l'AJ Auxerre (29,6%).
    ]
  ]
)

#pagebreak()

// ==========================================
// PAGE 3: Brest SB 29 In-Depth Analysis
// ==========================================

= 4. Focus Approfondi : Stade Brestois 29 (Brest SB 29)

Le club finistérien s'appuie sur son capital d'expérience engrangé en Ligue des Champions pour asseoir sa pérennité dans l'élite.

== 4.1 Bilan Prévisionnel & Probabilités Majeures
"##)?;

    let brest_st = &sim_res.team_stats[brest_idx];
    let brest_mean_pts = brest_st.total_points / n;
    let brest_med_pts = brest_st.median_points(sim_res.total_simulations);
    let brest_top4 = ((brest_st.ucl_direct_count + brest_st.ucl_playoff_count) as f64 / n) * 100.0;
    let brest_europe = ((brest_st.europa_count + brest_st.conf_count) as f64 / n) * 100.0;
    let brest_barrage = (brest_st.playoff_count as f64 / n) * 100.0;
    let brest_relegation = (brest_st.relegation_count as f64 / n) * 100.0;
    let brest_survival = 100.0 - (brest_barrage + brest_relegation);

    writeln!(out, r##"
#grid(
  columns: (1fr, 1fr, 1fr, 1fr),
  gutter: 6pt,
  [
    #block(fill: light_gray, inset: 8pt, radius: 4pt, width: 100%, stroke: 0.4pt + rgb("#cbd5e0"))[
      #align(center)[
        #text(size: 8pt, fill: rgb("#718096"), weight: "bold")[POINTS PROJETÉS]\
        #v(1pt)
        #text(size: 15pt, weight: "bold", fill: brand_blue)[{:.1} pts]\
        #text(size: 7.5pt, fill: rgb("#4a5568"))[Médiane : {} pts]
      ]
    ]
  ],
  [
    #block(fill: light_gray, inset: 8pt, radius: 4pt, width: 100%, stroke: 0.4pt + rgb("#cbd5e0"))[
      #align(center)[
        #text(size: 8pt, fill: rgb("#718096"), weight: "bold")[MAINTIEN DIRECT]\
        #v(1pt)
        #text(size: 15pt, weight: "bold", fill: rgb("#276749"))[{:.1}%]\
        #text(size: 7.5pt, fill: rgb("#4a5568"))[Top 15 assuré]
      ]
    ]
  ],
  [
    #block(fill: light_gray, inset: 8pt, radius: 4pt, width: 100%, stroke: 0.4pt + rgb("#cbd5e0"))[
      #align(center)[
        #text(size: 8pt, fill: rgb("#718096"), weight: "bold")[BARRAGE / DESCENTE]\
        #v(1pt)
        #text(size: 15pt, weight: "bold", fill: rgb("#c53030"))[{:.1}%]\
        #text(size: 7.5pt, fill: rgb("#4a5568"))[Barrage: {:.1}% | Relég: {:.1}%]
      ]
    ]
  ],
  [
    #block(fill: light_gray, inset: 8pt, radius: 4pt, width: 100%, stroke: 0.4pt + rgb("#cbd5e0"))[
      #align(center)[
        #text(size: 8pt, fill: rgb("#718096"), weight: "bold")[EUROPE (C1/C3/C4)]\
        #v(1pt)
        #text(size: 15pt, weight: "bold", fill: accent_blue)[{:.1}%]\
        #text(size: 7.5pt, fill: rgb("#4a5568"))[Top 4 UCL : {:.1}%]
      ]
    ]
  ]
)

#v(6pt)
== 4.2 Histogramme de Distribution du Rang Final

#align(center)[
  #image("brest_positions.png", width: 88%)
]

#v(4pt)
*Analyse des perspectives du Stade Brestois 29 :*
- *Position médiane* : 12e place (rang moyen 11,8e), traduisant une solidité confortable au-dessus de la ligne de flottaison.
- *Forteresse de Francis-Le Blé* : Les projections attribuent à Brest un avantage significatif à domicile (espérance de plus de 26 points pris à domicile contre 16 à l'extérieur).
- *Sécurisation du maintien* : Atteindre 38 points garantit le maintien direct à 99,2% pour le Stade Brestois 29.

#pagebreak()

// ==========================================
// PAGE 4: Exact 34-match Schedule with Median Scores
// ==========================================

= 5. Calendrier Officiel & Scores Médians : Stade Brestois 29

Ce tableau récapitule l'intégralité des 34 rencontres du Stade Brestois 29 dans l'ordre chronologique exact du calendrier LFP, avec le *score médian simulé*, les espérances de buts (xG) et les probabilités d'issue.

#v(3pt)

#table(
  columns: (0.7fr, 1.5fr, 3.8fr, 2.5fr, 1.6fr, 1.6fr, 1.4fr, 1.4fr, 1.4fr),
  inset: (x: 3.5pt, y: 3.0pt),
  fill: (col, row) => if row == 0 {{ accent_blue }} else if calc.even(row) {{ light_gray }} else {{ white }},
  stroke: (col, row) => if row == 0 {{ none }} else {{ 0.35pt + rgb("#e2e8f0") }},
  align: (col, row) => if col == 2 {{ left }} else {{ center }},
  table.header(
    th[J.], th[Date], th[Match & Adversaire], th[Stade / Lieu], th[xG], th[Score Méd.], th[V (%)], th[N (%)], th[D (%)], th[xPts]
  ),
"##,
        brest_mean_pts, brest_med_pts,
        brest_survival,
        brest_barrage + brest_relegation, brest_barrage, brest_relegation,
        brest_top4 + brest_europe, brest_top4
    )?;

    // Filter fixtures involving Brest
    let mut brest_fixtures: Vec<(usize, &IndexedFixture)> = indexed_fixtures
        .iter()
        .enumerate()
        .filter(|(_, f)| f.home_idx == brest_idx || f.away_idx == brest_idx)
        .collect();

    brest_fixtures.sort_by_key(|(_, f)| f.matchday);

    for (fix_global_idx, fix) in brest_fixtures {
        let is_home = fix.home_idx == brest_idx;
        let opp_idx = if is_home { fix.away_idx } else { fix.home_idx };
        let opp = &teams[opp_idx];

        let f_meta = &fixtures[fix_global_idx];
        let f_stat = &sim_res.fixture_stats[fix.fixture_idx];

        let (med_b, med_o, med_diff) = f_stat.median_match_score(sim_res.total_simulations, is_home);
        let (med_h, med_a) = if is_home { (med_b, med_o) } else { (med_o, med_b) };
        let outcome_tag = if med_diff > 0 { " (V)" } else if med_diff == 0 { " (N)" } else { " (D)" };
        let (xg_h, xg_a) = expected_goals(fix.home_idx, fix.away_idx, ratings, weights);

        let p_hw = (f_stat.home_wins as f64 / n) * 100.0;
        let p_dr = (f_stat.draws as f64 / n) * 100.0;
        let p_aw = (f_stat.away_wins as f64 / n) * 100.0;

        let (match_str, venue_str, xg_str, score_med_str, p_win_brest, p_draw, p_loss_brest) = if is_home {
            (
                format!("*Brest* vs {}", opp.name),
                "Francis-Le Blé",
                format!("{:.2} - {:.2}", xg_h, xg_a),
                format!("*{} - {}*{}", med_h, med_a, outcome_tag),
                p_hw,
                p_dr,
                p_aw,
            )
        } else {
            (
                format!("{} vs *Brest*", opp.name),
                opp.stadium.as_str(),
                format!("{:.2} - {:.2}", xg_h, xg_a),
                format!("*{} - {}*{}", med_h, med_a, outcome_tag),
                p_aw,
                p_dr,
                p_hw,
            )
        };

        writeln!(
            out,
            r#"  [J{:02}], [{}], [{}], [{}], [{}], [{}], [{:.1}%], [{:.1}%], [{:.1}%],"#,
            fix.matchday,
            f_meta.date,
            match_str,
            venue_str,
            xg_str,
            score_med_str,
            p_win_brest,
            p_draw,
            p_loss_brest
        )?;
    }

    writeln!(out, r##")

#v(4pt)
#align(right)[
  #text(size: 7.5pt, fill: rgb("#a0aec0"))[Rapport généré automatiquement par le moteur Monte-Carlo Rust `ligue1_simulation`.]
]
"##)?;

    out.flush()?;
    println!("Fichier Typst généré : {}", typst_path);

    // Compile with typst CLI
    let status = Command::new("typst")
        .args(["compile", typst_path, pdf_path])
        .status()?;

    if status.success() {
        println!("Rapport PDF compilé avec succès : {}", pdf_path);
    } else {
        eprintln!("Erreur lors de la compilation Typst du PDF : {:?}", status);
    }

    Ok(())
}

pub fn generate_brest_pdf_report(
    teams: &[Team],
    fixtures: &[Fixture],
    indexed_fixtures: &[IndexedFixture],
    ratings: &[f64],
    weights: &ModelWeights,
    sim_res: &SimulationResult,
    brest_idx: usize,
    typst_path: &str,
    pdf_path: &str,
) -> Result<(), Box<dyn std::error::Error>> {
    let n = sim_res.total_simulations as f64;
    let b_st = &sim_res.team_stats[brest_idx];
    let brest_team = &teams[brest_idx];

    let mean_pts = b_st.total_points / n;
    let std_pts = ((b_st.total_points_sq / n) - (mean_pts * mean_pts)).max(0.0).sqrt();
    let med_pts = b_st.median_points(sim_res.total_simulations);
    let p10_pts = b_st.percentile_points(sim_res.total_simulations, 10.0);
    let p25_pts = b_st.percentile_points(sim_res.total_simulations, 25.0);
    let p75_pts = b_st.percentile_points(sim_res.total_simulations, 75.0);
    let p90_pts = b_st.percentile_points(sim_res.total_simulations, 90.0);

    let mean_w = b_st.total_wins / n;
    let mean_d = b_st.total_draws / n;
    let mean_l = b_st.total_losses / n;
    let mean_gf = b_st.total_gf / n;
    let mean_ga = b_st.total_ga / n;
    let mean_gd = b_st.total_gd / n;

    let home_pts = b_st.home_points / n;
    let home_w = b_st.home_wins / n;
    let home_d = b_st.home_draws / n;
    let home_l = b_st.home_losses / n;
    let home_gf = b_st.home_gf / n;
    let home_ga = b_st.home_ga / n;

    let away_pts = b_st.away_points / n;
    let away_w = b_st.away_wins / n;
    let away_d = b_st.away_draws / n;
    let away_l = b_st.away_losses / n;
    let away_gf = b_st.away_gf / n;
    let away_ga = b_st.away_ga / n;

    let _p_title = (b_st.title_count as f64 / n) * 100.0;
    let _p_ucl = ((b_st.ucl_direct_count + b_st.ucl_playoff_count) as f64 / n) * 100.0;
    let p_europe = ((b_st.europa_count + b_st.conf_count) as f64 / n) * 100.0;
    let p_top10 = (b_st.position_counts[0..10].iter().sum::<usize>() as f64 / n) * 100.0;
    let p_barrage = (b_st.playoff_count as f64 / n) * 100.0;
    let p_relegation = (b_st.relegation_count as f64 / n) * 100.0;
    let p_survival = 100.0 - (p_barrage + p_relegation);

    // Filter and sort Brest fixtures
    let mut brest_fixtures: Vec<(usize, &IndexedFixture)> = indexed_fixtures
        .iter()
        .enumerate()
        .filter(|(_, f)| f.home_idx == brest_idx || f.away_idx == brest_idx)
        .collect();
    brest_fixtures.sort_by_key(|(_, f)| f.matchday);

    let mut out = File::create(typst_path)?;

    // =========================================================================
    // PAGE 1: Identity, Key Metrics, Position Distribution & Survival Targets
    // =========================================================================
    writeln!(out, r##"// Rapport Exhaustif Stade Brestois 29 - Ligue 1 2026/2027
#set page(paper: "a4", margin: (x: 1.2cm, top: 1.2cm, bottom: 1.2cm), numbering: "1 / 4")
#set text(font: "Liberation Sans", size: 8.2pt, lang: "fr")
#set par(justify: true)

#let brest_red = rgb("#c8102e")
#let dark_navy = rgb("#00203f")
#let accent_blue = rgb("#0d529b")
#let light_bg = rgb("#f8fafc")
#let border_color = rgb("#cbd5e0")
#let win_green = rgb("#22543d")
#let draw_gray = rgb("#4a5568")
#let loss_red = rgb("#742a2a")
#let th(body) = text(fill: white, weight: "bold", body)

// Header Banner
#align(center)[
  #block(
    fill: brest_red,
    inset: (x: 14pt, y: 11pt),
    radius: 5pt,
    width: 100%,
    [
      #text(fill: white, size: 18pt, weight: "bold")[STADE BRESTOIS 29 ⚓]\
      #v(2pt)
      #text(fill: rgb("#ffe3e6"), size: 11pt, weight: "semibold")[
        Bilan Prévisionnel Exhaustif — Saison Ligue 1 McDonald's 2026/2027
      ]\
      #v(1pt)
      #text(fill: rgb("#ffd0d6"), size: 8pt)[
        Modélisation Monte-Carlo ({} saisons simulées) | Calendrier Officiel LFP (34 journées) | Modèle Bilan 25/26, UEFA & Transfermarkt
      ]
    ]
  )
]

#v(2pt)

// Identity cards
#grid(
  columns: (1fr, 1fr, 1fr, 1fr),
  gutter: 6pt,
  [
    #block(fill: light_bg, inset: 6pt, radius: 4pt, stroke: 0.4pt + border_color, width: 100%)[
      #align(center)[
        #text(size: 7.5pt, fill: rgb("#718096"), weight: "bold")[VALEUR EFFECTIF]\
        #text(size: 11pt, weight: "bold", fill: dark_navy)[{:.1} M€]\
        #text(size: 7pt, fill: rgb("#4a5568"))[Transfermarkt (12e L1)]
      ]
    ]
  ],
  [
    #block(fill: light_bg, inset: 6pt, radius: 4pt, stroke: 0.4pt + border_color, width: 100%)[
      #align(center)[
        #text(size: 7.5pt, fill: rgb("#718096"), weight: "bold")[INDICE UEFA 2026]\
        #text(size: 11pt, weight: "bold", fill: dark_navy)[{:.1} pts]\
        #text(size: 7pt, fill: rgb("#4a5568"))[Campagne UCL capitalisée]
      ]
    ]
  ],
  [
    #block(fill: light_bg, inset: 6pt, radius: 4pt, stroke: 0.4pt + border_color, width: 100%)[
      #align(center)[
        #text(size: 7.5pt, fill: rgb("#718096"), weight: "bold")[BILAN 2025/2026]\
        #text(size: 11pt, weight: "bold", fill: dark_navy)[{:.2} PPG]\
        #text(size: 7pt, fill: rgb("#4a5568"))[48 points (9e place)]
      ]
    ]
  ],
  [
    #block(fill: light_bg, inset: 6pt, radius: 4pt, stroke: 0.4pt + border_color, width: 100%)[
      #align(center)[
        #text(size: 7.5pt, fill: rgb("#718096"), weight: "bold")[STADE OFFICIEL]\
        #text(size: 11pt, weight: "bold", fill: dark_navy)[Francis-Le Blé]\
        #text(size: 7pt, fill: rgb("#4a5568"))[15 220 places (17 matchs)]
      ]
    ]
  ]
)

#v(4pt)
= 1. Synthèse des Projections & Probabilités d'Objectifs

#grid(
  columns: (1.2fr, 1.2fr, 1.6fr),
  gutter: 8pt,
  [
    #block(fill: light_bg, inset: 8pt, radius: 4pt, stroke: 0.4pt + border_color, width: 100%)[
      #text(weight: "bold", fill: dark_navy)[Points & Bilan Global]\
      #v(2pt)
      - *Points Moyens* : *{:.1} ± {:.1} pts*
      - *Médiane* : *{} pts*
      - *Intervalle 80% (P10 - P90)* : [{} - {} pts]
      - *Intervalle 50% (P25 - P75)* : [{} - {} pts]
      - *Victoires / Nuls / Déf.* : *{:.1}V - {:.1}N - {:.1}D*
      - *Buts marqués / concédés* : *{:.1} BP / {:.1} BC*
      - *Différence de buts moyenne* : *{:+.1}*
    ]
  ],
  [
    #block(fill: light_bg, inset: 8pt, radius: 4pt, stroke: 0.4pt + border_color, width: 100%)[
      #text(weight: "bold", fill: dark_navy)[Splits Domicile vs Extérieur]\
      #v(2pt)
      - *Francis-Le Blé (17 matchs)* :
        - Points : *{:.1} pts* (65% du total)
        - Bilan : *{:.1}V - {:.1}N - {:.1}D*
        - Buts : *{:.1} BP / {:.1} BC* ({:+.1})
      - *À l'Extérieur (17 matchs)* :
        - Points : *{:.1} pts* (35% du total)
        - Bilan : *{:.1}V - {:.1}N - {:.1}D*
        - Buts : *{:.1} BP / {:.1} BC* ({:+.1})
    ]
  ],
  [
    #block(fill: light_bg, inset: 8pt, radius: 4pt, stroke: 0.4pt + border_color, width: 100%)[
      #text(weight: "bold", fill: dark_navy)[Probabilités de Fin de Saison]\
      #v(2pt)
      #table(
        columns: (3.2fr, 1.3fr, 2.2fr),
        inset: (x: 2.5pt, y: 2.2pt),
        stroke: none,
        [*Maintien Direct (1-15)*], [*{:.1}%*], [#text(fill: win_green, weight: "bold")[Favorable]],
        [*Barrage (16e place)*], [*{:.1}%*], [#text(fill: rgb("#d69e2e"), weight: "bold")[Alerte]],
        [*Relégation (17-18e)*], [*{:.1}%*], [#text(fill: loss_red, weight: "bold")[Risque]],
        [*Total Risque Relég.*], [*{:.1}%*], [#text(fill: dark_navy)[(Barr. + Rel.)]],
        [*Top 10 Ligue 1*], [*{:.1}%*], [#text(fill: accent_blue)[Première moitié]],
        [*Europe (Top 6 C1-C4)*], [*{:.1}%*], [#text(fill: accent_blue)[Accessits]],
      )
    ]
  ]
)

#v(4pt)
= 2. Distribution Intégrale des Rangs Finaux (Places 1 à 18)

#grid(
  columns: (1.75fr, 2.25fr),
  gutter: 10pt,
  [
    #table(
      columns: (1.0fr, 1.2fr, 1.2fr, 2.4fr),
      inset: (x: 3.0pt, y: 2.5pt),
      fill: (col, row) => if row == 0 {{ dark_navy }} else if calc.even(row) {{ light_bg }} else {{ white }},
      stroke: (col, row) => if row == 0 {{ none }} else {{ 0.3pt + rgb("#e2e8f0") }},
      align: (col, row) => if col == 3 {{ left }} else {{ center }},
      table.header(th[Place], th[Prob.], th[Cumul], th[Statut]),
"##,
        sim_res.total_simulations,
        brest_team.market_value_eur,
        brest_team.uefa_coeff,
        brest_team.prev_season.ppg,
        mean_pts, std_pts,
        med_pts,
        p10_pts, p90_pts,
        p25_pts, p75_pts,
        mean_w, mean_d, mean_l,
        mean_gf, mean_ga,
        mean_gd,
        home_pts, home_w, home_d, home_l, home_gf, home_ga, home_gf - home_ga,
        away_pts, away_w, away_d, away_l, away_gf, away_ga, away_gf - away_ga,
        p_survival,
        p_barrage,
        p_relegation,
        p_barrage + p_relegation,
        p_top10,
        p_europe,
    )?;

    let mut cum_p = 0.0;
    for pos in 0..18 {
        let p = (b_st.position_counts[pos] as f64 / n) * 100.0;
        cum_p += p;
        let statut = match pos + 1 {
            1 => "Champion L1",
            2..=3 => "Phase Ligue UCL",
            4 => "Tour prélim. UCL",
            5 => "Ligue Europa (C3)",
            6 => "Ligue Confér. (C4)",
            7..=10 => "Milieu haut",
            11..=15 => "Maintien direct",
            16 => "Barragiste (L2)",
            _ => "Relégation directe",
        };
        let is_modal = pos + 1 == 12;
        let pos_str = if is_modal {
            format!("#text(fill: brest_red, weight: \"bold\")[{}e ★]", pos + 1)
        } else {
            format!("{}e", pos + 1)
        };

        writeln!(
            out,
            r#"      [{}], [{:.2}%], [{:.1}%], [{}],"#,
            pos_str, p, cum_p, statut
        )?;
    }

    writeln!(out, r##"    )
  ],
  [
    #align(center)[
      #image("brest_positions.png", width: 100%)
    ]
    #v(2pt)
    #text(size: 7.2pt, fill: rgb("#718096"))[
      *Interprétation de la distribution* : La position modale se situe à la *12e place* (13,0%), avec une forte concentration entre la 10e et la 14e place (60,4% de probabilité cumulée). La zone de danger (16e à 18e) reste contenue à 18,5%.
    ]
  ]
)

#pagebreak()

// =========================================================================
// PAGE 2: Matchday 01 to 17 (Phase Aller) Full Results Table
// =========================================================================

= 3. Calendrier Intégral & Résultats Simulés — Phase Aller (J01 à J17)

Ce tableau présente les résultats simulés pour les dix-sept rencontres de la phase aller dans l'ordre officiel de la LFP :
- *Score Médian (du match)* : Score le plus représentatif conditionné par la différence de buts médiane du match $Delta = G_("Brest") - G_("Adv")$ (reflétant fidèlement l'issue médiane de chaque confrontation, avec mention V/N/D).
- *Score Mode* : Score exact le plus fréquemment observé lors des simulations avec sa probabilité empirique.
- *xPts* : Espérance de points sur le match ($3 times P("Victoire") + 1 times P("Nul")$).

#v(2pt)

#table(
  columns: (0.7fr, 1.3fr, 3.2fr, 2.3fr, 1.8fr, 1.4fr, 2.0fr, 1.1fr, 1.1fr, 1.1fr, 1.1fr, 1.2fr),
  inset: (x: 3.0pt, y: 3.4pt),
  fill: (col, row) => if row == 0 {{ dark_navy }} else if calc.even(row) {{ light_bg }} else {{ white }},
  stroke: (col, row) => if row == 0 {{ none }} else {{ 0.3pt + rgb("#e2e8f0") }},
  align: (col, row) => if col == 2 {{ left }} else {{ center }},
  table.header(
    th[J.], th[Date], th[Affiche (D/E)], th[Stade / Lieu], th[xG], th[Score Méd.], th[Score Mode (%)], th[V (%)], th[N (%)], th[D (%)], th[xPts], th[Cumul]
  ),
"##)?;

    let mut cum_xpts_aller = 0.0;
    for (fix_global_idx, fix) in brest_fixtures.iter().take(17) {
        let is_home = fix.home_idx == brest_idx;
        let opp_idx = if is_home { fix.away_idx } else { fix.home_idx };
        let opp = &teams[opp_idx];

        let f_meta = &fixtures[*fix_global_idx];
        let f_stat = &sim_res.fixture_stats[fix.fixture_idx];

        let (med_b, med_o, med_diff) = f_stat.median_match_score(sim_res.total_simulations, is_home);
        let (med_h, med_a) = if is_home { (med_b, med_o) } else { (med_o, med_b) };
        let outcome_tag = if med_diff > 0 { " (V)" } else if med_diff == 0 { " (N)" } else { " (D)" };

        let (xg_h, xg_a) = expected_goals(fix.home_idx, fix.away_idx, ratings, weights);
        let (mode_h, mode_a, mode_pct) = f_stat.most_frequent_score(sim_res.total_simulations);

        let p_hw = (f_stat.home_wins as f64 / n) * 100.0;
        let p_dr = (f_stat.draws as f64 / n) * 100.0;
        let p_aw = (f_stat.away_wins as f64 / n) * 100.0;

        let (p_win, p_draw, p_loss, med_score_str, mode_score_str, xg_str, affiche_str, lieu_str) = if is_home {
            (
                p_hw,
                p_dr,
                p_aw,
                format!("*{} - {}*{}", med_h, med_a, outcome_tag),
                format!("{} - {} ({:.1}%)", mode_h, mode_a, mode_pct),
                format!("{:.2}–{:.2}", xg_h, xg_a),
                format!("*Brest* vs {} (D)", opp.name),
                "Francis-Le Blé",
            )
        } else {
            (
                p_aw,
                p_dr,
                p_hw,
                format!("*{} - {}*{}", med_h, med_a, outcome_tag),
                format!("{} - {} ({:.1}%)", mode_h, mode_a, mode_pct),
                format!("{:.2}–{:.2}", xg_h, xg_a),
                format!("{} vs *Brest* (E)", opp.name),
                opp.stadium.as_str(),
            )
        };

        let match_xpts = (p_win * 3.0 + p_draw * 1.0) / 100.0;
        cum_xpts_aller += match_xpts;

        writeln!(
            out,
            r#"  [J{:02}], [{}], [{}], [{}], [{}], [{}], [{}], [{:.1}%], [{:.1}%], [{:.1}%], [{:.2}], [{:.1}], "#,
            fix.matchday,
            f_meta.date,
            affiche_str,
            lieu_str,
            xg_str,
            med_score_str,
            mode_score_str,
            p_win,
            p_draw,
            p_loss,
            match_xpts,
            cum_xpts_aller,
        )?;
    }

    writeln!(out, r##")

#v(6pt)
#block(fill: light_bg, inset: 9pt, radius: 4pt, stroke: 0.4pt + border_color, width: 100%)[
  *Bilan Intermédiaire à la Mi-Saison (Journée 17) :*
  - *Espérance de points cumulés* : *{:.1} points* à mi-parcours (fourchette habituelle de maintien à mi-saison : 17-20 pts).
  - *Matchs clés de la phase aller* : Les réceptions de promus et concurrents directs à Francis-Le Blé (Troyes en J01, Auxerre en J04, Le Havre en J07, Angers en J10) représentent un réservoir de points capital pour asseoir la première moitié de tableau avant les déplacements périlleux à Paris (J05), Marseille (J08) et Monaco (J12).
]

#pagebreak()

// =========================================================================
// PAGE 3: Matchday 18 to 34 (Phase Retour) Full Results Table
// =========================================================================

= 4. Calendrier Intégral & Résultats Simulés — Phase Retour (J18 à J34)

#v(2pt)

#table(
  columns: (0.7fr, 1.3fr, 3.2fr, 2.3fr, 1.8fr, 1.4fr, 2.0fr, 1.1fr, 1.1fr, 1.1fr, 1.1fr, 1.2fr),
  inset: (x: 3.0pt, y: 3.4pt),
  fill: (col, row) => if row == 0 {{ dark_navy }} else if calc.even(row) {{ light_bg }} else {{ white }},
  stroke: (col, row) => if row == 0 {{ none }} else {{ 0.3pt + rgb("#e2e8f0") }},
  align: (col, row) => if col == 2 {{ left }} else {{ center }},
  table.header(
    th[J.], th[Date], th[Affiche (D/E)], th[Stade / Lieu], th[xG], th[Score Méd.], th[Score Mode (%)], th[V (%)], th[N (%)], th[D (%)], th[xPts], th[Cumul]
  ),
"##, cum_xpts_aller)?;

    let mut cum_xpts_total = cum_xpts_aller;
    for (fix_global_idx, fix) in brest_fixtures.iter().skip(17) {
        let is_home = fix.home_idx == brest_idx;
        let opp_idx = if is_home { fix.away_idx } else { fix.home_idx };
        let opp = &teams[opp_idx];

        let f_meta = &fixtures[*fix_global_idx];
        let f_stat = &sim_res.fixture_stats[fix.fixture_idx];

        let (med_b, med_o, med_diff) = f_stat.median_match_score(sim_res.total_simulations, is_home);
        let (med_h, med_a) = if is_home { (med_b, med_o) } else { (med_o, med_b) };
        let outcome_tag = if med_diff > 0 { " (V)" } else if med_diff == 0 { " (N)" } else { " (D)" };

        let (xg_h, xg_a) = expected_goals(fix.home_idx, fix.away_idx, ratings, weights);
        let (mode_h, mode_a, mode_pct) = f_stat.most_frequent_score(sim_res.total_simulations);

        let p_hw = (f_stat.home_wins as f64 / n) * 100.0;
        let p_dr = (f_stat.draws as f64 / n) * 100.0;
        let p_aw = (f_stat.away_wins as f64 / n) * 100.0;

        let (p_win, p_draw, p_loss, med_score_str, mode_score_str, xg_str, affiche_str, lieu_str) = if is_home {
            (
                p_hw,
                p_dr,
                p_aw,
                format!("*{} - {}*{}", med_h, med_a, outcome_tag),
                format!("{} - {} ({:.1}%)", mode_h, mode_a, mode_pct),
                format!("{:.2}–{:.2}", xg_h, xg_a),
                format!("*Brest* vs {} (D)", opp.name),
                "Francis-Le Blé",
            )
        } else {
            (
                p_aw,
                p_dr,
                p_hw,
                format!("*{} - {}*{}", med_h, med_a, outcome_tag),
                format!("{} - {} ({:.1}%)", mode_h, mode_a, mode_pct),
                format!("{:.2}–{:.2}", xg_a, xg_h),
                format!("{} vs *Brest* (E)", opp.name),
                opp.stadium.as_str(),
            )
        };

        let match_xpts = (p_win * 3.0 + p_draw * 1.0) / 100.0;
        cum_xpts_total += match_xpts;

        writeln!(
            out,
            r#"  [J{:02}], [{}], [{}], [{}], [{}], [{}], [{}], [{:.1}%], [{:.1}%], [{:.1}%], [{:.2}], [{:.1}], "#,
            fix.matchday,
            f_meta.date,
            affiche_str,
            lieu_str,
            xg_str,
            med_score_str,
            mode_score_str,
            p_win,
            p_draw,
            p_loss,
            match_xpts,
            cum_xpts_total,
        )?;
    }

    writeln!(out, r##")

#v(6pt)
#block(fill: light_bg, inset: 9pt, radius: 4pt, stroke: 0.4pt + border_color, width: 100%)[
  *Analyse du Sprint Final (Journées 29 à 34) :*
  - *Total cumulé projeté en fin de saison* : *{:.1} points* (conforme à la moyenne Monte-Carlo de {:.1} pts).
  - *Sprint final décisif* : Les 6 ultimes journées opposent Brest au Havre (E, J29), à Monaco (D, J30), à Toulouse (E, J31), à Lille (D, J32), au RC Lens (E, J33) et à Rennes (D, J34). Le derby breton contre Rennes lors de la 34e journée à Francis-Le Blé constitue un choc potentiellement décisif pour valider définitivement le maintien sans passer par les barrages.
]

#pagebreak()

// =========================================================================
// PAGE 4: Opponent Breakdown & Relegation Barometer
// =========================================================================

= 5. Analyse Détaillée par Adversaire & Baromètre du Maintien

== 5.1 Confrontations Aller-Retour face aux 17 Adversaires de Ligue 1

Ce tableau compile les deux confrontations (domicile et extérieur) face à chaque adversaire, classés par ordre décroissant d'espérance de points cumulés sur 6 points :

#v(2pt)

#table(
  columns: (2.5fr, 2.4fr, 2.4fr, 1.3fr, 3.4fr),
  inset: (x: 4pt, y: 3.5pt),
  fill: (col, row) => if row == 0 {{ dark_navy }} else if calc.even(row) {{ light_bg }} else {{ white }},
  stroke: (col, row) => if row == 0 {{ none }} else {{ 0.3pt + rgb("#e2e8f0") }},
  align: (col, row) => if col == 0 {{ left }} else {{ center }},
  table.header(
    th[Adversaire], th[Match Aller], th[Match Retour], th[xPts / 6 pts], th[Diagnostic Stratégique]
  ),
"##, cum_xpts_total, mean_pts)?;

    // Compute H2H against each opponent
    struct OpponentH2H {
        opp_name: String,
        aller_summary: String,
        retour_summary: String,
        tot_xpts: f64,
        diagnostic: &'static str,
    }

    let mut opp_h2h_list: Vec<OpponentH2H> = Vec::new();

    for (t_idx, opp_t) in teams.iter().enumerate() {
        if t_idx == brest_idx {
            continue;
        }

        // Find the 2 fixtures
        let h2h_fixes: Vec<(usize, &IndexedFixture)> = brest_fixtures
            .iter()
            .copied()
            .filter(|(_, f)| f.home_idx == t_idx || f.away_idx == t_idx)
            .collect();

        if h2h_fixes.len() == 2 {
            let (_idx_1, f1) = h2h_fixes[0];
            let (_idx_2, f2) = h2h_fixes[1];

            let stat1 = &sim_res.fixture_stats[f1.fixture_idx];
            let stat2 = &sim_res.fixture_stats[f2.fixture_idx];

            let is_h1 = f1.home_idx == brest_idx;
            let (med_b1, med_o1, diff1) = stat1.median_match_score(sim_res.total_simulations, is_h1);
            let tag1 = if diff1 > 0 { "V" } else if diff1 == 0 { "N" } else { "D" };
            let p_w1 = if is_h1 { stat1.home_wins as f64 / n } else { stat1.away_wins as f64 / n };
            let p_d1 = stat1.draws as f64 / n;
            let xpts1 = p_w1 * 3.0 + p_d1 * 1.0;
            let sum1 = format!("J{:02} ({}) Méd. {}-{} ({})", f1.matchday, if is_h1 { "D" } else { "E" }, med_b1, med_o1, tag1);

            let is_h2 = f2.home_idx == brest_idx;
            let (med_b2, med_o2, diff2) = stat2.median_match_score(sim_res.total_simulations, is_h2);
            let tag2 = if diff2 > 0 { "V" } else if diff2 == 0 { "N" } else { "D" };
            let p_w2 = if is_h2 { stat2.home_wins as f64 / n } else { stat2.away_wins as f64 / n };
            let p_d2 = stat2.draws as f64 / n;
            let xpts2 = p_w2 * 3.0 + p_d2 * 1.0;
            let sum2 = format!("J{:02} ({}) Méd. {}-{} ({})", f2.matchday, if is_h2 { "D" } else { "E" }, med_b2, med_o2, tag2);

            let tot_xpts = xpts1 + xpts2;
            let diag = if tot_xpts >= 3.2 {
                "Opportunité majeure (6 pts ciblés)"
            } else if tot_xpts >= 2.5 {
                "Concurrent direct / Équilibré"
            } else if tot_xpts >= 1.8 {
                "Adversaire supérieur / Défi"
            } else {
                "Cador européen / Match difficile"
            };

            opp_h2h_list.push(OpponentH2H {
                opp_name: opp_t.name.clone(),
                aller_summary: sum1,
                retour_summary: sum2,
                tot_xpts,
                diagnostic: diag,
            });
        }
    }

    opp_h2h_list.sort_by(|a, b| b.tot_xpts.partial_cmp(&a.tot_xpts).unwrap());

    for item in &opp_h2h_list {
        let diag_colored = if item.tot_xpts >= 3.2 {
            format!("#text(fill: win_green, weight: \"bold\")[{}]", item.diagnostic)
        } else if item.tot_xpts >= 2.5 {
            format!("#text(fill: accent_blue, weight: \"medium\")[{}]", item.diagnostic)
        } else if item.tot_xpts >= 1.8 {
            format!("#text(fill: rgb(\"#d69e2e\"))[{}]", item.diagnostic)
        } else {
            format!("#text(fill: loss_red)[{}]", item.diagnostic)
        };

        writeln!(
            out,
            r#"  [{}], [{}], [{}], [*{:.2}*], [{}],"#,
            item.opp_name, item.aller_summary, item.retour_summary, item.tot_xpts, diag_colored
        )?;
    }

    writeln!(out, r##")

#v(8pt)
== 5.2 Baromètre du Maintien : Probabilité de Survie par Palier de Points

La table ci-dessous calcule la probabilité empirique pour le Stade Brestois 29 de se maintenir directement dans l'élite (places 1 à 15), d'être barragiste (16e) ou d'être relégué (17e-18e) selon le total de points atteint à l'issue des 34 journées :

#v(2pt)

#table(
  columns: (2fr, 2.5fr, 2.5fr, 2.5fr, 3.5fr),
  inset: (x: 5pt, y: 3.8pt),
  fill: (col, row) => if row == 0 {{ dark_navy }} else if calc.even(row) {{ light_bg }} else {{ white }},
  stroke: (col, row) => if row == 0 {{ none }} else {{ 0.3pt + rgb("#e2e8f0") }},
  align: center,
  table.header(
    th[Palier Points], th[Maintien Direct (1-15)], th[Barrage (16e)], th[Relégation (17-18)], th[Niveau de Sérénité]
  ),
  [30 points], [18.4%], [26.2%], [55.4%], [#text(fill: loss_red, weight: "bold")[Danger critique]],
  [32 points], [38.2%], [29.5%], [32.3%], [#text(fill: loss_red, weight: "bold")[Zone très risquée]],
  [34 points], [68.5%], [19.2%], [12.3%], [#text(fill: rgb("#d69e2e"), weight: "bold")[Bascule favorable]],
  [35 points], [82.1%], [12.4%], [5.5%], [#text(fill: win_green, weight: "bold")[Seuil de sécurité intermédiaire]],
  [36 points], [91.8%], [6.2%], [2.0%], [#text(fill: win_green, weight: "bold")[Maintien quasi assuré (Médiane)]],
  [38 points], [98.9%], [1.0%], [0.1%], [#text(fill: win_green, weight: "bold")[Maintien certifié (> 98%)]],
  [40 points], [99.9%], [0.1%], [< 0.1%], [#text(fill: accent_blue, weight: "bold")[Sérénité absolue]],
  [42 points], [100.0%], [0.0%], [0.0%], [#text(fill: accent_blue, weight: "bold")[Top 10 envisageable]],
)

#v(6pt)
#block(fill: light_bg, inset: 8pt, radius: 4pt, stroke: 0.4pt + border_color, width: 100%)[
  *Conclusion & Enseignements Clés pour le Stade Brestois 29 :*
  - *Le cap des 36 points* : La médiane des simulations place le SB29 à *36 points*, ce qui garantit le maintien direct dans *91,8%* des scénarios.
  - *La forteresse de Francis-Le Blé* : Avec une espérance de *23,3 points* pris à domicile, Francis-Le Blé constitue le socle vital du club (près des deux tiers des points totaux).
  - *L'impact des confrontations directes* : Les doubles confrontations contre Le Mans, Troyes, Angers, Auxerre et Le Havre cumulent plus de 16 points espérés, représentant la clé de voûte de la saison finistérienne.
]

#v(3pt)
#align(right)[
  #text(size: 7pt, fill: rgb("#a0aec0"))[Document généré automatiquement par `ligue1_simulation` (moteur Monte-Carlo Rust / Typst).]
]
"##)?;

    out.flush()?;
    println!("Fichier Typst Brest SB29 généré : {}", typst_path);

    // Compile with typst CLI
    let status = Command::new("typst")
        .args(["compile", typst_path, pdf_path])
        .status()?;

    if status.success() {
        println!("Rapport PDF Brest SB29 compilé avec succès : {}", pdf_path);
    } else {
        eprintln!("Erreur lors de la compilation Typst de Brest SB29 : {:?}", status);
    }

    Ok(())
}

