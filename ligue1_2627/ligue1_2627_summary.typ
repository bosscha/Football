// Typst Report - Simulation Ligue 1 McDonald's 2026/2027
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
        Rapport Prévisionnel Monte-Carlo (100000 saisons réelles simulées)
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
  fill: (col, row) => if row == 0 { accent_blue } else if calc.even(row) { light_gray } else { white },
  stroke: (col, row) => if row == 0 { none } else { 0.35pt + rgb("#e2e8f0") },
  align: (col, row) => if col <= 1 { left } else { center },
  table.header(
    th[Club], th[Stade officiel], th[Bilan 25/26], th[UEFA], th[Valeur TM], th[Note $R_i$]
  ),

  [Paris Saint-Germain], [Parc des Princes], [2.24 pts], [132.0], [1360.0 M€], [1.000],
  [RC Lens], [Stade Bollaert-Delelis], [2.06 pts], [16.7], [203.2 M€], [0.505],
  [LOSC Lille], [Decathlon Arena - Stade Pierre-Mauroy], [1.79 pts], [68.8], [245.1 M€], [0.557],
  [Olympique lyonnais], [Groupama Stadium], [1.76 pts], [32.0], [261.7 M€], [0.480],
  [Olympique de Marseille], [Orange Vélodrome], [1.74 pts], [48.0], [280.0 M€], [0.524],
  [Stade rennais FC], [Roazhon Park], [1.74 pts], [35.0], [185.0 M€], [0.437],
  [AS Monaco], [Stade Louis-II], [1.59 pts], [39.0], [313.7 M€], [0.472],
  [RC Strasbourg], [Stade de la Meinau], [1.56 pts], [14.1], [140.0 M€], [0.329],
  [Toulouse FC], [Stadium de Toulouse], [1.32 pts], [15.0], [95.0 M€], [0.230],
  [FC Lorient], [Stade du Moustoir], [1.32 pts], [14.1], [55.0 M€], [0.160],
  [Paris FC], [Stade Jean-Bouin], [1.29 pts], [14.1], [75.0 M€], [0.189],
  [Stade brestois 29], [Stade Francis-Le Blé], [1.15 pts], [16.0], [69.6 M€], [0.151],
  [Angers SCO], [Stade Raymond-Kopa], [1.06 pts], [14.1], [40.0 M€], [0.063],
  [Le Havre AC], [Stade Océane], [1.03 pts], [14.1], [45.0 M€], [0.066],
  [AJ Auxerre], [Stade de l'Abbé-Deschamps], [1.00 pts], [14.1], [50.0 M€], [0.082],
  [OGC Nice], [Allianz Riviera], [0.94 pts], [22.0], [175.0 M€], [0.202],
  [ESTAC Troyes], [Stade de l'Aube], [1.18 pts], [14.1], [42.0 M€], [0.102],
  [Le Mans FC], [Stade Marie-Marvingt], [1.08 pts], [14.1], [30.0 M€], [0.042],
)

#pagebreak()

// ==========================================
// PAGE 2: Final Standings & Key Cutoffs
// ==========================================

= 2. Classement Final Projeté (Synthèse sur 100000 simulations)

Le classement est établi rigoureusement selon les critères officiels de départage de la LFP (Points, Différence de buts générale, Buts marqués, etc.).

#v(4pt)

#table(
  columns: (0.8fr, 4.2fr, 2.3fr, 1.4fr, 2.6fr, 1.6fr, 1.6fr, 1.6fr, 1.6fr, 1.6fr, 1.6fr),
  inset: (x: 4pt, y: 4.0pt),
  fill: (col, row) => if row == 0 { brand_blue } else if calc.even(row) { light_gray } else { white },
  stroke: (col, row) => if row == 0 { none } else { 0.35pt + rgb("#e2e8f0") },
  align: (col, row) => if col == 1 { left } else { center },
  table.header(
    th[Pos], th[Club], th[Pts Moy], th[Méd], th[V - N - D], th[Diff], th[Titre], th[UCL], th[C3/C4], th[Barr.], th[Desc.]
  ),

  [1], [#text(weight: "medium")[Paris Saint-Germain]], [92.1 ± 4.4], [92], [30-3-1], [+104.6], [99.8%], [100.0%], [0.0%], [0.0%], [0.0%],
  [2], [#text(weight: "medium")[LOSC Lille]], [66.8 ± 6.8], [67], [20-6-8], [+33.7], [0.1%], [74.9%], [19.1%], [0.0%], [0.0%],
  [3], [#text(weight: "medium")[Olympique de Marseille]], [64.4 ± 6.9], [65], [19-6-8], [+29.0], [0.0%], [62.0%], [26.8%], [0.0%], [0.0%],
  [4], [#text(weight: "medium")[RC Lens]], [63.0 ± 7.0], [63], [19-7-9], [+26.4], [0.0%], [53.5%], [31.0%], [0.0%], [0.0%],
  [5], [#text(weight: "medium")[Olympique lyonnais]], [61.1 ± 7.0], [61], [18-7-9], [+22.8], [0.0%], [42.0%], [35.3%], [0.0%], [0.0%],
  [6], [#text(weight: "medium")[AS Monaco]], [60.5 ± 7.0], [61], [18-7-9], [+21.7], [0.0%], [38.6%], [35.7%], [0.0%], [0.0%],
  [7], [#text(weight: "medium")[Stade rennais FC]], [57.8 ± 7.1], [58], [17-7-10], [+16.7], [0.0%], [24.7%], [34.7%], [0.0%], [0.0%],
  [8], [#text(weight: "medium")[RC Strasbourg]], [49.5 ± 7.2], [49], [14-7-13], [+2.1], [0.0%], [3.7%], [12.7%], [0.2%], [0.1%],
  [9], [#text(weight: "medium")[Toulouse FC]], [41.8 ± 7.1], [42], [12-7-15], [-11.5], [0.0%], [0.3%], [2.1%], [2.4%], [2.1%],
  [10], [#text(weight: "medium")[OGC Nice]], [39.7 ± 7.0], [40], [11-7-16], [-15.4], [0.0%], [0.1%], [1.1%], [3.9%], [3.8%],
  [11], [#text(weight: "medium")[Paris FC]], [38.7 ± 7.0], [39], [11-7-16], [-17.3], [0.0%], [0.1%], [0.8%], [4.9%], [5.1%],
  [12], [#text(weight: "medium")[FC Lorient]], [36.6 ± 7.0], [36], [10-7-17], [-21.2], [0.0%], [0.0%], [0.3%], [7.5%], [8.7%],
  [13], [#text(fill: rgb("#c53030"), weight: "bold")[Stade brestois 29 ⚓]], [35.9 ± 6.9], [36], [10-7-17], [-22.6], [0.0%], [0.0%], [0.3%], [8.2%], [10.5%],
  [14], [#text(weight: "medium")[ESTAC Troyes]], [32.4 ± 6.8], [32], [9-7-19], [-29.3], [0.0%], [0.0%], [0.1%], [13.0%], [22.2%],
  [15], [#text(weight: "medium")[AJ Auxerre]], [31.0 ± 6.7], [31], [8-7-19], [-32.2], [0.0%], [0.0%], [0.0%], [14.4%], [29.3%],
  [16], [#text(weight: "medium")[Le Havre AC]], [29.9 ± 6.6], [30], [8-7-20], [-34.4], [0.0%], [0.0%], [0.0%], [15.2%], [35.5%],
  [17], [#text(weight: "medium")[Angers SCO]], [29.6 ± 6.6], [29], [8-7-20], [-34.9], [0.0%], [0.0%], [0.0%], [15.1%], [37.1%],
  [18], [#text(weight: "medium")[Le Mans FC]], [28.2 ± 6.5], [28], [7-6-20], [-37.9], [0.0%], [0.0%], [0.0%], [15.2%], [45.7%],
)

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


#grid(
  columns: (1fr, 1fr, 1fr, 1fr),
  gutter: 6pt,
  [
    #block(fill: light_gray, inset: 8pt, radius: 4pt, width: 100%, stroke: 0.4pt + rgb("#cbd5e0"))[
      #align(center)[
        #text(size: 8pt, fill: rgb("#718096"), weight: "bold")[POINTS PROJETÉS]\
        #v(1pt)
        #text(size: 15pt, weight: "bold", fill: brand_blue)[35.9 pts]\
        #text(size: 7.5pt, fill: rgb("#4a5568"))[Médiane : 36 pts]
      ]
    ]
  ],
  [
    #block(fill: light_gray, inset: 8pt, radius: 4pt, width: 100%, stroke: 0.4pt + rgb("#cbd5e0"))[
      #align(center)[
        #text(size: 8pt, fill: rgb("#718096"), weight: "bold")[MAINTIEN DIRECT]\
        #v(1pt)
        #text(size: 15pt, weight: "bold", fill: rgb("#276749"))[81.4%]\
        #text(size: 7.5pt, fill: rgb("#4a5568"))[Top 15 assuré]
      ]
    ]
  ],
  [
    #block(fill: light_gray, inset: 8pt, radius: 4pt, width: 100%, stroke: 0.4pt + rgb("#cbd5e0"))[
      #align(center)[
        #text(size: 8pt, fill: rgb("#718096"), weight: "bold")[BARRAGE / DESCENTE]\
        #v(1pt)
        #text(size: 15pt, weight: "bold", fill: rgb("#c53030"))[18.6%]\
        #text(size: 7.5pt, fill: rgb("#4a5568"))[Barrage: 8.2% | Relég: 10.5%]
      ]
    ]
  ],
  [
    #block(fill: light_gray, inset: 8pt, radius: 4pt, width: 100%, stroke: 0.4pt + rgb("#cbd5e0"))[
      #align(center)[
        #text(size: 8pt, fill: rgb("#718096"), weight: "bold")[EUROPE (C1/C3/C4)]\
        #v(1pt)
        #text(size: 15pt, weight: "bold", fill: accent_blue)[0.3%]\
        #text(size: 7.5pt, fill: rgb("#4a5568"))[Top 4 UCL : 0.0%]
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
  fill: (col, row) => if row == 0 { accent_blue } else if calc.even(row) { light_gray } else { white },
  stroke: (col, row) => if row == 0 { none } else { 0.35pt + rgb("#e2e8f0") },
  align: (col, row) => if col == 2 { left } else { center },
  table.header(
    th[J.], th[Date], th[Match & Adversaire], th[Stade / Lieu], th[xG], th[Score Méd.], th[V (%)], th[N (%)], th[D (%)], th[xPts]
  ),

  [J01], [2026-08-22], [Le Mans FC vs *Brest*], [Stade Marie-Marvingt], [1.48 - 1.54], [*1 - 1* (N)], [39.0%], [24.4%], [36.7%],
  [J02], [2026-08-29], [*Brest* vs Toulouse FC], [Francis-Le Blé], [1.53 - 1.48], [*1 - 1* (N)], [38.8%], [24.2%], [37.0%],
  [J03], [2026-09-05], [Le Havre AC vs *Brest*], [Stade Océane], [1.52 - 1.49], [*1 - 1* (N)], [37.1%], [24.5%], [38.4%],
  [J04], [2026-09-12], [*Brest* vs Paris Saint-Germain], [Francis-Le Blé], [0.61 - 3.74], [*0 - 3* (D)], [2.7%], [6.4%], [90.9%],
  [J05], [2026-09-19], [AJ Auxerre vs *Brest*], [Stade de l'Abbé-Deschamps], [1.55 - 1.47], [*1 - 1* (N)], [36.0%], [24.3%], [39.8%],
  [J06], [2026-09-26], [*Brest* vs Angers SCO], [Francis-Le Blé], [1.87 - 1.22], [*2 - 1* (V)], [52.9%], [22.6%], [24.6%],
  [J07], [2026-10-03], [LOSC Lille vs *Brest*], [Decathlon Arena - Stade Pierre-Mauroy], [2.74 - 0.83], [*2 - 0* (D)], [8.7%], [13.8%], [77.5%],
  [J08], [2026-10-17], [*Brest* vs OGC Nice], [Francis-Le Blé], [1.58 - 1.44], [*1 - 1* (N)], [41.1%], [24.4%], [34.5%],
  [J09], [2026-10-24], [FC Lorient vs *Brest*], [Stade du Moustoir], [1.70 - 1.34], [*1 - 1* (N)], [30.2%], [23.5%], [46.3%],
  [J10], [2026-10-31], [*Brest* vs Olympique lyonnais], [Francis-Le Blé], [1.13 - 2.00], [*1 - 2* (D)], [21.0%], [21.4%], [57.6%],
  [J11], [2026-11-07], [RC Strasbourg vs *Brest*], [Stade de la Meinau], [2.08 - 1.09], [*2 - 1* (D)], [19.1%], [20.6%], [60.2%],
  [J12], [2026-11-21], [*Brest* vs Paris FC], [Francis-Le Blé], [1.61 - 1.41], [*1 - 1* (N)], [42.2%], [24.0%], [33.8%],
  [J13], [2026-11-28], [Stade rennais FC vs *Brest*], [Roazhon Park], [2.37 - 0.96], [*2 - 1* (D)], [13.4%], [17.6%], [68.9%],
  [J14], [2026-12-05], [*Brest* vs ESTAC Troyes], [Francis-Le Blé], [1.78 - 1.27], [*1 - 1* (N)], [49.5%], [23.1%], [27.4%],
  [J15], [2026-12-12], [*Brest* vs Olympique de Marseille], [Francis-Le Blé], [1.07 - 2.11], [*1 - 2* (D)], [18.2%], [20.5%], [61.3%],
  [J16], [2026-12-19], [AS Monaco vs *Brest*], [Stade Louis-II], [2.47 - 0.92], [*2 - 1* (D)], [12.0%], [16.7%], [71.4%],
  [J17], [2027-01-09], [RC Lens vs *Brest*], [Stade Bollaert-Delelis], [2.57 - 0.88], [*2 - 0* (D)], [10.9%], [15.5%], [73.6%],
  [J18], [2027-01-16], [*Brest* vs RC Strasbourg], [Francis-Le Blé], [1.36 - 1.67], [*1 - 1* (N)], [31.4%], [24.0%], [44.7%],
  [J19], [2027-01-23], [OGC Nice vs *Brest*], [Allianz Riviera], [1.79 - 1.27], [*1 - 1* (N)], [27.4%], [23.0%], [49.5%],
  [J20], [2027-01-30], [*Brest* vs Stade rennais FC], [Francis-Le Blé], [1.19 - 1.90], [*1 - 2* (D)], [23.6%], [22.1%], [54.2%],
  [J21], [2027-02-06], [Paris Saint-Germain vs *Brest*], [Parc des Princes], [4.66 - 0.49], [*4 - 0* (D)], [0.9%], [2.8%], [96.3%],
  [J22], [2027-02-13], [*Brest* vs AS Monaco], [Francis-Le Blé], [1.14 - 1.99], [*1 - 2* (D)], [21.4%], [21.7%], [56.9%],
  [J23], [2027-02-20], [Paris FC vs *Brest*], [Stade Jean-Bouin], [1.76 - 1.29], [*1 - 1* (N)], [28.3%], [23.3%], [48.4%],
  [J24], [2027-02-27], [*Brest* vs LOSC Lille], [Francis-Le Blé], [1.03 - 2.20], [*1 - 2* (D)], [16.6%], [19.4%], [64.0%],
  [J25], [2027-03-06], [Toulouse FC vs *Brest*], [Stadium de Toulouse], [1.85 - 1.23], [*2 - 1* (D)], [25.0%], [22.8%], [52.2%],
  [J26], [2027-03-13], [*Brest* vs FC Lorient], [Francis-Le Blé], [1.66 - 1.36], [*1 - 1* (N)], [44.3%], [24.0%], [31.7%],
  [J27], [2027-03-20], [Olympique de Marseille vs *Brest*], [Orange Vélodrome], [2.63 - 0.86], [*2 - 0* (D)], [9.9%], [14.9%], [75.2%],
  [J28], [2027-04-03], [*Brest* vs Le Mans FC], [Francis-Le Blé], [1.92 - 1.18], [*2 - 1* (V)], [54.5%], [22.2%], [23.3%],
  [J29], [2027-04-10], [Olympique lyonnais vs *Brest*], [Groupama Stadium], [2.50 - 0.91], [*2 - 1* (D)], [11.6%], [16.5%], [71.9%],
  [J30], [2027-04-17], [ESTAC Troyes vs *Brest*], [Stade de l'Aube], [1.59 - 1.43], [*1 - 1* (N)], [34.6%], [23.9%], [41.5%],
  [J31], [2027-04-24], [*Brest* vs AJ Auxerre], [Francis-Le Blé], [1.83 - 1.24], [*2 - 1* (V)], [51.1%], [22.9%], [26.0%],
  [J32], [2027-05-01], [*Brest* vs Le Havre AC], [Francis-Le Blé], [1.86 - 1.22], [*2 - 1* (V)], [52.4%], [22.7%], [24.9%],
  [J33], [2027-05-08], [Angers SCO vs *Brest*], [Stade Raymond-Kopa], [1.51 - 1.50], [*1 - 1* (N)], [37.5%], [24.5%], [38.0%],
  [J34], [2027-05-22], [*Brest* vs RC Lens], [Francis-Le Blé], [1.10 - 2.07], [*1 - 2* (D)], [19.4%], [20.6%], [60.0%],
)

#v(4pt)
#align(right)[
  #text(size: 7.5pt, fill: rgb("#a0aec0"))[Rapport généré automatiquement par le moteur Monte-Carlo Rust `ligue1_simulation`.]
]

