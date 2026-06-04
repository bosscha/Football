module Tournament

using ..Teams
using ..Model
using Random

export GroupStanding, GroupResults, run_group_stage, get_advancing_teams, run_knockout_stage, run_tournament

struct GroupStanding
    team::Team
    points::Int
    goals_scored::Int
    goals_conceded::Int
    goal_difference::Int
end

struct GroupResults
    standings::Vector{GroupStanding}
end

# Compare two standings to rank them
function compare_standings(a::GroupStanding, b::GroupStanding)
    if a.points != b.points
        return a.points > b.points
    elseif a.goal_difference != b.goal_difference
        return a.goal_difference > b.goal_difference
    elseif a.goals_scored != b.goals_scored
        return a.goals_scored > b.goals_scored
    else
        # Tie breaker: FIFA points
        return a.team.fifa_points > b.team.fifa_points
    end
end

# Run a group stage for all 12 groups
function run_group_stage(teams::Vector{Team}, off::Dict{String, Float64}, def::Dict{String, Float64})
    # Group teams by their group letters
    groups_dict = Dict{String, Vector{Team}}()
    for t in teams
        if !haskey(groups_dict, t.group)
            groups_dict[t.group] = Team[]
        end
        push!(groups_dict[t.group], t)
    end
    
    standings_dict = Dict{String, GroupResults}()
    
    for (group_name, group_teams) in groups_dict
        # Initialize stats
        pts = Dict(t.name => 0 for t in group_teams)
        gs = Dict(t.name => 0 for t in group_teams)
        gc = Dict(t.name => 0 for t in group_teams)
        
        # Round robin: 6 matches
        n = length(group_teams)
        for i in 1:n
            for j in (i+1):n
                ta = group_teams[i]
                tb = group_teams[j]
                
                res = simulate_match(ta, tb, off, def, knockout=false)
                
                # Update goals
                gs[ta.name] += res.goals_a
                gc[ta.name] += res.goals_b
                gs[tb.name] += res.goals_b
                gc[tb.name] += res.goals_a
                
                # Update points
                if res.winner == 1
                    pts[ta.name] += 3
                elseif res.winner == 2
                    pts[tb.name] += 3
                else
                    pts[ta.name] += 1
                    pts[tb.name] += 1
                end
            end
        end
        
        # Build standings
        standings = GroupStanding[]
        for t in group_teams
            g_diff = gs[t.name] - gc[t.name]
            push!(standings, GroupStanding(t, pts[t.name], gs[t.name], gc[t.name], g_diff))
        end
        
        # Sort standings
        sort!(standings, lt=compare_standings)
        standings_dict[group_name] = GroupResults(standings)
    end
    
    return standings_dict
end

# Backtracking algorithm to match 3rd place teams against group winners
# group_winners = [1E, 1I, 1A, 1L, 1G, 1D, 1B, 1K]
# third_places = 8 qualified third place teams
function match_3rd_places(group_winners::Vector{Team}, third_places::Vector{Team})
    assigned = Vector{Team}(undef, 8)
    visited = zeros(Bool, 8)
    
    function backtrack(idx)
        if idx > 8
            return true
        end
        for i in 1:8
            if !visited[i]
                if third_places[i].group != group_winners[idx].group
                    assigned[idx] = third_places[i]
                    visited[i] = true
                    if backtrack(idx + 1)
                        return true
                    end
                    visited[i] = false
                end
            end
        end
        return false
    end
    
    if backtrack(1)
        return assigned
    else
        # Sequential fallback if no combination avoids matching team from same group
        return third_places
    end
end

# Get the advancing 32 teams from group stage
function get_advancing_teams(standings_dict::Dict{String, GroupResults})
    top2_dict = Dict{String, Vector{Team}}() # group -> [1st, 2nd]
    all_3rd_standings = GroupStanding[]
    
    groups = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L"]
    
    for g in groups
        g_results = standings_dict[g]
        top2_dict[g] = [g_results.standings[1].team, g_results.standings[2].team]
        push!(all_3rd_standings, g_results.standings[3])
    end
    
    # Sort all 3rd place teams to find the top 8
    sort!(all_3rd_standings, lt=compare_standings)
    
    top8_3rd_teams = [g_std.team for g_std in all_3rd_standings[1:8]]
    
    return top2_dict, top8_3rd_teams
end

# Run the knockout stage
# Returns a log of all matches played, plus the final standings/ranking
function run_knockout_stage(top2_dict::Dict{String, Vector{Team}}, top8_3rd::Vector{Team}, off::Dict{String, Float64}, def::Dict{String, Float64})
    # Group Winners (1st place)
    w_A = top2_dict["A"][1]; w_B = top2_dict["B"][1]; w_C = top2_dict["C"][1]; w_D = top2_dict["D"][1]
    w_E = top2_dict["E"][1]; w_F = top2_dict["F"][1]; w_G = top2_dict["G"][1]; w_H = top2_dict["H"][1]
    w_I = top2_dict["I"][1]; w_J = top2_dict["J"][1]; w_K = top2_dict["K"][1]; w_L = top2_dict["L"][1]
    
    # Group Runners-up (2nd place)
    r_A = top2_dict["A"][2]; r_B = top2_dict["B"][2]; r_C = top2_dict["C"][2]; r_D = top2_dict["D"][2]
    r_E = top2_dict["E"][2]; r_F = top2_dict["F"][2]; r_G = top2_dict["G"][2]; r_H = top2_dict["H"][2]
    r_I = top2_dict["I"][2]; r_J = top2_dict["J"][2]; r_K = top2_dict["K"][2]; r_L = top2_dict["L"][2]
    
    # Match the 3rd place teams against group winners [1E, 1I, 1A, 1L, 1G, 1D, 1B, 1K]
    winners_for_3rd = [w_E, w_I, w_A, w_L, w_G, w_D, w_B, w_K]
    matched_3rd = match_3rd_places(winners_for_3rd, top8_3rd)
    
    t3_E = matched_3rd[1] # Plays Winner E
    t3_I = matched_3rd[2] # Plays Winner I
    t3_A = matched_3rd[3] # Plays Winner A
    t3_L = matched_3rd[4] # Plays Winner L
    t3_G = matched_3rd[5] # Plays Winner G
    t3_D = matched_3rd[6] # Plays Winner D
    t3_B = matched_3rd[7] # Plays Winner B
    t3_K = matched_3rd[8] # Plays Winner K
    
    # --- Round of 32 ---
    r32_matches = [
        (r_A, r_B),   # Match 1
        (w_C, r_F),   # Match 2
        (w_E, t3_E),  # Match 3
        (w_F, r_C),   # Match 4
        (r_E, r_I),   # Match 5
        (w_I, t3_I),  # Match 6
        (w_A, t3_A),  # Match 7
        (w_L, t3_L),  # Match 8
        (w_G, t3_G),  # Match 9
        (w_D, t3_D),  # Match 10
        (w_H, r_J),   # Match 11
        (r_K, r_L),   # Match 12
        (w_B, t3_B),  # Match 13
        (r_D, r_G),   # Match 14
        (w_J, r_H),   # Match 15
        (w_K, t3_K)   # Match 16
    ]
    
    r32_winners = Team[]
    match_log = Dict{String, Any}[]
    
    for (idx, (ta, tb)) in enumerate(r32_matches)
        res = simulate_match(ta, tb, off, def, knockout=true)
        winner = res.winner == 1 ? ta : tb
        push!(r32_winners, winner)
        
        push!(match_log, Dict(
            "stage" => "R32",
            "team_a" => ta.name,
            "team_b" => tb.name,
            "goals_a" => res.goals_a,
            "goals_b" => res.goals_b,
            "reg_goals_a" => res.regular_goals_a,
            "reg_goals_b" => res.regular_goals_b,
            "ext_goals_a" => res.extra_goals_a,
            "ext_goals_b" => res.extra_goals_b,
            "pen_goals_a" => res.penalties_a,
            "pen_goals_b" => res.penalties_b,
            "winner" => winner.name
        ))
    end
    
    # --- Round of 16 ---
    # Match 1 winner vs Match 2 winner, etc.
    r16_pairings = [
        (r32_winners[1], r32_winners[2]),   # R16 M1
        (r32_winners[3], r32_winners[4]),   # R16 M2
        (r32_winners[5], r32_winners[6]),   # R16 M3
        (r32_winners[7], r32_winners[8]),   # R16 M4
        (r32_winners[9], r32_winners[10]),  # R16 M5
        (r32_winners[11], r32_winners[12]), # R16 M6
        (r32_winners[13], r32_winners[14]), # R16 M7
        (r32_winners[15], r32_winners[16])  # R16 M8
    ]
    
    r16_winners = Team[]
    for (idx, (ta, tb)) in enumerate(r16_pairings)
        res = simulate_match(ta, tb, off, def, knockout=true)
        winner = res.winner == 1 ? ta : tb
        push!(r16_winners, winner)
        
        push!(match_log, Dict(
            "stage" => "R16",
            "team_a" => ta.name,
            "team_b" => tb.name,
            "goals_a" => res.goals_a,
            "goals_b" => res.goals_b,
            "reg_goals_a" => res.regular_goals_a,
            "reg_goals_b" => res.regular_goals_b,
            "ext_goals_a" => res.extra_goals_a,
            "ext_goals_b" => res.extra_goals_b,
            "pen_goals_a" => res.penalties_a,
            "pen_goals_b" => res.penalties_b,
            "winner" => winner.name
        ))
    end
    
    # --- Quarterfinals ---
    qf_pairings = [
        (r16_winners[1], r16_winners[2]),   # QF 1
        (r16_winners[3], r16_winners[4]),   # QF 2
        (r16_winners[5], r16_winners[6]),   # QF 3
        (r16_winners[7], r16_winners[8])    # QF 4
    ]
    
    qf_winners = Team[]
    for (idx, (ta, tb)) in enumerate(qf_pairings)
        res = simulate_match(ta, tb, off, def, knockout=true)
        winner = res.winner == 1 ? ta : tb
        push!(qf_winners, winner)
        
        push!(match_log, Dict(
            "stage" => "QF",
            "team_a" => ta.name,
            "team_b" => tb.name,
            "goals_a" => res.goals_a,
            "goals_b" => res.goals_b,
            "reg_goals_a" => res.regular_goals_a,
            "reg_goals_b" => res.regular_goals_b,
            "ext_goals_a" => res.extra_goals_a,
            "ext_goals_b" => res.extra_goals_b,
            "pen_goals_a" => res.penalties_a,
            "pen_goals_b" => res.penalties_b,
            "winner" => winner.name
        ))
    end
    
    # --- Semifinals ---
    sf_pairings = [
        (qf_winners[1], qf_winners[2]),     # SF 1
        (qf_winners[3], qf_winners[4])      # SF 2
    ]
    
    sf_winners = Team[]
    sf_losers = Team[]
    for (idx, (ta, tb)) in enumerate(sf_pairings)
        res = simulate_match(ta, tb, off, def, knockout=true)
        winner = res.winner == 1 ? ta : tb
        loser = res.winner == 1 ? tb : ta
        push!(sf_winners, winner)
        push!(sf_losers, loser)
        
        push!(match_log, Dict(
            "stage" => "SF",
            "team_a" => ta.name,
            "team_b" => tb.name,
            "goals_a" => res.goals_a,
            "goals_b" => res.goals_b,
            "reg_goals_a" => res.regular_goals_a,
            "reg_goals_b" => res.regular_goals_b,
            "ext_goals_a" => res.extra_goals_a,
            "ext_goals_b" => res.extra_goals_b,
            "pen_goals_a" => res.penalties_a,
            "pen_goals_b" => res.penalties_b,
            "winner" => winner.name
        ))
    end
    
    # --- 3rd Place Match ---
    res_3rd = simulate_match(sf_losers[1], sf_losers[2], off, def, knockout=true)
    third_place = res_3rd.winner == 1 ? sf_losers[1] : sf_losers[2]
    fourth_place = res_3rd.winner == 1 ? sf_losers[2] : sf_losers[1]
    
    push!(match_log, Dict(
        "stage" => "3RD",
        "team_a" => sf_losers[1].name,
        "team_b" => sf_losers[2].name,
        "goals_a" => res_3rd.goals_a,
        "goals_b" => res_3rd.goals_b,
        "reg_goals_a" => res_3rd.regular_goals_a,
        "reg_goals_b" => res_3rd.regular_goals_b,
        "ext_goals_a" => res_3rd.extra_goals_a,
        "ext_goals_b" => res_3rd.extra_goals_b,
        "pen_goals_a" => res_3rd.penalties_a,
        "pen_goals_b" => res_3rd.penalties_b,
        "winner" => third_place.name
    ))
    
    # --- Final ---
    res_final = simulate_match(sf_winners[1], sf_winners[2], off, def, knockout=true)
    champion = res_final.winner == 1 ? sf_winners[1] : sf_winners[2]
    runner_up = res_final.winner == 1 ? sf_winners[2] : sf_winners[1]
    
    push!(match_log, Dict(
        "stage" => "FINAL",
        "team_a" => sf_winners[1].name,
        "team_b" => sf_winners[2].name,
        "goals_a" => res_final.goals_a,
        "goals_b" => res_final.goals_b,
        "reg_goals_a" => res_final.regular_goals_a,
        "reg_goals_b" => res_final.regular_goals_b,
        "ext_goals_a" => res_final.extra_goals_a,
        "ext_goals_b" => res_final.extra_goals_b,
        "pen_goals_a" => res_final.penalties_a,
        "pen_goals_b" => res_final.penalties_b,
        "winner" => champion.name
    ))
    
    return champion, runner_up, third_place, fourth_place, match_log
end

# Run one full tournament simulation
function run_tournament(teams::Vector{Team}; shape_k::Float64=12.0)
    # 1. Sample ratings for this simulation run
    off, def = sample_ratings(teams, shape_k=shape_k)
    
    # 2. Run group stage
    standings = run_group_stage(teams, off, def)
    
    # 3. Get advancing teams
    top2_dict, top8_3rd = get_advancing_teams(standings)
    
    # 4. Run knockout stage
    champion, runner_up, third_place, fourth_place, match_log = run_knockout_stage(top2_dict, top8_3rd, off, def)
    
    # 5. Extract stage reached for every team
    stages_reached = Dict{String, String}()
    
    # Initialize all to "Group Stage"
    for t in teams
        stages_reached[t.name] = "GS"
    end
    
    # Update based on advancement
    # Those who advanced to R32
    for (g, list) in top2_dict
        stages_reached[list[1].name] = "R32"
        stages_reached[list[2].name] = "R32"
    end
    for t in top8_3rd
        stages_reached[t.name] = "R32"
    end
    
    # Update for later knockout stages based on log
    for m in match_log
        stage = m["stage"]
        winner = m["winner"]
        loser = m["team_a"] == winner ? m["team_b"] : m["team_a"]
        
        if stage == "R32"
            stages_reached[winner] = "R16"
        elseif stage == "R16"
            stages_reached[winner] = "QF"
        elseif stage == "QF"
            stages_reached[winner] = "SF"
        elseif stage == "SF"
            stages_reached[winner] = "FINAL" # Or 3RD / 4TH
        end
    end
    
    # Specific final placement
    stages_reached[champion.name] = "WINNER"
    stages_reached[runner_up.name] = "2ND"
    stages_reached[third_place.name] = "3RD"
    stages_reached[fourth_place.name] = "4TH"
    
    return standings, match_log, stages_reached
end

end
