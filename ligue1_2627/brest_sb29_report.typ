// Rapport Exhaustif Stade Brestois 29 - Ligue 1 2026/2027
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
        Modélisation Monte-Carlo (1000000 saisons simulées) | Calendrier Officiel LFP (34 journées) | Modèle Bilan 25/26, UEFA & Transfermarkt
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
        #text(size: 11pt, weight: "bold", fill: dark_navy)[69.6 M€]\
        #text(size: 7pt, fill: rgb("#4a5568"))[Transfermarkt (12e L1)]
      ]
    ]
  ],
  [
    #block(fill: light_bg, inset: 6pt, radius: 4pt, stroke: 0.4pt + border_color, width: 100%)[
      #align(center)[
        #text(size: 7.5pt, fill: rgb("#718096"), weight: "bold")[INDICE UEFA 2026]\
        #text(size: 11pt, weight: "bold", fill: dark_navy)[16.0 pts]\
        #text(size: 7pt, fill: rgb("#4a5568"))[Campagne UCL capitalisée]
      ]
    ]
  ],
  [
    #block(fill: light_bg, inset: 6pt, radius: 4pt, stroke: 0.4pt + border_color, width: 100%)[
      #align(center)[
        #text(size: 7.5pt, fill: rgb("#718096"), weight: "bold")[BILAN 2025/2026]\
        #text(size: 11pt, weight: "bold", fill: dark_navy)[1.15 PPG]\
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
      - *Points Moyens* : *35.9 ± 6.9 pts*
      - *Médiane* : *36 pts*
      - *Intervalle 80% (P10 - P90)* : [27 - 45 pts]
      - *Intervalle 50% (P25 - P75)* : [31 - 41 pts]
      - *Victoires / Nuls / Déf.* : *9.6V - 7.0N - 17.4D*
      - *Buts marqués / concédés* : *43.8 BP / 66.3 BC*
      - *Différence de buts moyenne* : *-22.5*
    ]
  ],
  [
    #block(fill: light_bg, inset: 8pt, radius: 4pt, stroke: 0.4pt + border_color, width: 100%)[
      #text(weight: "bold", fill: dark_navy)[Splits Domicile vs Extérieur]\
      #v(2pt)
      - *Francis-Le Blé (17 matchs)* :
        - Points : *21.1 pts* (65% du total)
        - Bilan : *5.8V - 3.7N - 7.5D*
        - Buts : *24.3 BP / 29.5 BC* (-5.2)
      - *À l'Extérieur (17 matchs)* :
        - Points : *14.8 pts* (35% du total)
        - Bilan : *3.8V - 3.3N - 9.9D*
        - Buts : *19.5 BP / 36.8 BC* (-17.3)
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
        [*Maintien Direct (1-15)*], [*81.5%*], [#text(fill: win_green, weight: "bold")[Favorable]],
        [*Barrage (16e place)*], [*8.2%*], [#text(fill: rgb("#d69e2e"), weight: "bold")[Alerte]],
        [*Relégation (17-18e)*], [*10.3%*], [#text(fill: loss_red, weight: "bold")[Risque]],
        [*Total Risque Relég.*], [*18.5%*], [#text(fill: dark_navy)[(Barr. + Rel.)]],
        [*Top 10 Ligue 1*], [*22.5%*], [#text(fill: accent_blue)[Première moitié]],
        [*Europe (Top 6 C1-C4)*], [*0.3%*], [#text(fill: accent_blue)[Accessits]],
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
      fill: (col, row) => if row == 0 { dark_navy } else if calc.even(row) { light_bg } else { white },
      stroke: (col, row) => if row == 0 { none } else { 0.3pt + rgb("#e2e8f0") },
      align: (col, row) => if col == 3 { left } else { center },
      table.header(th[Place], th[Prob.], th[Cumul], th[Statut]),

      [1e], [0.00%], [0.0%], [Champion L1],
      [2e], [0.00%], [0.0%], [Phase Ligue UCL],
      [3e], [0.00%], [0.0%], [Phase Ligue UCL],
      [4e], [0.02%], [0.0%], [Tour prélim. UCL],
      [5e], [0.06%], [0.1%], [Ligue Europa (C3)],
      [6e], [0.22%], [0.3%], [Ligue Confér. (C4)],
      [7e], [0.84%], [1.1%], [Milieu haut],
      [8e], [3.27%], [4.4%], [Milieu haut],
      [9e], [7.60%], [12.0%], [Milieu haut],
      [10e], [10.52%], [22.5%], [Milieu haut],
      [11e], [12.22%], [34.8%], [Maintien direct],
      [#text(fill: brest_red, weight: "bold")[12e ★]], [12.79%], [47.5%], [Maintien direct],
      [13e], [12.54%], [60.1%], [Maintien direct],
      [14e], [11.45%], [71.5%], [Maintien direct],
      [15e], [9.93%], [81.5%], [Maintien direct],
      [16e], [8.22%], [89.7%], [Barragiste (L2)],
      [17e], [6.21%], [95.9%], [Relégation directe],
      [18e], [4.10%], [100.0%], [Relégation directe],
    )
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
  fill: (col, row) => if row == 0 { dark_navy } else if calc.even(row) { light_bg } else { white },
  stroke: (col, row) => if row == 0 { none } else { 0.3pt + rgb("#e2e8f0") },
  align: (col, row) => if col == 2 { left } else { center },
  table.header(
    th[J.], th[Date], th[Affiche (D/E)], th[Stade / Lieu], th[xG], th[Score Méd.], th[Score Mode (%)], th[V (%)], th[N (%)], th[D (%)], th[xPts], th[Cumul]
  ),

  [J01], [2026-08-22], [Le Mans FC vs *Brest* (E)], [Stade Marie-Marvingt], [1.48–1.54], [*1 - 1* (N)], [1 - 1 (11.2%)], [39.3%], [24.2%], [36.5%], [1.42], [1.4], 
  [J02], [2026-08-29], [*Brest* vs Toulouse FC (D)], [Francis-Le Blé], [1.53–1.48], [*1 - 1* (N)], [1 - 1 (11.1%)], [39.0%], [24.2%], [36.8%], [1.41], [2.8], 
  [J03], [2026-09-05], [Le Havre AC vs *Brest* (E)], [Stade Océane], [1.52–1.49], [*1 - 1* (N)], [1 - 1 (11.2%)], [37.4%], [24.2%], [38.4%], [1.36], [4.2], 
  [J04], [2026-09-12], [*Brest* vs Paris Saint-Germain (D)], [Francis-Le Blé], [0.61–3.74], [*0 - 3* (D)], [0 - 3 (11.3%)], [2.6%], [6.4%], [91.0%], [0.14], [4.3], 
  [J05], [2026-09-19], [AJ Auxerre vs *Brest* (E)], [Stade de l'Abbé-Deschamps], [1.55–1.47], [*1 - 1* (N)], [1 - 1 (11.1%)], [36.1%], [24.2%], [39.8%], [1.32], [5.7], 
  [J06], [2026-09-26], [*Brest* vs Angers SCO (D)], [Francis-Le Blé], [1.87–1.22], [*2 - 1* (V)], [1 - 1 (10.4%)], [52.7%], [22.5%], [24.7%], [1.81], [7.5], 
  [J07], [2026-10-03], [LOSC Lille vs *Brest* (E)], [Decathlon Arena - Stade Pierre-Mauroy], [2.74–0.83], [*2 - 0* (D)], [2 - 0 (10.6%)], [8.7%], [14.0%], [77.3%], [0.40], [7.9], 
  [J08], [2026-10-17], [*Brest* vs OGC Nice (D)], [Francis-Le Blé], [1.58–1.44], [*1 - 1* (N)], [1 - 1 (11.1%)], [41.1%], [24.1%], [34.8%], [1.47], [9.3], 
  [J09], [2026-10-24], [FC Lorient vs *Brest* (E)], [Stade du Moustoir], [1.70–1.34], [*1 - 1* (N)], [1 - 1 (10.9%)], [30.2%], [23.6%], [46.2%], [1.14], [10.5], 
  [J10], [2026-10-31], [*Brest* vs Olympique lyonnais (D)], [Francis-Le Blé], [1.13–2.00], [*1 - 2* (D)], [1 - 2 (9.9%)], [21.0%], [21.5%], [57.6%], [0.84], [11.3], 
  [J11], [2026-11-07], [RC Strasbourg vs *Brest* (E)], [Stade de la Meinau], [2.08–1.09], [*2 - 1* (D)], [2 - 1 (9.9%)], [19.1%], [20.7%], [60.3%], [0.78], [12.1], 
  [J12], [2026-11-21], [*Brest* vs Paris FC (D)], [Francis-Le Blé], [1.61–1.41], [*1 - 1* (N)], [1 - 1 (11.0%)], [42.3%], [24.0%], [33.7%], [1.51], [13.6], 
  [J13], [2026-11-28], [Stade rennais FC vs *Brest* (E)], [Roazhon Park], [2.37–0.96], [*2 - 1* (D)], [2 - 0 (10.0%)], [13.6%], [17.7%], [68.7%], [0.58], [14.2], 
  [J14], [2026-12-05], [*Brest* vs ESTAC Troyes (D)], [Francis-Le Blé], [1.78–1.27], [*1 - 1* (N)], [1 - 1 (10.7%)], [49.5%], [23.2%], [27.3%], [1.72], [15.9], 
  [J15], [2026-12-12], [*Brest* vs Olympique de Marseille (D)], [Francis-Le Blé], [1.07–2.11], [*1 - 2* (D)], [1 - 2 (9.9%)], [18.4%], [20.4%], [61.2%], [0.76], [16.7], 
  [J16], [2026-12-19], [AS Monaco vs *Brest* (E)], [Stade Louis-II], [2.47–0.92], [*2 - 1* (D)], [2 - 0 (10.3%)], [12.0%], [16.6%], [71.5%], [0.52], [17.2], 
  [J17], [2027-01-09], [RC Lens vs *Brest* (E)], [Stade Bollaert-Delelis], [2.57–0.88], [*2 - 0* (D)], [2 - 0 (10.4%)], [10.6%], [15.5%], [73.8%], [0.47], [17.7], 
)

#v(6pt)
#block(fill: light_bg, inset: 9pt, radius: 4pt, stroke: 0.4pt + border_color, width: 100%)[
  *Bilan Intermédiaire à la Mi-Saison (Journée 17) :*
  - *Espérance de points cumulés* : *17.7 points* à mi-parcours (fourchette habituelle de maintien à mi-saison : 17-20 pts).
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
  fill: (col, row) => if row == 0 { dark_navy } else if calc.even(row) { light_bg } else { white },
  stroke: (col, row) => if row == 0 { none } else { 0.3pt + rgb("#e2e8f0") },
  align: (col, row) => if col == 2 { left } else { center },
  table.header(
    th[J.], th[Date], th[Affiche (D/E)], th[Stade / Lieu], th[xG], th[Score Méd.], th[Score Mode (%)], th[V (%)], th[N (%)], th[D (%)], th[xPts], th[Cumul]
  ),

  [J18], [2027-01-16], [*Brest* vs RC Strasbourg (D)], [Francis-Le Blé], [1.36–1.67], [*1 - 1* (N)], [1 - 1 (10.9%)], [31.2%], [23.8%], [45.0%], [1.17], [18.9], 
  [J19], [2027-01-23], [OGC Nice vs *Brest* (E)], [Allianz Riviera], [1.27–1.79], [*1 - 1* (N)], [1 - 1 (10.6%)], [27.2%], [23.2%], [49.6%], [1.05], [19.9], 
  [J20], [2027-01-30], [*Brest* vs Stade rennais FC (D)], [Francis-Le Blé], [1.19–1.90], [*1 - 2* (D)], [1 - 1 (10.3%)], [23.8%], [22.4%], [53.8%], [0.94], [20.8], 
  [J21], [2027-02-06], [Paris Saint-Germain vs *Brest* (E)], [Parc des Princes], [0.49–4.66], [*4 - 0* (D)], [7 - 0 (11.7%)], [0.9%], [2.9%], [96.2%], [0.06], [20.9], 
  [J22], [2027-02-13], [*Brest* vs AS Monaco (D)], [Francis-Le Blé], [1.14–1.99], [*1 - 2* (D)], [1 - 1 (9.9%)], [21.5%], [21.6%], [56.9%], [0.86], [21.8], 
  [J23], [2027-02-20], [Paris FC vs *Brest* (E)], [Stade Jean-Bouin], [1.29–1.76], [*1 - 1* (N)], [1 - 1 (10.7%)], [28.1%], [23.3%], [48.6%], [1.08], [22.8], 
  [J24], [2027-02-27], [*Brest* vs LOSC Lille (D)], [Francis-Le Blé], [1.03–2.20], [*1 - 2* (D)], [1 - 2 (9.9%)], [16.6%], [19.5%], [63.8%], [0.69], [23.5], 
  [J25], [2027-03-06], [Toulouse FC vs *Brest* (E)], [Stadium de Toulouse], [1.23–1.85], [*2 - 1* (D)], [1 - 1 (10.5%)], [25.3%], [22.7%], [52.0%], [0.99], [24.5], 
  [J26], [2027-03-13], [*Brest* vs FC Lorient (D)], [Francis-Le Blé], [1.66–1.36], [*1 - 1* (N)], [1 - 1 (11.0%)], [44.5%], [23.9%], [31.5%], [1.58], [26.1], 
  [J27], [2027-03-20], [Olympique de Marseille vs *Brest* (E)], [Orange Vélodrome], [0.86–2.63], [*2 - 0* (D)], [2 - 0 (10.5%)], [9.9%], [15.0%], [75.1%], [0.45], [26.5], 
  [J28], [2027-04-03], [*Brest* vs Le Mans FC (D)], [Francis-Le Blé], [1.92–1.18], [*2 - 1* (V)], [1 - 1 (10.2%)], [54.5%], [22.1%], [23.3%], [1.86], [28.4], 
  [J29], [2027-04-10], [Olympique lyonnais vs *Brest* (E)], [Groupama Stadium], [0.91–2.50], [*2 - 1* (D)], [2 - 0 (10.4%)], [11.7%], [16.3%], [72.0%], [0.51], [28.9], 
  [J30], [2027-04-17], [ESTAC Troyes vs *Brest* (E)], [Stade de l'Aube], [1.43–1.59], [*1 - 1* (N)], [1 - 1 (11.1%)], [34.6%], [24.1%], [41.3%], [1.28], [30.2], 
  [J31], [2027-04-24], [*Brest* vs AJ Auxerre (D)], [Francis-Le Blé], [1.83–1.24], [*2 - 1* (V)], [1 - 1 (10.6%)], [51.1%], [23.0%], [26.0%], [1.76], [31.9], 
  [J32], [2027-05-01], [*Brest* vs Le Havre AC (D)], [Francis-Le Blé], [1.86–1.22], [*2 - 1* (V)], [1 - 1 (10.5%)], [52.3%], [22.8%], [24.9%], [1.80], [33.7], 
  [J33], [2027-05-08], [Angers SCO vs *Brest* (E)], [Stade Raymond-Kopa], [1.50–1.51], [*1 - 1* (N)], [1 - 1 (11.2%)], [37.6%], [24.2%], [38.2%], [1.37], [35.1], 
  [J34], [2027-05-22], [*Brest* vs RC Lens (D)], [Francis-Le Blé], [1.10–2.07], [*1 - 2* (D)], [1 - 2 (9.9%)], [19.6%], [20.9%], [59.6%], [0.80], [35.9], 
)

#v(6pt)
#block(fill: light_bg, inset: 9pt, radius: 4pt, stroke: 0.4pt + border_color, width: 100%)[
  *Analyse du Sprint Final (Journées 29 à 34) :*
  - *Total cumulé projeté en fin de saison* : *35.9 points* (conforme à la moyenne Monte-Carlo de 35.9 pts).
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
  fill: (col, row) => if row == 0 { dark_navy } else if calc.even(row) { light_bg } else { white },
  stroke: (col, row) => if row == 0 { none } else { 0.3pt + rgb("#e2e8f0") },
  align: (col, row) => if col == 0 { left } else { center },
  table.header(
    th[Adversaire], th[Match Aller], th[Match Retour], th[xPts / 6 pts], th[Diagnostic Stratégique]
  ),

  [Le Mans FC], [J01 (E) Méd. 1-1 (N)], [J28 (D) Méd. 2-1 (V)], [*3.28*], [#text(fill: win_green, weight: "bold")[Opportunité majeure (6 pts ciblés)]],
  [Angers SCO], [J06 (D) Méd. 2-1 (V)], [J33 (E) Méd. 1-1 (N)], [*3.18*], [#text(fill: accent_blue, weight: "medium")[Concurrent direct / Équilibré]],
  [Le Havre AC], [J03 (E) Méd. 1-1 (N)], [J32 (D) Méd. 2-1 (V)], [*3.16*], [#text(fill: accent_blue, weight: "medium")[Concurrent direct / Équilibré]],
  [AJ Auxerre], [J05 (E) Méd. 1-1 (N)], [J31 (D) Méd. 2-1 (V)], [*3.09*], [#text(fill: accent_blue, weight: "medium")[Concurrent direct / Équilibré]],
  [ESTAC Troyes], [J14 (D) Méd. 1-1 (N)], [J30 (E) Méd. 1-1 (N)], [*2.99*], [#text(fill: accent_blue, weight: "medium")[Concurrent direct / Équilibré]],
  [FC Lorient], [J09 (E) Méd. 1-1 (N)], [J26 (D) Méd. 1-1 (N)], [*2.72*], [#text(fill: accent_blue, weight: "medium")[Concurrent direct / Équilibré]],
  [Paris FC], [J12 (D) Méd. 1-1 (N)], [J23 (E) Méd. 1-1 (N)], [*2.59*], [#text(fill: accent_blue, weight: "medium")[Concurrent direct / Équilibré]],
  [OGC Nice], [J08 (D) Méd. 1-1 (N)], [J19 (E) Méd. 1-1 (N)], [*2.52*], [#text(fill: accent_blue, weight: "medium")[Concurrent direct / Équilibré]],
  [Toulouse FC], [J02 (D) Méd. 1-1 (N)], [J25 (E) Méd. 1-2 (D)], [*2.40*], [#text(fill: rgb("#d69e2e"))[Adversaire supérieur / Défi]],
  [RC Strasbourg], [J11 (E) Méd. 1-2 (D)], [J18 (D) Méd. 1-1 (N)], [*1.95*], [#text(fill: rgb("#d69e2e"))[Adversaire supérieur / Défi]],
  [Stade rennais FC], [J13 (E) Méd. 1-2 (D)], [J20 (D) Méd. 1-2 (D)], [*1.52*], [#text(fill: loss_red)[Cador européen / Match difficile]],
  [AS Monaco], [J16 (E) Méd. 1-2 (D)], [J22 (D) Méd. 1-2 (D)], [*1.39*], [#text(fill: loss_red)[Cador européen / Match difficile]],
  [Olympique lyonnais], [J10 (D) Méd. 1-2 (D)], [J29 (E) Méd. 1-2 (D)], [*1.36*], [#text(fill: loss_red)[Cador européen / Match difficile]],
  [RC Lens], [J17 (E) Méd. 0-2 (D)], [J34 (D) Méd. 1-2 (D)], [*1.27*], [#text(fill: loss_red)[Cador européen / Match difficile]],
  [Olympique de Marseille], [J15 (D) Méd. 1-2 (D)], [J27 (E) Méd. 0-2 (D)], [*1.20*], [#text(fill: loss_red)[Cador européen / Match difficile]],
  [LOSC Lille], [J07 (E) Méd. 0-2 (D)], [J24 (D) Méd. 1-2 (D)], [*1.09*], [#text(fill: loss_red)[Cador européen / Match difficile]],
  [Paris Saint-Germain], [J04 (D) Méd. 0-3 (D)], [J21 (E) Méd. 0-4 (D)], [*0.20*], [#text(fill: loss_red)[Cador européen / Match difficile]],
)

#v(8pt)
== 5.2 Baromètre du Maintien : Probabilité de Survie par Palier de Points

La table ci-dessous calcule la probabilité empirique pour le Stade Brestois 29 de se maintenir directement dans l'élite (places 1 à 15), d'être barragiste (16e) ou d'être relégué (17e-18e) selon le total de points atteint à l'issue des 34 journées :

#v(2pt)

#table(
  columns: (2fr, 2.5fr, 2.5fr, 2.5fr, 3.5fr),
  inset: (x: 5pt, y: 3.8pt),
  fill: (col, row) => if row == 0 { dark_navy } else if calc.even(row) { light_bg } else { white },
  stroke: (col, row) => if row == 0 { none } else { 0.3pt + rgb("#e2e8f0") },
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

