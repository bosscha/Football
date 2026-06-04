# WFC26 Simulation Runner Script
# Usage: julia --project=. run.jl [N]
# Where N is the optional number of simulations (default 10,000)

push!(LOAD_PATH, joinpath(@__DIR__, "src"))

using FootballSim
using JSON
using Random
using Printf

function parse_args_N()
    if length(ARGS) >= 1
        try
            return parse(Int, ARGS[1])
        catch
            println("Invalid N parameter provided. Defaulting to 10,000.")
        end
    end
    return 10000
end

function main()
    N = parse_args_N()
    println("==================================================")
    println("      FIFA World Cup 2026 Simulation Runner       ")
    println("==================================================")
    println("Number of simulations (N): $N")
    
    # 1. Load teams
    teams = get_teams()
    num_teams = length(teams)
    println("Loaded $num_teams teams from Group A to L.")
    
    # 2. Initialize accumulator dictionaries for stats
    # Stats to track: stage reached counts
    stages = ["GS", "R32", "R16", "QF", "SF", "3RD", "4TH", "2ND", "WINNER"]
    team_stats = Dict{String, Dict{String, Int}}()
    goals_scored = Dict{String, Int}()
    goals_conceded = Dict{String, Int}()
    matches_played = Dict{String, Int}()
    
    for t in teams
        team_stats[t.name] = Dict(s => 0 for s in stages)
        goals_scored[t.name] = 0
        goals_conceded[t.name] = 0
        matches_played[t.name] = 0
    end
    
    # France vs Spain H2H stats
    h2h_meetings = 0
    h2h_france_wins = 0
    h2h_spain_wins = 0
    h2h_stages = Dict("R32" => 0, "R16" => 0, "QF" => 0, "SF" => 0, "FINAL" => 0, "3RD" => 0)
    
    # Bracket slot accumulator
    match_slot_stats = [Dict{String, Dict{String, Int}}() for _ in 1:32]
    for i in 1:32
        match_slot_stats[i] = Dict(
            "team_a" => Dict{String, Int}(),
            "team_b" => Dict{String, Int}(),
            "winner" => Dict{String, Int}()
        )
    end
    
    println("\nRunning simulations...")
    start_time = time()
    
    for sim in 1:N
        # Run one tournament
        standings_dict, match_log, stages_reached = run_tournament(teams, shape_k=12.0)
        
        # Accumulate stages reached
        # If team reached "WINNER", it also reached "R32", "R16", "QF", "SF", "FINAL" (2ND)
        for (team_name, stage) in stages_reached
            team_stats[team_name][stage] += 1
        end
        
        # Accumulate goals and matches from group stage
        for (g_name, g_res) in standings_dict
            for standing in g_res.standings
                name = standing.team.name
                goals_scored[name] += standing.goals_scored
                goals_conceded[name] += standing.goals_conceded
                matches_played[name] += 3 # 3 group matches
            end
        end
        
        # Accumulate goals and matches from knockout stage
        for m in match_log
            ta = m["team_a"]
            tb = m["team_b"]
            
            # Increment match counts
            matches_played[ta] += 1
            matches_played[tb] += 1
            
            # Count regular goals + extra goals (exclude penalty shootout goals for averages)
            goals_scored[ta] += m["reg_goals_a"] + m["ext_goals_a"]
            goals_conceded[ta] += m["reg_goals_b"] + m["ext_goals_b"]
            
            goals_scored[tb] += m["reg_goals_b"] + m["ext_goals_b"]
            goals_conceded[tb] += m["reg_goals_a"] + m["ext_goals_a"]
            
            # Check for France vs Spain match
            if (ta == "France" && tb == "Spain") || (ta == "Spain" && tb == "France")
                h2h_meetings += 1
                stage = m["stage"]
                h2h_stages[stage] = get(h2h_stages, stage, 0) + 1
                
                if m["winner"] == "France"
                    h2h_france_wins += 1
                else
                    h2h_spain_wins += 1
                end
            end
        end
        
        # Accumulate bracket slot stats
        for i in 1:32
            m = match_log[i]
            ta = m["team_a"]
            tb = m["team_b"]
            w = m["winner"]
            
            match_slot_stats[i]["team_a"][ta] = get(match_slot_stats[i]["team_a"], ta, 0) + 1
            match_slot_stats[i]["team_b"][tb] = get(match_slot_stats[i]["team_b"], tb, 0) + 1
            match_slot_stats[i]["winner"][w] = get(match_slot_stats[i]["winner"], w, 0) + 1
        end
        
        # Log progress
        if sim % (max(1, N ÷ 10)) == 0
            @printf("➔ Progress: %d / %d (%.0f%%) completed...\n", sim, N, (sim / N) * 100)
        end
    end
    
    elapsed = time() - start_time
    @printf("\nSimulation completed in %.2f seconds.\n", elapsed)
    
    # 3. Compile output stats
    teams_output = []
    for t in teams
        name = t.name
        stats = team_stats[name]
        
        # Calculate individual probability of reaching/finishing at each stage
        # E.g., probability of winning = winner_count / N
        winner_prob = stats["WINNER"] / N
        final_prob = (stats["WINNER"] + stats["2ND"]) / N
        sf_prob = (stats["WINNER"] + stats["2ND"] + stats["3RD"] + stats["4TH"]) / N
        
        # For QF, R16, R32 we need to sum up all stages equal or better
        # A team reached QF if they reached SF, FINAL, 2ND, 3RD, 4TH, or exited in QF
        qf_prob = (stats["WINNER"] + stats["2ND"] + stats["3RD"] + stats["4TH"] + stats["QF"]) / N
        r16_prob = (stats["WINNER"] + stats["2ND"] + stats["3RD"] + stats["4TH"] + stats["QF"] + stats["R16"]) / N
        r32_prob = (stats["WINNER"] + stats["2ND"] + stats["3RD"] + stats["4TH"] + stats["QF"] + stats["R16"] + stats["R32"]) / N
        gs_exit_prob = stats["GS"] / N
        
        avg_gs = matches_played[name] > 0 ? goals_scored[name] / matches_played[name] : 0.0
        avg_gc = matches_played[name] > 0 ? goals_conceded[name] / matches_played[name] : 0.0
        
        push!(teams_output, Dict(
            "name" => name,
            "fifa_points" => t.fifa_points,
            "group" => t.group,
            "goals_scored_avg" => t.goals_scored_avg,
            "goals_conceded_avg" => t.goals_conceded_avg,
            "sim_avg_goals_scored" => avg_gs,
            "sim_avg_goals_conceded" => avg_gc,
            "probs" => Dict(
                "group_exit" => gs_exit_prob,
                "r32" => r32_prob,
                "r16" => r16_prob,
                "qf" => qf_prob,
                "sf" => sf_prob,
                "final" => final_prob,
                "winner" => winner_prob
            )
        ))
    end
    
    # Sort teams by winner probability descending
    sort!(teams_output, by = x -> x["probs"]["winner"], rev = true)
    
    # H2H output
    h2h_output = Dict(
        "total_meetings" => h2h_meetings,
        "prob_of_meeting" => h2h_meetings / N,
        "france_wins" => h2h_france_wins,
        "spain_wins" => h2h_spain_wins,
        "france_win_ratio" => h2h_meetings > 0 ? h2h_france_wins / h2h_meetings : 0.0,
        "spain_win_ratio" => h2h_meetings > 0 ? h2h_spain_wins / h2h_meetings : 0.0,
        "stages" => h2h_stages
    )
    
    # 4. Compile bracket slot stats
    bracket_output = []
    for i in 1:32
        slot = match_slot_stats[i]
        
        # Sort and convert team_a
        ta_sorted = sort(collect(slot["team_a"]), by = x -> x[2], rev = true)
        ta_probs = [Dict("team" => name, "prob" => count / N) for (name, count) in ta_sorted]
        
        # Sort and convert team_b
        tb_sorted = sort(collect(slot["team_b"]), by = x -> x[2], rev = true)
        tb_probs = [Dict("team" => name, "prob" => count / N) for (name, count) in tb_sorted]
        
        # Sort and convert winner
        w_sorted = sort(collect(slot["winner"]), by = x -> x[2], rev = true)
        w_probs = [Dict("team" => name, "prob" => count / N) for (name, count) in w_sorted]
        
        stage = ""
        label = ""
        if i <= 16
            stage = "R32"
            label = "R32 Match $i"
        elseif i <= 24
            stage = "R16"
            label = "R16 Match $(i-16)"
        elseif i <= 28
            stage = "QF"
            label = "QF Match $(i-24)"
        elseif i <= 30
            stage = "SF"
            label = "SF Match $(i-28)"
        elseif i == 31
            stage = "3RD"
            label = "3rd Place Match"
        else
            stage = "FINAL"
            label = "Final"
        end
        
        push!(bracket_output, Dict(
            "slot_index" => i,
            "stage" => stage,
            "label" => label,
            "team_a_probs" => ta_probs[1:min(5, length(ta_probs))],
            "team_b_probs" => tb_probs[1:min(5, length(tb_probs))],
            "winner_probs" => w_probs[1:min(5, length(w_probs))]
        ))
    end
    
    output_data = Dict(
        "N" => N,
        "teams" => teams_output,
        "h2h" => h2h_output,
        "bracket" => bracket_output
    )
    
    # Create results folder if it doesn't exist, and write the JSON and JS data files
    results_dir = joinpath(@__DIR__, "results")
    if !isdir(results_dir)
        mkdir(results_dir)
    end
    
    open(joinpath(results_dir, "data.json"), "w") do f
        JSON.print(f, output_data, 2)
    end
    
    open(joinpath(results_dir, "data.js"), "w") do f
        write(f, "const SIMULATION_DATA = ")
        JSON.print(f, output_data, 2)
        write(f, ";\n")
    end
    
    # Read the dashboard template, embed the JSON directly, and write to results/index.html
    template_path = joinpath(@__DIR__, "src", "dashboard_template.html")
    if isfile(template_path)
        template_content = read(template_path, String)
        json_data_str = JSON.json(output_data)
        compiled_html = replace(template_content, "/*__DATA_PLACEHOLDER__*/ null" => json_data_str)
        write(joinpath(results_dir, "index.html"), compiled_html)
    end
    
    println("\n==================================================")
    println("Results exported to: $(joinpath(results_dir, "index.html")) and data.json")
    @printf("France simulated winner prob: %.2f%%\n", (team_stats["France"]["WINNER"] / N) * 100)
    @printf("Spain simulated winner prob:  %.2f%%\n", (team_stats["Spain"]["WINNER"] / N) * 100)
    @printf("France and Spain met in %.2f%% of tournaments.\n", (h2h_meetings / N) * 100)
    println("==================================================")
end

main()
