#set document(
  title: [UEFA Champions League 2026/27 - Calendrier & Scores Médians des 144 Matchs],
  author: ("Stéphane Leon", "Gemini")
)
#set page(
  paper: "a4",
  margin: (x: 1.3cm, top: 1.2cm, bottom: 1.2cm),
  header: context {
    if counter(page).get().first() > 1 [
      #text(size: 8pt, fill: rgb("#718096"))[
        UEFA Champions League 2026/27 — Calendrier Officiel & Scores Médians des 144 Matchs
        #h(1fr)
        Stéphane Leon & Gemini • Septembre 2026
      ]
      #v(-4pt)
      #line(length: 100%, stroke: 0.5pt + rgb("#cbd5e0"))
    ]
  },
  footer: context [
    #line(length: 100%, stroke: 0.5pt + rgb("#cbd5e0"))
    #v(-2pt)
    #text(size: 7.5pt, fill: rgb("#718096"))[
      Équipes françaises (Paris SG, Lille OSC, RC Lens) et FC Barcelone en gras • Modèle de Poisson calibré
      #h(1fr)
      Page #counter(page).display() of 5
    ]
  ]
)

#set text(font: "Liberation Sans", size: 8.2pt)
#set par(justify: true, leading: 0.44em)

// En-tête Page 1
#align(center)[
  #text(size: 17pt, weight: "bold", fill: rgb("#1a365d"))[UEFA Champions League 2026/27]
  #v(-4pt)
  #text(size: 11.5pt, weight: "medium", fill: rgb("#2b6cb0"))[Calendrier Officiel des 144 Matchs & Prévisions des Scores Médians]
  #v(-4pt)
  #text(size: 8pt, fill: rgb("#4a5568"))[
    *Simulations probabilistes issues du modèle calibré (Classement UEFA 2026, Valeur Transfermarkt & Forme YTD)*
  ]
  #v(2pt)
  #text(size: 8.5pt, weight: "bold", fill: rgb("#2d3748"))[
    Auteurs : Stéphane Leon & Gemini (Google DeepMind)
  ]
  #v(2pt)
  #line(length: 100%, stroke: 1.2pt + rgb("#2b6cb0"))
]

#v(0.01cm)

== 1. Présentation & Guide de Lecture

Ce document présente l'intégralité des *144 matchs officiels* de la phase de ligue de la Ligue des Champions UEFA 2026/27 (8 journées de 18 rencontres). Chaque club dispute 8 matchs (4 à domicile, 4 à l'extérieur) face à 2 adversaires de chaque chapeau.

=== Définitions des Métriques Affichées :
- *Score Médian ($M_H - M_A$)* : La médiane de la distribution des buts simulés pour chaque équipe sur 100 000 tirages Poisson. Il traduit le score pivot le plus représentatif.
- *Espérance de Buts ($x G$)* : Le nombre moyen de buts attendus ($lambda_H - lambda_A$) calculé selon les forces relatives et l'avantage du terrain (+0,25).
- *Probabilités 1 / N / 2* : Les probabilités en pourcentage de Victoire Domicile ($1$), Match Nul ($N$), et Victoire Extérieure ($2$).
- *Mise en Évidence Spéciale* : Conformément à votre demande, les équipes françaises (*Paris Saint-Germain*, *Lille OSC*, *RC Lens*) ainsi que le *FC Barcelone* sont mis en *gras*.

#v(0.02cm)

== 2. Focus : Calendrier & Scores Médians des Clubs Français et du FC Barcelone

Ce tableau synthétise les *31 affiches phares* impliquant les 3 clubs français et le FC Barcelone :

#v(0.02cm)
#align(center)[
#table(
  columns: (26pt, 34pt, 138pt, 46pt, 138pt, 50pt, 64pt),
  stroke: (x, y) => if y == 0 { 1pt + rgb("#2b6cb0") } else { 0.4pt + rgb("#e2e8f0") },
  fill: (col, row) => {
    if row == 0 { rgb("#edf2f7") }
    else if calc.odd(row) { rgb("#f7fafc") }
    else { none }
  },
  inset: (x: 2.5pt, y: 1.8pt),
  align: (col, row) => (
    if col in (0, 1, 3, 5, 6) { center }
    else if col == 2 { right }
    else { left }
  ),
  table.header(
    [*Jour.*], [*Date*], [*Équipe Domicile*], [*Médian*], [*Équipe Extérieure*], [*xG Esp.*], [*1 / N / 2*]
  ),
  [J1], [09-08], [*#text(fill: rgb("#1a365d"))[Lille OSC]*], [*#text(size: 8.8pt)[2 – 1]*], [#text(fill: rgb("#2d3748"))[Real Betis]], [1.81 – 1.29], [49%/23%/28%],
  [J1], [09-09], [*#text(fill: rgb("#1a365d"))[FC Barcelone]*], [*#text(size: 8.8pt)[3 – 1]*], [#text(fill: rgb("#2d3748"))[Feyenoord]], [2.82 – 0.83], [78%/13%/8%],
  [J1], [09-09], [*#text(fill: rgb("#1a365d"))[Paris Saint-Germain]*], [*#text(size: 8.8pt)[4 – 0]*], [#text(fill: rgb("#2d3748"))[Slovan Bratislava]], [3.88 – 0.60], [92%/6%/2%],
  [J1], [09-10], [#text(fill: rgb("#2d3748"))[Slavia Prague]], [*#text(size: 8.8pt)[2 – 1]*], [*#text(fill: rgb("#1a365d"))[RC Lens]*], [1.94 – 1.21], [54%/22%/24%],
  [J2], [10-13], [*#text(fill: rgb("#1a365d"))[RC Lens]*], [*#text(size: 8.8pt)[1 – 2]*], [#text(fill: rgb("#2d3748"))[Sporting CP]], [1.12 – 2.08], [20%/21%/59%],
  [J2], [10-13], [#text(fill: rgb("#2d3748"))[Arsenal]], [*#text(size: 8.8pt)[3 – 1]*], [*#text(fill: rgb("#1a365d"))[Lille OSC]*], [2.67 – 0.88], [76%/15%/10%],
  [J2], [10-13], [#text(fill: rgb("#2d3748"))[Galatasaray]], [*#text(size: 8.8pt)[1 – 2]*], [*#text(fill: rgb("#1a365d"))[FC Barcelone]*], [1.23 – 1.91], [25%/22%/53%],
  [J2], [10-14], [#text(fill: rgb("#2d3748"))[Manchester City]], [*#text(size: 8.8pt)[2 – 1]*], [*#text(fill: rgb("#1a365d"))[Paris Saint-Germain]*], [1.72 – 1.36], [46%/24%/30%],
  [J3], [10-20], [*#text(fill: rgb("#1a365d"))[Paris Saint-Germain]*], [*#text(size: 8.8pt)[2 – 1]*], [*#text(fill: rgb("#1a365d"))[FC Barcelone]*], [1.80 – 1.30], [49%/23%/28%],
  [J3], [10-21], [*#text(fill: rgb("#1a365d"))[Lille OSC]*], [*#text(size: 8.8pt)[1 – 1]*], [#text(fill: rgb("#2d3748"))[Galatasaray]], [1.47 – 1.59], [36%/24%/40%],
  [J3], [10-21], [#text(fill: rgb("#2d3748"))[Club Brugge]], [*#text(size: 8.8pt)[2 – 1]*], [*#text(fill: rgb("#1a365d"))[RC Lens]*], [1.97 – 1.19], [56%/22%/22%],
  [J4], [11-03], [*#text(fill: rgb("#1a365d"))[FC Barcelone]*], [*#text(size: 8.8pt)[2 – 1]*], [#text(fill: rgb("#2d3748"))[Aston Villa]], [2.46 – 0.95], [70%/17%/13%],
  [J4], [11-03], [#text(fill: rgb("#2d3748"))[Bodø/Glimt]], [*#text(size: 8.8pt)[1 – 1]*], [*#text(fill: rgb("#1a365d"))[Lille OSC]*], [1.55 – 1.51], [39%/24%/37%],
  [J4], [11-03], [#text(fill: rgb("#2d3748"))[Villarreal]], [*#text(size: 8.8pt)[1 – 2]*], [*#text(fill: rgb("#1a365d"))[Paris Saint-Germain]*], [0.98 – 2.40], [14%/17%/69%],
  [J4], [11-04], [*#text(fill: rgb("#1a365d"))[RC Lens]*], [*#text(size: 8.8pt)[1 – 1]*], [#text(fill: rgb("#2d3748"))[Como]], [1.67 – 1.40], [44%/24%/32%],
  [J5], [11-24], [#text(fill: rgb("#2d3748"))[RB Leipzig]], [*#text(size: 8.8pt)[2 – 1]*], [*#text(fill: rgb("#1a365d"))[RC Lens]*], [2.20 – 1.07], [63%/20%/17%],
  [J5], [11-25], [#text(fill: rgb("#2d3748"))[Sabah]], [*#text(size: 8.8pt)[0 – 4]*], [*#text(fill: rgb("#1a365d"))[FC Barcelone]*], [0.59 – 3.94], [2%/6%/92%],
  [J5], [11-25], [*#text(fill: rgb("#1a365d"))[Lille OSC]*], [*#text(size: 8.8pt)[1 – 2]*], [#text(fill: rgb("#2d3748"))[Bayern Munich]], [1.05 – 2.24], [17%/19%/64%],
  [J5], [11-25], [*#text(fill: rgb("#1a365d"))[Paris Saint-Germain]*], [*#text(size: 8.8pt)[2 – 1]*], [#text(fill: rgb("#2d3748"))[Roma]], [2.64 – 0.89], [75%/15%/10%],
  [J6], [12-08], [#text(fill: rgb("#2d3748"))[Aston Villa]], [*#text(size: 8.8pt)[1 – 2]*], [*#text(fill: rgb("#1a365d"))[Paris Saint-Germain]*], [1.17 – 1.99], [22%/21%/56%],
  [J6], [12-08], [*#text(fill: rgb("#1a365d"))[FC Barcelone]*], [*#text(size: 8.8pt)[2 – 1]*], [#text(fill: rgb("#2d3748"))[Manchester City]], [1.68 – 1.39], [44%/24%/32%],
  [J6], [12-09], [*#text(fill: rgb("#1a365d"))[RC Lens]*], [*#text(size: 8.8pt)[2 – 1]*], [#text(fill: rgb("#2d3748"))[Bodø/Glimt]], [1.68 – 1.40], [44%/23%/32%],
  [J6], [12-09], [#text(fill: rgb("#2d3748"))[VfB Stuttgart]], [*#text(size: 8.8pt)[1 – 1]*], [*#text(fill: rgb("#1a365d"))[Lille OSC]*], [1.61 – 1.45], [42%/24%/35%],
  [J7], [01-19], [*#text(fill: rgb("#1a365d"))[Lille OSC]*], [*#text(size: 8.8pt)[2 – 1]*], [#text(fill: rgb("#2d3748"))[Slovan Bratislava]], [2.25 – 1.04], [65%/19%/16%],
  [J7], [01-20], [#text(fill: rgb("#2d3748"))[Como]], [*#text(size: 8.8pt)[1 – 2]*], [*#text(fill: rgb("#1a365d"))[Paris Saint-Germain]*], [0.90 – 2.61], [11%/15%/74%],
  [J7], [01-20], [*#text(fill: rgb("#1a365d"))[RC Lens]*], [*#text(size: 8.8pt)[1 – 3]*], [#text(fill: rgb("#2d3748"))[Manchester City]], [0.87 – 2.68], [10%/15%/76%],
  [J7], [01-20], [#text(fill: rgb("#2d3748"))[Sporting CP]], [*#text(size: 8.8pt)[1 – 2]*], [*#text(fill: rgb("#1a365d"))[FC Barcelone]*], [1.39 – 1.68], [32%/24%/45%],
  [J8], [01-27], [#text(fill: rgb("#2d3748"))[Roma]], [*#text(size: 8.8pt)[2 – 1]*], [*#text(fill: rgb("#1a365d"))[Lille OSC]*], [1.97 – 1.19], [56%/22%/23%],
  [J8], [01-27], [*#text(fill: rgb("#1a365d"))[FC Barcelone]*], [*#text(size: 8.8pt)[3 – 1]*], [#text(fill: rgb("#2d3748"))[Como]], [3.22 – 0.73], [85%/10%/5%],
  [J8], [01-27], [#text(fill: rgb("#2d3748"))[Liverpool]], [*#text(size: 8.8pt)[3 – 1]*], [*#text(fill: rgb("#1a365d"))[RC Lens]*], [3.24 – 0.72], [85%/10%/5%],
  [J8], [01-27], [*#text(fill: rgb("#1a365d"))[Paris Saint-Germain]*], [*#text(size: 8.8pt)[2 – 1]*], [#text(fill: rgb("#2d3748"))[Galatasaray]], [2.54 – 0.92], [73%/16%/11%],

)
]

#pagebreak()

== Calendrier Officiel — Journées 1 et 2

=== Journée 1
#align(center)[
#table(
  columns: (38pt, 142pt, 46pt, 142pt, 50pt, 66pt),
  stroke: (x, y) => if y == 0 { 1pt + rgb("#2b6cb0") } else { 0.4pt + rgb("#e2e8f0") },
  fill: (col, row) => {
    if row == 0 { rgb("#edf2f7") }
    else if calc.odd(row) { rgb("#f7fafc") }
    else { none }
  },
  inset: (x: 2.5pt, y: 1.8pt),
  align: (col, row) => (
    if col in (0, 2, 4, 5) { center }
    else if col == 1 { right }
    else { left }
  ),
  table.header(
    [*Date*], [*Équipe Domicile*], [*Médian*], [*Équipe Extérieure*], [*xG Esp.*], [*1 / N / 2*]
  ),
  [2026-09-08], [#text(fill: rgb("#2d3748"))[AEK Athens]], [*#text(size: 8.8pt)[2 – 1]*], [#text(fill: rgb("#2d3748"))[LASK]], [2.13 – 1.10], [61%/20%/19%],
  [2026-09-08], [#text(fill: rgb("#2d3748"))[Club Brugge]], [*#text(size: 8.8pt)[1 – 1]*], [#text(fill: rgb("#2d3748"))[Aston Villa]], [1.46 – 1.61], [35%/24%/41%],
  [2026-09-08], [#text(fill: rgb("#2d3748"))[Borussia Dortmund]], [*#text(size: 8.8pt)[2 – 1]*], [#text(fill: rgb("#2d3748"))[Villarreal]], [2.17 – 1.08], [62%/20%/18%],
  [2026-09-08], [#text(fill: rgb("#2d3748"))[Porto]], [*#text(size: 8.8pt)[1 – 2]*], [#text(fill: rgb("#2d3748"))[Manchester City]], [1.28 – 1.83], [27%/23%/50%],
  [2026-09-08], [*#text(fill: rgb("#1a365d"))[Lille OSC]*], [*#text(size: 8.8pt)[2 – 1]*], [#text(fill: rgb("#2d3748"))[Real Betis]], [1.81 – 1.29], [49%/23%/28%],
  [2026-09-08], [#text(fill: rgb("#2d3748"))[Real Madrid]], [*#text(size: 8.8pt)[2 – 1]*], [#text(fill: rgb("#2d3748"))[Inter Milan]], [2.00 – 1.17], [56%/22%/22%],
  [2026-09-09], [*#text(fill: rgb("#1a365d"))[FC Barcelone]*], [*#text(size: 8.8pt)[3 – 1]*], [#text(fill: rgb("#2d3748"))[Feyenoord]], [2.82 – 0.83], [78%/13%/8%],
  [2026-09-09], [#text(fill: rgb("#2d3748"))[VfB Stuttgart]], [*#text(size: 8.8pt)[2 – 1]*], [#text(fill: rgb("#2d3748"))[Viking]], [2.26 – 1.04], [65%/19%/16%],
  [2026-09-09], [#text(fill: rgb("#2d3748"))[Liverpool]], [*#text(size: 8.8pt)[2 – 1]*], [#text(fill: rgb("#2d3748"))[Atlético Madrid]], [2.21 – 1.06], [64%/19%/17%],
  [2026-09-09], [*#text(fill: rgb("#1a365d"))[Paris Saint-Germain]*], [*#text(size: 8.8pt)[4 – 0]*], [#text(fill: rgb("#2d3748"))[Slovan Bratislava]], [3.88 – 0.60], [92%/6%/2%],
  [2026-09-09], [#text(fill: rgb("#2d3748"))[Sporting CP]], [*#text(size: 8.8pt)[2 – 1]*], [#text(fill: rgb("#2d3748"))[Galatasaray]], [1.96 – 1.19], [55%/22%/23%],
  [2026-09-09], [#text(fill: rgb("#2d3748"))[Napoli]], [*#text(size: 8.8pt)[1 – 2]*], [#text(fill: rgb("#2d3748"))[Arsenal]], [1.21 – 1.94], [23%/22%/54%],
  [2026-09-10], [#text(fill: rgb("#2d3748"))[Fenerbahçe]], [*#text(size: 8.8pt)[2 – 1]*], [#text(fill: rgb("#2d3748"))[Roma]], [1.68 – 1.39], [45%/24%/32%],
  [2026-09-10], [#text(fill: rgb("#2d3748"))[PSV Eindhoven]], [*#text(size: 8.8pt)[2 – 1]*], [#text(fill: rgb("#2d3748"))[Shakhtar Donetsk]], [2.18 – 1.08], [63%/20%/18%],
  [2026-09-10], [#text(fill: rgb("#2d3748"))[Como]], [*#text(size: 8.8pt)[1 – 1]*], [#text(fill: rgb("#2d3748"))[RB Leipzig]], [1.42 – 1.65], [33%/24%/43%],
  [2026-09-10], [#text(fill: rgb("#2d3748"))[Bayern Munich]], [*#text(size: 8.8pt)[3 – 1]*], [#text(fill: rgb("#2d3748"))[Bodø/Glimt]], [3.22 – 0.73], [85%/10%/5%],
  [2026-09-10], [#text(fill: rgb("#2d3748"))[Manchester United]], [*#text(size: 8.8pt)[3 – 0]*], [#text(fill: rgb("#2d3748"))[Sabah]], [3.48 – 0.67], [88%/8%/4%],
  [2026-09-10], [#text(fill: rgb("#2d3748"))[Slavia Prague]], [*#text(size: 8.8pt)[2 – 1]*], [*#text(fill: rgb("#1a365d"))[RC Lens]*], [1.94 – 1.21], [54%/22%/24%],

)
]

#v(0.08cm)

=== Journée 2
#align(center)[
#table(
  columns: (38pt, 142pt, 46pt, 142pt, 50pt, 66pt),
  stroke: (x, y) => if y == 0 { 1pt + rgb("#2b6cb0") } else { 0.4pt + rgb("#e2e8f0") },
  fill: (col, row) => {
    if row == 0 { rgb("#edf2f7") }
    else if calc.odd(row) { rgb("#f7fafc") }
    else { none }
  },
  inset: (x: 2.5pt, y: 1.8pt),
  align: (col, row) => (
    if col in (0, 2, 4, 5) { center }
    else if col == 1 { right }
    else { left }
  ),
  table.header(
    [*Date*], [*Équipe Domicile*], [*Médian*], [*Équipe Extérieure*], [*xG Esp.*], [*1 / N / 2*]
  ),
  [2026-10-13], [*#text(fill: rgb("#1a365d"))[RC Lens]*], [*#text(size: 8.8pt)[1 – 2]*], [#text(fill: rgb("#2d3748"))[Sporting CP]], [1.12 – 2.08], [20%/21%/59%],
  [2026-10-13], [#text(fill: rgb("#2d3748"))[Sabah]], [*#text(size: 8.8pt)[1 – 2]*], [#text(fill: rgb("#2d3748"))[Slavia Prague]], [1.03 – 2.28], [15%/19%/65%],
  [2026-10-13], [#text(fill: rgb("#2d3748"))[Arsenal]], [*#text(size: 8.8pt)[3 – 1]*], [*#text(fill: rgb("#1a365d"))[Lille OSC]*], [2.67 – 0.88], [76%/15%/10%],
  [2026-10-13], [#text(fill: rgb("#2d3748"))[Atlético Madrid]], [*#text(size: 8.8pt)[2 – 1]*], [#text(fill: rgb("#2d3748"))[Manchester United]], [1.92 – 1.22], [54%/22%/24%],
  [2026-10-13], [#text(fill: rgb("#2d3748"))[Inter Milan]], [*#text(size: 8.8pt)[2 – 1]*], [#text(fill: rgb("#2d3748"))[Club Brugge]], [2.61 – 0.90], [74%/15%/11%],
  [2026-10-13], [#text(fill: rgb("#2d3748"))[Galatasaray]], [*#text(size: 8.8pt)[1 – 2]*], [*#text(fill: rgb("#1a365d"))[FC Barcelone]*], [1.23 – 1.91], [25%/22%/53%],
  [2026-10-13], [#text(fill: rgb("#2d3748"))[RB Leipzig]], [*#text(size: 8.8pt)[1 – 1]*], [#text(fill: rgb("#2d3748"))[PSV Eindhoven]], [1.52 – 1.54], [38%/24%/38%],
  [2026-10-13], [#text(fill: rgb("#2d3748"))[Viking]], [*#text(size: 8.8pt)[1 – 3]*], [#text(fill: rgb("#2d3748"))[Bayern Munich]], [0.75 – 3.14], [6%/10%/84%],
  [2026-10-13], [#text(fill: rgb("#2d3748"))[Villarreal]], [*#text(size: 8.8pt)[1 – 1]*], [#text(fill: rgb("#2d3748"))[Napoli]], [1.57 – 1.49], [40%/24%/36%],
  [2026-10-14], [#text(fill: rgb("#2d3748"))[Feyenoord]], [*#text(size: 8.8pt)[2 – 1]*], [#text(fill: rgb("#2d3748"))[Como]], [1.98 – 1.18], [56%/22%/22%],
  [2026-10-14], [#text(fill: rgb("#2d3748"))[LASK]], [*#text(size: 8.8pt)[0 – 3]*], [#text(fill: rgb("#2d3748"))[Liverpool]], [0.68 – 3.45], [4%/8%/88%],
  [2026-10-14], [#text(fill: rgb("#2d3748"))[Roma]], [*#text(size: 8.8pt)[1 – 2]*], [#text(fill: rgb("#2d3748"))[Real Madrid]], [1.15 – 2.03], [21%/21%/58%],
  [2026-10-14], [#text(fill: rgb("#2d3748"))[Aston Villa]], [*#text(size: 8.8pt)[2 – 1]*], [#text(fill: rgb("#2d3748"))[Fenerbahçe]], [1.84 – 1.27], [51%/23%/26%],
  [2026-10-14], [#text(fill: rgb("#2d3748"))[Shakhtar Donetsk]], [*#text(size: 8.8pt)[2 – 1]*], [#text(fill: rgb("#2d3748"))[AEK Athens]], [2.21 – 1.06], [63%/19%/17%],
  [2026-10-14], [#text(fill: rgb("#2d3748"))[Bodø/Glimt]], [*#text(size: 8.8pt)[1 – 2]*], [#text(fill: rgb("#2d3748"))[Borussia Dortmund]], [1.28 – 1.84], [27%/23%/50%],
  [2026-10-14], [#text(fill: rgb("#2d3748"))[Manchester City]], [*#text(size: 8.8pt)[2 – 1]*], [*#text(fill: rgb("#1a365d"))[Paris Saint-Germain]*], [1.72 – 1.36], [46%/24%/30%],
  [2026-10-14], [#text(fill: rgb("#2d3748"))[Real Betis]], [*#text(size: 8.8pt)[1 – 2]*], [#text(fill: rgb("#2d3748"))[Porto]], [1.31 – 1.78], [28%/23%/49%],
  [2026-10-14], [#text(fill: rgb("#2d3748"))[Slovan Bratislava]], [*#text(size: 8.8pt)[1 – 1]*], [#text(fill: rgb("#2d3748"))[VfB Stuttgart]], [1.44 – 1.63], [34%/24%/42%],

)
]

#pagebreak()

== Calendrier Officiel — Journées 3 et 4

=== Journée 3
#align(center)[
#table(
  columns: (38pt, 142pt, 46pt, 142pt, 50pt, 66pt),
  stroke: (x, y) => if y == 0 { 1pt + rgb("#2b6cb0") } else { 0.4pt + rgb("#e2e8f0") },
  fill: (col, row) => {
    if row == 0 { rgb("#edf2f7") }
    else if calc.odd(row) { rgb("#f7fafc") }
    else { none }
  },
  inset: (x: 2.5pt, y: 1.8pt),
  align: (col, row) => (
    if col in (0, 2, 4, 5) { center }
    else if col == 1 { right }
    else { left }
  ),
  table.header(
    [*Date*], [*Équipe Domicile*], [*Médian*], [*Équipe Extérieure*], [*xG Esp.*], [*1 / N / 2*]
  ),
  [2026-10-20], [#text(fill: rgb("#2d3748"))[Fenerbahçe]], [*#text(size: 8.8pt)[2 – 1]*], [#text(fill: rgb("#2d3748"))[Slavia Prague]], [1.98 – 1.18], [56%/22%/22%],
  [2026-10-20], [#text(fill: rgb("#2d3748"))[Sabah]], [*#text(size: 8.8pt)[1 – 3]*], [#text(fill: rgb("#2d3748"))[Borussia Dortmund]], [0.81 – 2.88], [8%/13%/80%],
  [2026-10-20], [#text(fill: rgb("#2d3748"))[Roma]], [*#text(size: 8.8pt)[2 – 1]*], [#text(fill: rgb("#2d3748"))[Slovan Bratislava]], [2.55 – 0.92], [73%/16%/11%],
  [2026-10-20], [#text(fill: rgb("#2d3748"))[Porto]], [*#text(size: 8.8pt)[2 – 1]*], [#text(fill: rgb("#2d3748"))[PSV Eindhoven]], [1.76 – 1.33], [48%/23%/29%],
  [2026-10-20], [#text(fill: rgb("#2d3748"))[Liverpool]], [*#text(size: 8.8pt)[3 – 1]*], [#text(fill: rgb("#2d3748"))[Villarreal]], [2.88 – 0.81], [79%/13%/8%],
  [2026-10-20], [#text(fill: rgb("#2d3748"))[Manchester City]], [*#text(size: 8.8pt)[4 – 0]*], [#text(fill: rgb("#2d3748"))[AEK Athens]], [3.83 – 0.61], [91%/6%/2%],
  [2026-10-20], [*#text(fill: rgb("#1a365d"))[Paris Saint-Germain]*], [*#text(size: 8.8pt)[2 – 1]*], [*#text(fill: rgb("#1a365d"))[FC Barcelone]*], [1.80 – 1.30], [49%/23%/28%],
  [2026-10-20], [#text(fill: rgb("#2d3748"))[Napoli]], [*#text(size: 8.8pt)[2 – 1]*], [#text(fill: rgb("#2d3748"))[Bodø/Glimt]], [2.09 – 1.12], [60%/21%/20%],
  [2026-10-20], [#text(fill: rgb("#2d3748"))[VfB Stuttgart]], [*#text(size: 8.8pt)[1 – 2]*], [#text(fill: rgb("#2d3748"))[Atlético Madrid]], [1.27 – 1.84], [26%/23%/51%],
  [2026-10-21], [#text(fill: rgb("#2d3748"))[Como]], [*#text(size: 8.8pt)[1 – 2]*], [#text(fill: rgb("#2d3748"))[Manchester United]], [1.36 – 1.72], [30%/24%/46%],
  [2026-10-21], [*#text(fill: rgb("#1a365d"))[Lille OSC]*], [*#text(size: 8.8pt)[1 – 1]*], [#text(fill: rgb("#2d3748"))[Galatasaray]], [1.47 – 1.59], [36%/24%/40%],
  [2026-10-21], [#text(fill: rgb("#2d3748"))[Aston Villa]], [*#text(size: 8.8pt)[3 – 1]*], [#text(fill: rgb("#2d3748"))[Viking]], [2.84 – 0.82], [79%/13%/8%],
  [2026-10-21], [#text(fill: rgb("#2d3748"))[Club Brugge]], [*#text(size: 8.8pt)[2 – 1]*], [*#text(fill: rgb("#1a365d"))[RC Lens]*], [1.97 – 1.19], [56%/22%/22%],
  [2026-10-21], [#text(fill: rgb("#2d3748"))[Bayern Munich]], [*#text(size: 8.8pt)[2 – 1]*], [#text(fill: rgb("#2d3748"))[Arsenal]], [1.86 – 1.25], [52%/23%/26%],
  [2026-10-21], [#text(fill: rgb("#2d3748"))[Inter Milan]], [*#text(size: 8.8pt)[2 – 1]*], [#text(fill: rgb("#2d3748"))[Shakhtar Donetsk]], [2.59 – 0.90], [73%/16%/11%],
  [2026-10-21], [#text(fill: rgb("#2d3748"))[Real Madrid]], [*#text(size: 8.8pt)[3 – 1]*], [#text(fill: rgb("#2d3748"))[RB Leipzig]], [2.71 – 0.86], [76%/14%/9%],
  [2026-10-21], [#text(fill: rgb("#2d3748"))[Real Betis]], [*#text(size: 8.8pt)[1 – 1]*], [#text(fill: rgb("#2d3748"))[Feyenoord]], [1.63 – 1.44], [42%/24%/34%],
  [2026-10-21], [#text(fill: rgb("#2d3748"))[Sporting CP]], [*#text(size: 8.8pt)[3 – 0]*], [#text(fill: rgb("#2d3748"))[LASK]], [3.65 – 0.64], [90%/7%/3%],

)
]

#v(0.08cm)

=== Journée 4
#align(center)[
#table(
  columns: (38pt, 142pt, 46pt, 142pt, 50pt, 66pt),
  stroke: (x, y) => if y == 0 { 1pt + rgb("#2b6cb0") } else { 0.4pt + rgb("#e2e8f0") },
  fill: (col, row) => {
    if row == 0 { rgb("#edf2f7") }
    else if calc.odd(row) { rgb("#f7fafc") }
    else { none }
  },
  inset: (x: 2.5pt, y: 1.8pt),
  align: (col, row) => (
    if col in (0, 2, 4, 5) { center }
    else if col == 1 { right }
    else { left }
  ),
  table.header(
    [*Date*], [*Équipe Domicile*], [*Médian*], [*Équipe Extérieure*], [*xG Esp.*], [*1 / N / 2*]
  ),
  [2026-11-03], [#text(fill: rgb("#2d3748"))[Shakhtar Donetsk]], [*#text(size: 8.8pt)[1 – 2]*], [#text(fill: rgb("#2d3748"))[Sporting CP]], [1.29 – 1.81], [27%/23%/50%],
  [2026-11-03], [#text(fill: rgb("#2d3748"))[Galatasaray]], [*#text(size: 8.8pt)[2 – 1]*], [#text(fill: rgb("#2d3748"))[VfB Stuttgart]], [2.19 – 1.07], [63%/20%/17%],
  [2026-11-03], [#text(fill: rgb("#2d3748"))[Atlético Madrid]], [*#text(size: 8.8pt)[1 – 2]*], [#text(fill: rgb("#2d3748"))[Bayern Munich]], [1.32 – 1.77], [29%/23%/48%],
  [2026-11-03], [*#text(fill: rgb("#1a365d"))[FC Barcelone]*], [*#text(size: 8.8pt)[2 – 1]*], [#text(fill: rgb("#2d3748"))[Aston Villa]], [2.46 – 0.95], [70%/17%/13%],
  [2026-11-03], [#text(fill: rgb("#2d3748"))[Feyenoord]], [*#text(size: 8.8pt)[1 – 2]*], [#text(fill: rgb("#2d3748"))[Inter Milan]], [1.20 – 1.96], [23%/22%/55%],
  [2026-11-03], [#text(fill: rgb("#2d3748"))[Bodø/Glimt]], [*#text(size: 8.8pt)[1 – 1]*], [*#text(fill: rgb("#1a365d"))[Lille OSC]*], [1.55 – 1.51], [39%/24%/37%],
  [2026-11-03], [#text(fill: rgb("#2d3748"))[LASK]], [*#text(size: 8.8pt)[1 – 1]*], [#text(fill: rgb("#2d3748"))[Slovan Bratislava]], [1.42 – 1.65], [33%/24%/43%],
  [2026-11-03], [#text(fill: rgb("#2d3748"))[Manchester United]], [*#text(size: 8.8pt)[2 – 1]*], [#text(fill: rgb("#2d3748"))[Roma]], [1.74 – 1.34], [47%/23%/30%],
  [2026-11-03], [#text(fill: rgb("#2d3748"))[Villarreal]], [*#text(size: 8.8pt)[1 – 2]*], [*#text(fill: rgb("#1a365d"))[Paris Saint-Germain]*], [0.98 – 2.40], [14%/17%/69%],
  [2026-11-04], [#text(fill: rgb("#2d3748"))[AEK Athens]], [*#text(size: 8.8pt)[1 – 3]*], [#text(fill: rgb("#2d3748"))[Real Madrid]], [0.79 – 2.97], [7%/12%/81%],
  [2026-11-04], [#text(fill: rgb("#2d3748"))[Fenerbahçe]], [*#text(size: 8.8pt)[1 – 2]*], [#text(fill: rgb("#2d3748"))[Liverpool]], [1.18 – 1.98], [23%/22%/56%],
  [2026-11-04], [#text(fill: rgb("#2d3748"))[Borussia Dortmund]], [*#text(size: 8.8pt)[2 – 1]*], [#text(fill: rgb("#2d3748"))[Real Betis]], [2.19 – 1.07], [63%/20%/17%],
  [2026-11-04], [#text(fill: rgb("#2d3748"))[Porto]], [*#text(size: 8.8pt)[2 – 1]*], [#text(fill: rgb("#2d3748"))[Napoli]], [2.04 – 1.15], [58%/21%/21%],
  [2026-11-04], [#text(fill: rgb("#2d3748"))[PSV Eindhoven]], [*#text(size: 8.8pt)[2 – 1]*], [#text(fill: rgb("#2d3748"))[Club Brugge]], [2.20 – 1.07], [63%/20%/17%],
  [2026-11-04], [#text(fill: rgb("#2d3748"))[RB Leipzig]], [*#text(size: 8.8pt)[1 – 2]*], [#text(fill: rgb("#2d3748"))[Manchester City]], [1.11 – 2.12], [19%/20%/60%],
  [2026-11-04], [*#text(fill: rgb("#1a365d"))[RC Lens]*], [*#text(size: 8.8pt)[1 – 1]*], [#text(fill: rgb("#2d3748"))[Como]], [1.67 – 1.40], [44%/24%/32%],
  [2026-11-04], [#text(fill: rgb("#2d3748"))[Slavia Prague]], [*#text(size: 8.8pt)[1 – 2]*], [#text(fill: rgb("#2d3748"))[Arsenal]], [1.08 – 2.16], [18%/20%/62%],
  [2026-11-04], [#text(fill: rgb("#2d3748"))[Viking]], [*#text(size: 8.8pt)[2 – 1]*], [#text(fill: rgb("#2d3748"))[Sabah]], [2.17 – 1.08], [62%/20%/18%],

)
]

#pagebreak()

== Calendrier Officiel — Journées 5 et 6

=== Journée 5
#align(center)[
#table(
  columns: (38pt, 142pt, 46pt, 142pt, 50pt, 66pt),
  stroke: (x, y) => if y == 0 { 1pt + rgb("#2b6cb0") } else { 0.4pt + rgb("#e2e8f0") },
  fill: (col, row) => {
    if row == 0 { rgb("#edf2f7") }
    else if calc.odd(row) { rgb("#f7fafc") }
    else { none }
  },
  inset: (x: 2.5pt, y: 1.8pt),
  align: (col, row) => (
    if col in (0, 2, 4, 5) { center }
    else if col == 1 { right }
    else { left }
  ),
  table.header(
    [*Date*], [*Équipe Domicile*], [*Médian*], [*Équipe Extérieure*], [*xG Esp.*], [*1 / N / 2*]
  ),
  [2026-11-24], [#text(fill: rgb("#2d3748"))[Bodø/Glimt]], [*#text(size: 8.8pt)[2 – 1]*], [#text(fill: rgb("#2d3748"))[LASK]], [2.45 – 0.96], [70%/17%/13%],
  [2026-11-24], [#text(fill: rgb("#2d3748"))[Galatasaray]], [*#text(size: 8.8pt)[2 – 1]*], [#text(fill: rgb("#2d3748"))[Aston Villa]], [1.74 – 1.34], [47%/23%/29%],
  [2026-11-24], [#text(fill: rgb("#2d3748"))[Arsenal]], [*#text(size: 8.8pt)[2 – 1]*], [#text(fill: rgb("#2d3748"))[Borussia Dortmund]], [2.20 – 1.06], [63%/20%/17%],
  [2026-11-24], [#text(fill: rgb("#2d3748"))[Como]], [*#text(size: 8.8pt)[2 – 1]*], [#text(fill: rgb("#2d3748"))[AEK Athens]], [2.00 – 1.17], [56%/21%/22%],
  [2026-11-24], [#text(fill: rgb("#2d3748"))[Feyenoord]], [*#text(size: 8.8pt)[1 – 1]*], [#text(fill: rgb("#2d3748"))[Porto]], [1.40 – 1.67], [32%/24%/44%],
  [2026-11-24], [#text(fill: rgb("#2d3748"))[Manchester City]], [*#text(size: 8.8pt)[3 – 1]*], [#text(fill: rgb("#2d3748"))[Napoli]], [2.76 – 0.85], [78%/14%/9%],
  [2026-11-24], [#text(fill: rgb("#2d3748"))[RB Leipzig]], [*#text(size: 8.8pt)[2 – 1]*], [*#text(fill: rgb("#1a365d"))[RC Lens]*], [2.20 – 1.07], [63%/20%/17%],
  [2026-11-24], [#text(fill: rgb("#2d3748"))[Real Madrid]], [*#text(size: 8.8pt)[2 – 1]*], [#text(fill: rgb("#2d3748"))[PSV Eindhoven]], [2.38 – 0.98], [68%/18%/14%],
  [2026-11-24], [#text(fill: rgb("#2d3748"))[Slovan Bratislava]], [*#text(size: 8.8pt)[1 – 1]*], [#text(fill: rgb("#2d3748"))[Real Betis]], [1.39 – 1.68], [32%/24%/44%],
  [2026-11-25], [#text(fill: rgb("#2d3748"))[Sabah]], [*#text(size: 8.8pt)[0 – 4]*], [*#text(fill: rgb("#1a365d"))[FC Barcelone]*], [0.59 – 3.94], [2%/6%/92%],
  [2026-11-25], [#text(fill: rgb("#2d3748"))[Slavia Prague]], [*#text(size: 8.8pt)[2 – 1]*], [#text(fill: rgb("#2d3748"))[Villarreal]], [1.72 – 1.36], [46%/23%/31%],
  [2026-11-25], [#text(fill: rgb("#2d3748"))[Atlético Madrid]], [*#text(size: 8.8pt)[3 – 1]*], [#text(fill: rgb("#2d3748"))[Viking]], [3.08 – 0.76], [83%/11%/6%],
  [2026-11-25], [#text(fill: rgb("#2d3748"))[Club Brugge]], [*#text(size: 8.8pt)[1 – 2]*], [#text(fill: rgb("#2d3748"))[Liverpool]], [1.05 – 2.22], [17%/19%/64%],
  [2026-11-25], [#text(fill: rgb("#2d3748"))[Inter Milan]], [*#text(size: 8.8pt)[3 – 1]*], [#text(fill: rgb("#2d3748"))[VfB Stuttgart]], [2.76 – 0.85], [77%/14%/9%],
  [2026-11-25], [#text(fill: rgb("#2d3748"))[Shakhtar Donetsk]], [*#text(size: 8.8pt)[1 – 1]*], [#text(fill: rgb("#2d3748"))[Fenerbahçe]], [1.56 – 1.50], [39%/24%/37%],
  [2026-11-25], [*#text(fill: rgb("#1a365d"))[Lille OSC]*], [*#text(size: 8.8pt)[1 – 2]*], [#text(fill: rgb("#2d3748"))[Bayern Munich]], [1.05 – 2.24], [17%/19%/64%],
  [2026-11-25], [*#text(fill: rgb("#1a365d"))[Paris Saint-Germain]*], [*#text(size: 8.8pt)[2 – 1]*], [#text(fill: rgb("#2d3748"))[Roma]], [2.64 – 0.89], [75%/15%/10%],
  [2026-11-25], [#text(fill: rgb("#2d3748"))[Sporting CP]], [*#text(size: 8.8pt)[2 – 1]*], [#text(fill: rgb("#2d3748"))[Manchester United]], [2.02 – 1.16], [57%/21%/21%],

)
]

#v(0.08cm)

=== Journée 6
#align(center)[
#table(
  columns: (38pt, 142pt, 46pt, 142pt, 50pt, 66pt),
  stroke: (x, y) => if y == 0 { 1pt + rgb("#2b6cb0") } else { 0.4pt + rgb("#e2e8f0") },
  fill: (col, row) => {
    if row == 0 { rgb("#edf2f7") }
    else if calc.odd(row) { rgb("#f7fafc") }
    else { none }
  },
  inset: (x: 2.5pt, y: 1.8pt),
  align: (col, row) => (
    if col in (0, 2, 4, 5) { center }
    else if col == 1 { right }
    else { left }
  ),
  table.header(
    [*Date*], [*Équipe Domicile*], [*Médian*], [*Équipe Extérieure*], [*xG Esp.*], [*1 / N / 2*]
  ),
  [2026-12-08], [#text(fill: rgb("#2d3748"))[Viking]], [*#text(size: 8.8pt)[1 – 2]*], [#text(fill: rgb("#2d3748"))[Feyenoord]], [1.21 – 1.93], [24%/22%/54%],
  [2026-12-08], [#text(fill: rgb("#2d3748"))[Villarreal]], [*#text(size: 8.8pt)[3 – 1]*], [#text(fill: rgb("#2d3748"))[Sabah]], [2.96 – 0.79], [81%/12%/7%],
  [2026-12-08], [#text(fill: rgb("#2d3748"))[AEK Athens]], [*#text(size: 8.8pt)[1 – 2]*], [#text(fill: rgb("#2d3748"))[Galatasaray]], [1.14 – 2.05], [21%/21%/58%],
  [2026-12-08], [#text(fill: rgb("#2d3748"))[Roma]], [*#text(size: 8.8pt)[1 – 1]*], [#text(fill: rgb("#2d3748"))[Sporting CP]], [1.48 – 1.58], [36%/24%/40%],
  [2026-12-08], [#text(fill: rgb("#2d3748"))[Aston Villa]], [*#text(size: 8.8pt)[1 – 2]*], [*#text(fill: rgb("#1a365d"))[Paris Saint-Germain]*], [1.17 – 1.99], [22%/21%/56%],
  [2026-12-08], [*#text(fill: rgb("#1a365d"))[FC Barcelone]*], [*#text(size: 8.8pt)[2 – 1]*], [#text(fill: rgb("#2d3748"))[Manchester City]], [1.68 – 1.39], [44%/24%/32%],
  [2026-12-08], [#text(fill: rgb("#2d3748"))[Bayern Munich]], [*#text(size: 8.8pt)[3 – 1]*], [#text(fill: rgb("#2d3748"))[Slavia Prague]], [2.98 – 0.78], [81%/12%/7%],
  [2026-12-08], [#text(fill: rgb("#2d3748"))[Manchester United]], [*#text(size: 8.8pt)[2 – 1]*], [#text(fill: rgb("#2d3748"))[RB Leipzig]], [1.81 – 1.29], [49%/23%/27%],
  [2026-12-08], [#text(fill: rgb("#2d3748"))[Napoli]], [*#text(size: 8.8pt)[2 – 1]*], [#text(fill: rgb("#2d3748"))[Club Brugge]], [1.90 – 1.23], [53%/22%/25%],
  [2026-12-09], [#text(fill: rgb("#2d3748"))[Real Betis]], [*#text(size: 8.8pt)[2 – 1]*], [#text(fill: rgb("#2d3748"))[Como]], [1.86 – 1.26], [51%/23%/26%],
  [2026-12-09], [#text(fill: rgb("#2d3748"))[Slovan Bratislava]], [*#text(size: 8.8pt)[1 – 2]*], [#text(fill: rgb("#2d3748"))[Shakhtar Donetsk]], [1.35 – 1.73], [30%/23%/47%],
  [2026-12-09], [#text(fill: rgb("#2d3748"))[Arsenal]], [*#text(size: 8.8pt)[1 – 1]*], [#text(fill: rgb("#2d3748"))[Real Madrid]], [1.57 – 1.49], [40%/24%/36%],
  [2026-12-09], [#text(fill: rgb("#2d3748"))[Borussia Dortmund]], [*#text(size: 8.8pt)[1 – 1]*], [#text(fill: rgb("#2d3748"))[Inter Milan]], [1.42 – 1.65], [33%/24%/43%],
  [2026-12-09], [#text(fill: rgb("#2d3748"))[LASK]], [*#text(size: 8.8pt)[1 – 2]*], [#text(fill: rgb("#2d3748"))[Fenerbahçe]], [0.99 – 2.35], [14%/18%/68%],
  [2026-12-09], [#text(fill: rgb("#2d3748"))[Liverpool]], [*#text(size: 8.8pt)[2 – 1]*], [#text(fill: rgb("#2d3748"))[Porto]], [2.21 – 1.06], [63%/20%/17%],
  [2026-12-09], [#text(fill: rgb("#2d3748"))[PSV Eindhoven]], [*#text(size: 8.8pt)[2 – 1]*], [#text(fill: rgb("#2d3748"))[Atlético Madrid]], [1.70 – 1.37], [45%/24%/31%],
  [2026-12-09], [*#text(fill: rgb("#1a365d"))[RC Lens]*], [*#text(size: 8.8pt)[2 – 1]*], [#text(fill: rgb("#2d3748"))[Bodø/Glimt]], [1.68 – 1.40], [44%/23%/32%],
  [2026-12-09], [#text(fill: rgb("#2d3748"))[VfB Stuttgart]], [*#text(size: 8.8pt)[1 – 1]*], [*#text(fill: rgb("#1a365d"))[Lille OSC]*], [1.61 – 1.45], [42%/24%/35%],

)
]

#pagebreak()

== Calendrier Officiel — Journées 7 et 8

=== Journée 7
#align(center)[
#table(
  columns: (38pt, 142pt, 46pt, 142pt, 50pt, 66pt),
  stroke: (x, y) => if y == 0 { 1pt + rgb("#2b6cb0") } else { 0.4pt + rgb("#e2e8f0") },
  fill: (col, row) => {
    if row == 0 { rgb("#edf2f7") }
    else if calc.odd(row) { rgb("#f7fafc") }
    else { none }
  },
  inset: (x: 2.5pt, y: 1.8pt),
  align: (col, row) => (
    if col in (0, 2, 4, 5) { center }
    else if col == 1 { right }
    else { left }
  ),
  table.header(
    [*Date*], [*Équipe Domicile*], [*Médian*], [*Équipe Extérieure*], [*xG Esp.*], [*1 / N / 2*]
  ),
  [2027-01-19], [#text(fill: rgb("#2d3748"))[Bodø/Glimt]], [*#text(size: 8.8pt)[1 – 2]*], [#text(fill: rgb("#2d3748"))[Atlético Madrid]], [1.22 – 1.91], [24%/22%/53%],
  [2027-01-19], [#text(fill: rgb("#2d3748"))[Galatasaray]], [*#text(size: 8.8pt)[2 – 1]*], [#text(fill: rgb("#2d3748"))[Feyenoord]], [2.00 – 1.17], [57%/22%/22%],
  [2027-01-19], [#text(fill: rgb("#2d3748"))[AEK Athens]], [*#text(size: 8.8pt)[1 – 2]*], [#text(fill: rgb("#2d3748"))[Roma]], [1.18 – 1.97], [22%/22%/56%],
  [2027-01-19], [#text(fill: rgb("#2d3748"))[Aston Villa]], [*#text(size: 8.8pt)[1 – 1]*], [#text(fill: rgb("#2d3748"))[Borussia Dortmund]], [1.67 – 1.40], [44%/24%/32%],
  [2027-01-19], [#text(fill: rgb("#2d3748"))[Inter Milan]], [*#text(size: 8.8pt)[1 – 1]*], [#text(fill: rgb("#2d3748"))[Liverpool]], [1.59 – 1.47], [41%/24%/35%],
  [2027-01-19], [#text(fill: rgb("#2d3748"))[Porto]], [*#text(size: 8.8pt)[2 – 1]*], [#text(fill: rgb("#2d3748"))[Slavia Prague]], [2.28 – 1.03], [65%/19%/16%],
  [2027-01-19], [*#text(fill: rgb("#1a365d"))[Lille OSC]*], [*#text(size: 8.8pt)[2 – 1]*], [#text(fill: rgb("#2d3748"))[Slovan Bratislava]], [2.25 – 1.04], [65%/19%/16%],
  [2027-01-19], [#text(fill: rgb("#2d3748"))[Real Madrid]], [*#text(size: 8.8pt)[4 – 0]*], [#text(fill: rgb("#2d3748"))[LASK]], [4.67 – 0.50], [96%/3%/1%],
  [2027-01-19], [#text(fill: rgb("#2d3748"))[VfB Stuttgart]], [*#text(size: 8.8pt)[1 – 1]*], [#text(fill: rgb("#2d3748"))[Club Brugge]], [1.64 – 1.43], [43%/24%/33%],
  [2027-01-20], [#text(fill: rgb("#2d3748"))[Fenerbahçe]], [*#text(size: 8.8pt)[2 – 1]*], [#text(fill: rgb("#2d3748"))[Villarreal]], [1.97 – 1.19], [56%/22%/23%],
  [2027-01-20], [#text(fill: rgb("#2d3748"))[Sabah]], [*#text(size: 8.8pt)[1 – 2]*], [#text(fill: rgb("#2d3748"))[Napoli]], [0.92 – 2.55], [11%/16%/73%],
  [2027-01-20], [#text(fill: rgb("#2d3748"))[Como]], [*#text(size: 8.8pt)[1 – 2]*], [*#text(fill: rgb("#1a365d"))[Paris Saint-Germain]*], [0.90 – 2.61], [11%/15%/74%],
  [2027-01-20], [#text(fill: rgb("#2d3748"))[Manchester United]], [*#text(size: 8.8pt)[1 – 2]*], [#text(fill: rgb("#2d3748"))[Bayern Munich]], [1.19 – 1.96], [23%/22%/55%],
  [2027-01-20], [#text(fill: rgb("#2d3748"))[RB Leipzig]], [*#text(size: 8.8pt)[2 – 1]*], [#text(fill: rgb("#2d3748"))[Shakhtar Donetsk]], [1.91 – 1.22], [53%/22%/25%],
  [2027-01-20], [*#text(fill: rgb("#1a365d"))[RC Lens]*], [*#text(size: 8.8pt)[1 – 3]*], [#text(fill: rgb("#2d3748"))[Manchester City]], [0.87 – 2.68], [10%/15%/76%],
  [2027-01-20], [#text(fill: rgb("#2d3748"))[Real Betis]], [*#text(size: 8.8pt)[1 – 2]*], [#text(fill: rgb("#2d3748"))[Arsenal]], [1.08 – 2.17], [18%/20%/62%],
  [2027-01-20], [#text(fill: rgb("#2d3748"))[Sporting CP]], [*#text(size: 8.8pt)[1 – 2]*], [*#text(fill: rgb("#1a365d"))[FC Barcelone]*], [1.39 – 1.68], [32%/24%/45%],
  [2027-01-20], [#text(fill: rgb("#2d3748"))[Viking]], [*#text(size: 8.8pt)[1 – 2]*], [#text(fill: rgb("#2d3748"))[PSV Eindhoven]], [0.99 – 2.35], [15%/18%/67%],

)
]

#v(0.08cm)

=== Journée 8
#align(center)[
#table(
  columns: (38pt, 142pt, 46pt, 142pt, 50pt, 66pt),
  stroke: (x, y) => if y == 0 { 1pt + rgb("#2b6cb0") } else { 0.4pt + rgb("#e2e8f0") },
  fill: (col, row) => {
    if row == 0 { rgb("#edf2f7") }
    else if calc.odd(row) { rgb("#f7fafc") }
    else { none }
  },
  inset: (x: 2.5pt, y: 1.8pt),
  align: (col, row) => (
    if col in (0, 2, 4, 5) { center }
    else if col == 1 { right }
    else { left }
  ),
  table.header(
    [*Date*], [*Équipe Domicile*], [*Médian*], [*Équipe Extérieure*], [*xG Esp.*], [*1 / N / 2*]
  ),
  [2027-01-27], [#text(fill: rgb("#2d3748"))[Arsenal]], [*#text(size: 8.8pt)[5 – 0]*], [#text(fill: rgb("#2d3748"))[Sabah]], [4.69 – 0.50], [96%/3%/1%],
  [2027-01-27], [#text(fill: rgb("#2d3748"))[Roma]], [*#text(size: 8.8pt)[2 – 1]*], [*#text(fill: rgb("#1a365d"))[Lille OSC]*], [1.97 – 1.19], [56%/22%/23%],
  [2027-01-27], [#text(fill: rgb("#2d3748"))[Atlético Madrid]], [*#text(size: 8.8pt)[2 – 1]*], [#text(fill: rgb("#2d3748"))[Fenerbahçe]], [1.99 – 1.18], [56%/22%/22%],
  [2027-01-27], [#text(fill: rgb("#2d3748"))[Borussia Dortmund]], [*#text(size: 8.8pt)[3 – 1]*], [#text(fill: rgb("#2d3748"))[AEK Athens]], [2.71 – 0.86], [76%/15%/9%],
  [2027-01-27], [#text(fill: rgb("#2d3748"))[Club Brugge]], [*#text(size: 8.8pt)[2 – 1]*], [#text(fill: rgb("#2d3748"))[Bodø/Glimt]], [1.91 – 1.23], [53%/22%/25%],
  [2027-01-27], [#text(fill: rgb("#2d3748"))[Bayern Munich]], [*#text(size: 8.8pt)[3 – 1]*], [#text(fill: rgb("#2d3748"))[Real Betis]], [2.99 – 0.78], [81%/12%/7%],
  [2027-01-27], [*#text(fill: rgb("#1a365d"))[FC Barcelone]*], [*#text(size: 8.8pt)[3 – 1]*], [#text(fill: rgb("#2d3748"))[Como]], [3.22 – 0.73], [85%/10%/5%],
  [2027-01-27], [#text(fill: rgb("#2d3748"))[Shakhtar Donetsk]], [*#text(size: 8.8pt)[1 – 2]*], [#text(fill: rgb("#2d3748"))[Real Madrid]], [1.01 – 2.32], [15%/18%/67%],
  [2027-01-27], [#text(fill: rgb("#2d3748"))[Feyenoord]], [*#text(size: 8.8pt)[1 – 1]*], [#text(fill: rgb("#2d3748"))[RB Leipzig]], [1.62 – 1.45], [42%/24%/34%],
  [2027-01-27], [#text(fill: rgb("#2d3748"))[LASK]], [*#text(size: 8.8pt)[1 – 3]*], [#text(fill: rgb("#2d3748"))[Porto]], [0.87 – 2.70], [10%/14%/76%],
  [2027-01-27], [#text(fill: rgb("#2d3748"))[Liverpool]], [*#text(size: 8.8pt)[3 – 1]*], [*#text(fill: rgb("#1a365d"))[RC Lens]*], [3.24 – 0.72], [85%/10%/5%],
  [2027-01-27], [#text(fill: rgb("#2d3748"))[Manchester City]], [*#text(size: 8.8pt)[2 – 1]*], [#text(fill: rgb("#2d3748"))[Sporting CP]], [2.23 – 1.05], [64%/19%/17%],
  [2027-01-27], [*#text(fill: rgb("#1a365d"))[Paris Saint-Germain]*], [*#text(size: 8.8pt)[2 – 1]*], [#text(fill: rgb("#2d3748"))[Galatasaray]], [2.54 – 0.92], [73%/16%/11%],
  [2027-01-27], [#text(fill: rgb("#2d3748"))[PSV Eindhoven]], [*#text(size: 8.8pt)[2 – 1]*], [#text(fill: rgb("#2d3748"))[VfB Stuttgart]], [2.32 – 1.01], [67%/18%/15%],
  [2027-01-27], [#text(fill: rgb("#2d3748"))[Slavia Prague]], [*#text(size: 8.8pt)[1 – 1]*], [#text(fill: rgb("#2d3748"))[Aston Villa]], [1.43 – 1.64], [34%/24%/43%],
  [2027-01-27], [#text(fill: rgb("#2d3748"))[Napoli]], [*#text(size: 8.8pt)[2 – 1]*], [#text(fill: rgb("#2d3748"))[Viking]], [2.61 – 0.90], [74%/15%/10%],
  [2027-01-27], [#text(fill: rgb("#2d3748"))[Villarreal]], [*#text(size: 8.8pt)[1 – 1]*], [#text(fill: rgb("#2d3748"))[Manchester United]], [1.47 – 1.59], [36%/24%/40%],
  [2027-01-27], [#text(fill: rgb("#2d3748"))[Slovan Bratislava]], [*#text(size: 8.8pt)[1 – 2]*], [#text(fill: rgb("#2d3748"))[Inter Milan]], [0.90 – 2.59], [11%/15%/74%],

)
]
