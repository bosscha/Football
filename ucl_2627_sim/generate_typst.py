import csv

with open('ucl_2627_standings_1M.csv') as f:
    rows = list(csv.DictReader(f))

with open('ucl_2627_summary.typ', 'w') as f:
    f.write('''#set document(
  title: [UEFA Champions League 2026/27 - Simulation Report & Case Studies],
  author: ("Stéphane Leon", "Gemini")
)
#set page(
  paper: "a4",
  margin: (x: 1.5cm, top: 1.4cm, bottom: 1.4cm),
  header: context {
    if counter(page).get().first() > 1 [
      #text(size: 8pt, fill: rgb("#718096"))[
        UEFA Champions League 2026/27 — 1,000,000 Monte Carlo Simulations & Case Studies
        #h(1fr)
        Stéphane Leon & Gemini • September 2026
      ]
      #v(-4pt)
      #line(length: 100%, stroke: 0.5pt + rgb("#cbd5e0"))
    ]
  },
  footer: context [
    #line(length: 100%, stroke: 0.5pt + rgb("#cbd5e0"))
    #v(-2pt)
    #text(size: 8pt, fill: rgb("#718096"))[
      Simulation Study based on Official UEFA Fixtures, Rankings & Squad Values
      #h(1fr)
      Page #counter(page).display() of 5
    ]
  ]
)

#set text(font: "Liberation Sans", size: 8.7pt)
#set par(justify: true, leading: 0.50em)

// Title Block
#align(center)[
  #text(size: 19pt, weight: "bold", fill: rgb("#1a365d"))[UEFA Champions League 2026/27]
  #v(-4pt)
  #text(size: 12.5pt, weight: "medium", fill: rgb("#2b6cb0"))[League Phase Simulation & Probabilistic Classification]
  #v(-4pt)
  #text(size: 8.2pt, fill: rgb("#4a5568"))[
    *A 1,000,000 Monte Carlo Simulation Study based on Real Fixtures, UEFA Rankings, Transfermarkt Valuations, and YTD Form*
  ]
  #v(2pt)
  #text(size: 9pt, weight: "bold", fill: rgb("#2d3748"))[
    Authors: Stéphane Leon & Gemini (Google DeepMind)
  ]
  #v(2pt)
  #line(length: 100%, stroke: 1.2pt + rgb("#2b6cb0"))
]

#v(0.04cm)

== 1. Executive Summary

Following the official league phase draw in late August 2026, all *36 qualified clubs* enter a unified single-table league playing *8 matches* (4 home, 4 away; 144 fixtures total). Each club faces exactly 2 opponents from each of the 4 seeding pots. 

To forecast final standings, quantify qualification likelihoods, and examine specific national contingents, we implemented a high-performance simulation engine in Rust. We executed *1,000,000 complete seasons* (144,000,000 individual matches) in *7.88 seconds* (~18.3M matches/sec). The simulation fuses each team's *2026 UEFA coefficient*, *Transfermarkt squad valuation*, and *2026 year-to-date (YTD) performance form*.

#v(0.04cm)
#grid(
  columns: (1fr, 1fr),
  gutter: 1.2cm,
  [
    #block(fill: rgb("#f0fff4"), inset: 6.5pt, radius: 4pt, stroke: 0.5pt + rgb("#38a169"))[
      *Top 8 Cutoff (Direct Round of 16 Bye)* \\
      - *Expected threshold*: *15.66 points*
      - *Median (50%)*: *16 points*
      - *Safe threshold (90%)*: *17 points* (or 16 pts with $+6$ GD)
      - Clubs reaching 16 pts have an *82.4%* chance of a top-8 finish.
    ]
  ],
  [
    #block(fill: rgb("#ebf8ff"), inset: 6.5pt, radius: 4pt, stroke: 0.5pt + rgb("#3182ce"))[
      *Top 24 Cutoff (Knockout Play-offs)* \\
      - *Expected threshold*: *9.02 points*
      - *Median (50%)*: *9 points*
      - *Safe threshold (90%)*: *10 points* (or 9 pts with $0$ GD)
      - Clubs with 10 pts qualify for play-offs in *95.8%* of simulations.
    ]
  ]
)

#v(0.04cm)

== 2. Methodology & Mathematical Modeling

=== Composite Team Power Rating
For each club $i$, a normalized strength index $R_i in [0, 1]$ is constructed by fusing three distinct dimensions:
$ R_i = w_u S_(u,i) + w_m S_(m,i) + w_y S_(y,i) $
- *UEFA Club Coefficient ($w_u = 0.25$)*: Reflects 5-year continental competition pedigree, normalized linearly across the field ($6.000$ for Sabah to $147.500$ for Bayern Munich).
- *Transfermarkt Squad Market Value ($w_m = 0.50$)*: Log-normalized ($ln(M V_i)$) to reflect diminishing returns on financial talent. Valuations range from €18.35M to €1,460M.
- *Year-To-Date (YTD) Performance ($w_y = 0.25$)*: Synthesizes early 2026/27 domestic league form and qualifying results through Points-Per-Game ($P P G$), win rate, and goal differential per match.

=== Match Goal Expectancies & Poisson Sampling
For each fixture between Home club $H$ and Away club $A$, expected goal parameters $lambda_H$ and $lambda_A$ are calculated as:
$ lambda_H = max(0.10, mu_0 exp(gamma + beta (R_H - R_A))), quad lambda_A = max(0.10, mu_0 exp(-beta (R_H - R_A))) $
where $mu_0 = 1.35$ goals, $gamma = 0.25$ (home advantage bonus), and $beta = 1.25$ (calibrated rating sensitivity). Goals scored are sampled from independent Poisson distributions: $G_H tilde.op "Poisson"(lambda_H)$ and $G_A tilde.op "Poisson"(lambda_A)$.

=== Official UEFA Tiebreaker Hierarchy
Standings are resolved strictly under UEFA Champions League regulations: (1) Total Points, (2) Superior Goal Difference, (3) Higher Goals Scored, (4) Away Goals Scored, (5) Total Wins, (6) Total Away Wins, and (7) UEFA Club Coefficient.

#pagebreak()

== 3. Complete League Phase Classification (1,000,000 Simulations)

#v(-5pt)
#text(size: 7.8pt, fill: rgb("#4a5568"))[
  Sorted by expected finishing position (*Mean Pos*). Green: Top 8 (Round of 16 Bye); Blue: 9–24 (Play-offs); Red: 25–36 (Elimination).
]
#v(-3pt)

#align(center)[
#table(
  columns: (20pt, 125pt, 22pt, 24pt, 42pt, 45pt, 48pt, 36pt, 40pt, 42pt, 38pt),
  stroke: (x, y) => if y == 0 { 1pt + rgb("#2b6cb0") } else { 0.4pt + rgb("#e2e8f0") },
  fill: (col, row) => {
    if row == 0 { rgb("#edf2f7") }
    else if row <= 8 { rgb("#f0fff4") }
    else if row <= 24 { rgb("#ebf8ff") }
    else { rgb("#fff5f5") }
  },
  inset: (x: 3pt, y: 3.0pt),
  align: (col, row) => (
    if col == 1 { left }
    else if col in (0, 2, 3) { center }
    else { right }
  ),
  table.header(
    [*Rk*], [*Team*], [*Pot*], [*Nat*], [*Coeff*], [*Value*], [*Exp Pts*], [*GD*], [*Top 8*], [*Play-off*], [*Elim.*]
  ),
''')

    for r in rows:
        rk = r['Rank']
        name = r['Team']
        pot = r['Pot']
        nat = r['Country']
        coeff = f"{float(r['UEFA_Coeff']):.1f}"
        val = f"€{float(r['MarketValue_M_Eur']):.0f}M"
        pts = f"{float(r['Exp_Points']):.1f}"
        gd = f"{float(r['Exp_GD']):+.1f}"
        t8 = f"{float(r['Top8_Pct']):.1f}%"
        po = f"{float(r['Playoff_Pct']):.1f}%"
        el = f"{float(r['Eliminated_Pct']):.1f}%"
        f.write(f"  [{rk}], [{name}], [{pot}], [{nat}], [{coeff}], [{val}], [{pts}], [{gd}], [{t8}], [{po}], [{el}],\n")

    f.write('''
)
]

#pagebreak()

== 4. Case Studies: The French Contingent (PSG, Lille, Lens)

France is represented by three clubs across three distinct seeding pots in the 2026/27 campaign. Their simulation results reflect divergent tournament trajectories:

#v(0.1cm)

#grid(
  columns: (1fr, 1fr, 1fr),
  gutter: 0.8cm,
  [
    #block(fill: rgb("#ebf8ff"), inset: 6pt, radius: 4pt, stroke: 0.5pt + rgb("#3182ce"))[
      *Paris Saint-Germain (Pot 1)* \\
      #text(size: 8pt)[
        - *Squad Value*: €1,360M | *Coeff*: 132.0
        - *Exp Points*: *16.9 ±2.6* (GD: +10.8)
        - *Top 8 (R16 Bye)*: *70.3%*
        - *Play-offs (9–24)*: *28.9%*
        - *Elimination*: *0.8%* (Mean Pos: 6.8)
        - *Home*: Slovan, Barça, Roma, Gala
        - *Away*: Man City, Villarreal, Villa, Como
      ]
    ]
  ],
  [
    #block(fill: rgb("#fffaf0"), inset: 6pt, radius: 4pt, stroke: 0.5pt + rgb("#dd6b20"))[
      *Lille OSC (Pot 3)* \\
      #text(size: 8pt)[
        - *Squad Value*: €245M | *Coeff*: 68.8
        - *Exp Points*: *9.8 ±3.3* (GD: -2.4)
        - *Top 8 (R16 Bye)*: *5.2%*
        - *Play-offs (9–24)*: *55.4%*
        - *Elimination*: *39.5%* (Mean Pos: 21.7)
        - *Home*: Betis, Gala, Bayern, Slovan
        - *Away*: Arsenal, Bodø, Stuttgart, Roma
      ]
    ]
  ],
  [
    #block(fill: rgb("#fff5f5"), inset: 6pt, radius: 4pt, stroke: 0.5pt + rgb("#e53e3e"))[
      *RC Lens (Pot 4)* \\
      #text(size: 8pt)[
        - *Squad Value*: €203M | *Coeff*: 16.7
        - *Exp Points*: *7.1 ±3.2* (GD: -7.4)
        - *Top 8 (R16 Bye)*: *0.8%*
        - *Play-offs (9–24)*: *27.8%*
        - *Elimination*: *71.4%* (Mean Pos: 27.4)
        - *Home*: Sporting, Como, Bodø, Man City
        - *Away*: Slavia, Brugge, Leipzig, Liverpool
      ]
    ]
  ]
)

#v(0.1cm)

=== Analytical Breakdown for French Clubs
1. *Paris Saint-Germain (Expected Rank: 4th)*: PSG boasts the 4th highest expected points total in the competition. With favorable home matchups against Slovan Bratislava, Galatasaray, and Roma, PSG commands a *70.3% probability* of qualifying directly for the Round of 16. Their major roadblocks are high-stakes trips to Manchester City (MD2) and home against Barcelona (MD3).
2. *Lille OSC (Expected Rank: 22nd)*: Positioned right on the qualification bubble, Lille has a *55.4% chance* of reaching the Knockout Play-offs. Crucially, Lille must maximize points at Stade Pierre-Mauroy against Betis and Slovan Bratislava to offset grueling trips to the Emirates (Arsenal) and the Arctic Circle (Bodø/Glimt).
3. *RC Lens (Expected Rank: 31st)*: Facing an uphill battle from Pot 4, Lens must overcome severe schedule headwinds (hosting Manchester City and traveling to Anfield and Leipzig). Their realistic qualification path requires taking 7–9 points from matches against Como, Slavia Prague, Club Brugge, and Bodø/Glimt.

#align(center)[
  #image("french_teams_distribution.png", width: 94%)
]

#pagebreak()

== 5. Case Studies: The Spanish Contingent (5 Qualified Clubs)

Spain enters the 2026/27 Champions League with *5 qualified clubs* spanning Pots 1, 2, and 3, representing both continental heavyweight title contenders and fierce play-off bubble battles:

#v(0.1cm)

#align(center)[
#table(
  columns: (22pt, 82pt, 24pt, 42pt, 45pt, 40pt, 36pt, 42pt, 45pt, 40pt, 36pt),
  stroke: (x, y) => if y == 0 { 1pt + rgb("#2b6cb0") } else { 0.4pt + rgb("#e2e8f0") },
  fill: (col, row) => {
    if row == 0 { rgb("#edf2f7") }
    else if row in (1, 2) { rgb("#f0fff4") }
    else if row == 3 { rgb("#ebf8ff") }
    else { rgb("#fffaf0") }
  },
  inset: (x: 3pt, y: 2.8pt),
  align: (col, row) => (
    if col == 1 { left }
    else if col in (0, 2) { center }
    else { right }
  ),
  table.header(
    [*Rk*], [*Club*], [*Pot*], [*Value*], [*Coeff*], [*Exp Pts*], [*GD*], [*Top 8*], [*Play-off*], [*Elim.*], [*Mean*]
  ),
  [2], [Real Madrid], [1], [€1,460M], [144.5], [17.5], [+12.5], [76.9%], [22.7%], [0.4%], [5.8],
  [6], [FC Barcelona], [1], [€1,260M], [113.2], [16.3], [+10.1], [63.1%], [35.9%], [1.0%], [7.8],
  [13], [Atlético Madrid], [1], [€681M], [104.8], [12.9], [+3.2], [23.3%], [65.2%], [11.6%], [14.7],
  [26], [Villarreal CF], [3], [€332M], [59.0], [9.0], [-3.6], [2.9%], [48.1%], [49.0%], [23.4],
  [29], [Real Betis], [2], [€255M], [74.5], [8.8], [-4.3], [2.8%], [45.1%], [52.1%], [24.0],
)
]

#v(0.05cm)

=== Strategic Dynamics Across the Spanish Field
1. *Real Madrid (Projected 2nd, 76.9% Top 8)*: Enjoying the strongest home schedule among Pot 1 teams (Inter, Leipzig, PSV, LASK), Madrid holds a *16.1% probability of finishing 1st overall*. Away trips to Arsenal and Roma represent their main tests.
2. *FC Barcelona (Projected 6th, 63.1% Top 8)*: Spearheaded by high domestic form (2.75 PPG), Barça faces marquee clashes away at PSG (MD3) and home to Manchester City (MD6), comfortably tracking for direct Round of 16 qualification.
3. *Atlético Madrid (Projected 13th, 65.2% Play-offs)*: Despite Pot 1 status, Simeone's side drew one of the most demanding schedules in Europe: hosting Bayern Munich and Man United while traveling to Anfield (Liverpool) and Philips Stadion (PSV). Consequently, their most probable destination is seeded Knockout Play-offs.
4. *Villarreal CF & Real Betis (Projected 26th & 29th)*: Both reside directly on the 24th cutoff line (*48.1%* and *45.1%* play-offs qualification likelihood respectively). Betis faces extreme road tests at Bayern Munich and Dortmund, while Villarreal hosts PSG and travels to Liverpool. For both, advancing requires seizing points from fellow bubble contenders.

#v(0.05cm)
#align(center)[
  #image("spanish_teams_distribution.png", width: 94%)
]

#pagebreak()

== 6. Case Studies: The Italian Contingent (Inter, Napoli, Roma, Como)

Italy is represented by *4 clubs* across all four seeding pots (Pots 1 to 4). Italian clubs occupy pivotal strategic thresholds, spanning the direct Round of 16 cutoff to the play-off battleground:

#v(0.1cm)

#align(center)[
#table(
  columns: (22pt, 82pt, 24pt, 42pt, 45pt, 40pt, 36pt, 42pt, 45pt, 40pt, 36pt),
  stroke: (x, y) => if y == 0 { 1pt + rgb("#2b6cb0") } else { 0.4pt + rgb("#e2e8f0") },
  fill: (col, row) => {
    if row == 0 { rgb("#edf2f7") }
    else if row == 1 { rgb("#f0fff4") }
    else if row in (2, 3) { rgb("#ebf8ff") }
    else { rgb("#fffaf0") }
  },
  inset: (x: 3pt, y: 2.8pt),
  align: (col, row) => (
    if col == 1 { left }
    else if col in (0, 2) { center }
    else { right }
  ),
  table.header(
    [*Rk*], [*Club*], [*Pot*], [*Value*], [*Coeff*], [*Exp Pts*], [*GD*], [*Top 8*], [*Play-off*], [*Elim.*], [*Mean*]
  ),
  [8], [Inter Milan], [1], [€730M], [127.0], [15.3], [+7.3], [50.1%], [47.1%], [2.8%], [9.7],
  [14], [SSC Napoli], [3], [€433M], [63.0], [12.0], [+1.4], [14.9%], [68.6%], [16.5%], [16.6],
  [19], [AS Roma], [2], [€485M], [97.8], [11.1], [-0.2], [10.1%], [64.2%], [25.7%], [18.8],
  [30], [Como 1907], [4], [€537M], [20.0], [8.1], [-5.7], [1.6%], [38.0%], [60.4%], [25.5],
)
]

#v(0.05cm)

=== Strategic Dynamics Across the Italian Field
1. *Inter Milan (Projected 8th, 50.1% Top 8)*: Inter sits exactly on the knife-edge of direct Round of 16 qualification. An opening fixture away to Real Madrid (MD1) and hosting Liverpool (MD7) are counterbalanced by high-expectancy home ties against Brugge, Shakhtar, and Stuttgart.
2. *SSC Napoli (Projected 14th, 68.6% Play-offs)*: Antonio Conte's side enjoys the highest play-off certainty among Italian clubs (68.6%). Anchored by home matches against Bodø/Glimt, Brugge, and Viking, Napoli must navigate away fixtures at Manchester City, Porto, and Villarreal.
3. *AS Roma (Projected 19th, 64.2% Play-offs)*: Roma faces a challenging Pot 2 slate: hosting Real Madrid and visiting Paris Saint-Germain and Manchester United. A top-24 finish will hinge on converting home matches against Slovan Bratislava and Lille.
4. *Como 1907 (Projected 30th, 38.0% Play-offs)*: An ambitious Pot 4 newcomer boasting an impressive €537M squad valuation, Como faces an unforgiving schedule (hosting PSG, Man United, and Leipzig; visiting Barcelona and Betis). Despite a 60.4% elimination likelihood, Como possesses significant upset potential to crash the play-off bubble (38.0%).

#v(0.05cm)
#align(center)[
  #image("italian_teams_distribution.png", width: 94%)
]

#v(-0.25cm)

== 7. Technical Implementation & Reproducibility

```bash
# Run 1,000,000 simulations and export CSV
./target/release/ucl_2627_sim --simulations 1000000 --csv ucl_2627_standings_1M.csv

# Target Italian clubs for histogram distribution and PNG plots
./target/release/ucl_2627_sim -n 100000 --target-team "Inter Milan" --plot inter_dist.png
./target/release/ucl_2627_sim -n 100000 --target-team "Como" --plot como_dist.png
```
''')
print('generate_typst.py wrote expanded 5-page ucl_2627_summary.typ')
