import json, math
import numpy as np

# 1. Load data
with open('data/teams.json') as f:
    teams = json.load(f)
with open('data/fixtures.json') as f:
    fixtures = json.load(f)

# 2. Compute ratings
coeffs = [t['uefa_coeff'] for t in teams]
min_coeff, max_coeff = min(coeffs), max(coeffs)
coeff_range = max(max_coeff - min_coeff, 1e-6)

ln_mvs = [math.log(t['market_value_eur']) for t in teams]
min_ln_mv, max_ln_mv = min(ln_mvs), max(ln_mvs)
ln_mv_range = max(max_ln_mv - min_ln_mv, 1e-6)

ytd_scores = []
for t in teams:
    ppg = min(max(t['ytd']['ppg'] / 3.0, 0.0), 1.0)
    wr = min(max(t['ytd']['win_rate'], 0.0), 1.0)
    gd = min(max((t['ytd']['gd_pg'] + 1.5) / 4.0, 0.0), 1.0)
    ytd_scores.append(0.50 * ppg + 0.30 * wr + 0.20 * gd)

min_ytd, max_ytd = min(ytd_scores), max(ytd_scores)
ytd_range = max(max_ytd - min_ytd, 1e-6)

w_u, w_m, w_y = 0.25, 0.50, 0.25
total_w = w_u + w_m + w_y
norm_u, norm_m, norm_y = w_u / total_w, w_m / total_w, w_y / total_w

ratings = {}
for i, t in enumerate(teams):
    s_u = (t['uefa_coeff'] - min_coeff) / coeff_range
    s_m = (math.log(t['market_value_eur']) - min_ln_mv) / ln_mv_range
    s_y = (ytd_scores[i] - min_ytd) / ytd_range
    ratings[t['name']] = norm_u * s_u + norm_m * s_m + norm_y * s_y

# 3. Simulate 100,000 runs per fixture for empirical median & stats
np.random.seed(42)
N_SIMS = 100000

matches_by_day = {d: [] for d in range(1, 9)}
special_matches = []

highlight_teams = {'Paris Saint-Germain', 'Lille', 'Lens', 'Barcelona'}

def format_team(name):
    display = name
    if name == 'Barcelona':
        display = 'FC Barcelone'
    elif name == 'Lille':
        display = 'Lille OSC'
    elif name == 'Lens':
        display = 'RC Lens'
    elif name == 'Paris Saint-Germain':
        display = 'Paris Saint-Germain'
    
    if name in highlight_teams:
        return f'*#text(fill: rgb("#1a365d"))[{display}]*'
    else:
        return f'#text(fill: rgb("#2d3748"))[{display}]'

for fix in fixtures:
    h = fix['home_team']
    a = fix['away_team']
    diff = ratings[h] - ratings[a]
    
    lh = min(max(1.35 * math.exp(0.25 + 1.25 * diff), 0.1), 8.0)
    la = min(max(1.35 * math.exp(-1.25 * diff), 0.1), 8.0)
    
    gh = np.random.poisson(lh, N_SIMS)
    ga = np.random.poisson(la, N_SIMS)
    
    med_h = int(np.median(gh))
    med_a = int(np.median(ga))
    
    p_win = np.mean(gh > ga) * 100
    p_draw = np.mean(gh == ga) * 100
    p_loss = np.mean(gh < ga) * 100
    
    m_data = {
        'matchday': fix['matchday'],
        'date': fix['date'],
        'home_raw': h,
        'away_raw': a,
        'home_fmt': format_team(h),
        'away_fmt': format_team(a),
        'med_h': med_h,
        'med_a': med_a,
        'lh': lh,
        'la': la,
        'p_win': p_win,
        'p_draw': p_draw,
        'p_loss': p_loss,
        'is_special': (h in highlight_teams or a in highlight_teams)
    }
    matches_by_day[fix['matchday']].append(m_data)
    if m_data['is_special']:
        special_matches.append(m_data)

lines = []
lines.append('''#set document(
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
''')

for m in special_matches:
    j = f"J{m['matchday']}"
    d = m['date'][5:]  # MM-DD
    score = f"*#text(size: 8.8pt)[{m['med_h']} – {m['med_a']}]*"
    xg = f"{m['lh']:.2f} – {m['la']:.2f}"
    prob = f"{m['p_win']:.0f}%/{m['p_draw']:.0f}%/{m['p_loss']:.0f}%"
    lines.append(f"  [{j}], [{d}], [{m['home_fmt']}], [{score}], [{m['away_fmt']}], [{xg}], [{prob}],\n")

lines.append('''
)
]

#pagebreak()
''')

day_pairs = [(1, 2), (3, 4), (5, 6), (7, 8)]

for p_idx, (d1, d2) in enumerate(day_pairs):
    lines.append(f'''
== Calendrier Officiel — Journées {d1} et {d2}

=== Journée {d1}
#align(center)[
#table(
  columns: (38pt, 142pt, 46pt, 142pt, 50pt, 66pt),
  stroke: (x, y) => if y == 0 {{ 1pt + rgb("#2b6cb0") }} else {{ 0.4pt + rgb("#e2e8f0") }},
  fill: (col, row) => {{
    if row == 0 {{ rgb("#edf2f7") }}
    else if calc.odd(row) {{ rgb("#f7fafc") }}
    else {{ none }}
  }},
  inset: (x: 2.5pt, y: 1.8pt),
  align: (col, row) => (
    if col in (0, 2, 4, 5) {{ center }}
    else if col == 1 {{ right }}
    else {{ left }}
  ),
  table.header(
    [*Date*], [*Équipe Domicile*], [*Médian*], [*Équipe Extérieure*], [*xG Esp.*], [*1 / N / 2*]
  ),
''')
    for m in matches_by_day[d1]:
        d = m['date']
        score = f"*#text(size: 8.8pt)[{m['med_h']} – {m['med_a']}]*"
        xg = f"{m['lh']:.2f} – {m['la']:.2f}"
        prob = f"{m['p_win']:.0f}%/{m['p_draw']:.0f}%/{m['p_loss']:.0f}%"
        lines.append(f"  [{d}], [{m['home_fmt']}], [{score}], [{m['away_fmt']}], [{xg}], [{prob}],\n")

    lines.append(f'''
)
]

#v(0.08cm)

=== Journée {d2}
#align(center)[
#table(
  columns: (38pt, 142pt, 46pt, 142pt, 50pt, 66pt),
  stroke: (x, y) => if y == 0 {{ 1pt + rgb("#2b6cb0") }} else {{ 0.4pt + rgb("#e2e8f0") }},
  fill: (col, row) => {{
    if row == 0 {{ rgb("#edf2f7") }}
    else if calc.odd(row) {{ rgb("#f7fafc") }}
    else {{ none }}
  }},
  inset: (x: 2.5pt, y: 1.8pt),
  align: (col, row) => (
    if col in (0, 2, 4, 5) {{ center }}
    else if col == 1 {{ right }}
    else {{ left }}
  ),
  table.header(
    [*Date*], [*Équipe Domicile*], [*Médian*], [*Équipe Extérieure*], [*xG Esp.*], [*1 / N / 2*]
  ),
''')
    for m in matches_by_day[d2]:
        d = m['date']
        score = f"*#text(size: 8.8pt)[{m['med_h']} – {m['med_a']}]*"
        xg = f"{m['lh']:.2f} – {m['la']:.2f}"
        prob = f"{m['p_win']:.0f}%/{m['p_draw']:.0f}%/{m['p_loss']:.0f}%"
        lines.append(f"  [{d}], [{m['home_fmt']}], [{score}], [{m['away_fmt']}], [{xg}], [{prob}],\n")

    lines.append('''
)
]
''')
    if p_idx < len(day_pairs) - 1:
        lines.append('\n#pagebreak()\n')

with open('ucl_2627_fixtures_report.typ', 'w') as f:
    f.writelines(lines)

print('ucl_2627_fixtures_report.typ generated successfully!')
