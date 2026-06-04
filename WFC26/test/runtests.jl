using Test

# Load the package files directly or activate the environment
push!(LOAD_PATH, joinpath(@__DIR__, "..", "src"))
using FootballSim
using Random

@testset "WFC26 Football Simulator Tests" begin

    @testset "Data Loading Tests" begin
        teams = get_teams()
        @test length(teams) == 48
        
        # Check groups A-L
        groups = [t.group for t in teams]
        unique_groups = unique(groups)
        @test length(unique_groups) == 12
        @test all(g in ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L"] for g in unique_groups)
        
        # Check teams per group
        for g in unique_groups
            @test count(x -> x == g, groups) == 4
        end
    end

    @testset "Bayesian Model Rating Tests" begin
        teams = get_teams()
        off, def = sample_ratings(teams, shape_k=15.0)
        
        @test length(off) == 48
        @test length(def) == 48
        @test all(v > 0 for v in values(off))
        @test all(v > 0 for v in values(def))
        
        # France should have a high expected offense, South Africa lower
        france = filter(t -> t.name == "France", teams)[1]
        sa = filter(t -> t.name == "South Africa", teams)[1]
        
        # Expected rating order check
        # We can test multiple samples to ensure statistical order
        fr_off_samples = [sample_ratings(teams, shape_k=50.0)[1]["France"] for _ in 1:10]
        sa_off_samples = [sample_ratings(teams, shape_k=50.0)[1]["South Africa"] for _ in 1:10]
        @test minimum(fr_off_samples) > maximum(sa_off_samples)
    end

    @testset "Match Simulation Tests" begin
        teams = get_teams()
        off, def = sample_ratings(teams)
        
        france = filter(t -> t.name == "France", teams)[1]
        senegal = filter(t -> t.name == "Senegal", teams)[1]
        
        # Group stage match
        res_group = simulate_match(france, senegal, off, def, knockout=false)
        @test res_group.goals_a >= 0
        @test res_group.goals_b >= 0
        @test res_group.winner in [0, 1, 2]
        
        # Knockout stage match (cannot be draw)
        res_ko = simulate_match(france, senegal, off, def, knockout=true)
        @test res_ko.goals_a >= 0
        @test res_ko.goals_b >= 0
        @test res_ko.winner in [1, 2]
        if res_ko.regular_goals_a == res_ko.regular_goals_b
            @test (res_ko.extra_goals_a > 0 || res_ko.extra_goals_b > 0 || res_ko.penalties_a > 0 || res_ko.penalties_b > 0)
        end
    end

    @testset "Tournament Simulation Tests" begin
        teams = get_teams()
        standings, match_log, stages_reached = run_tournament(teams)
        
        # 12 group standings
        @test length(standings) == 12
        @test haskey(standings, "A")
        @test length(standings["A"].standings) == 4
        
        # Knockout log length check
        # Round of 32 (16 matches) + R16 (8) + QF (4) + SF (2) + 3rd (1) + Final (1) = 32 matches
        @test length(match_log) == 32
        
        # All 48 teams should have a stage reached
        @test length(stages_reached) == 48
        
        # Exactly one winner, one runner-up (2ND), one 3RD, one 4TH
        placements = values(stages_reached)
        @test count(x -> x == "WINNER", placements) == 1
        @test count(x -> x == "2ND", placements) == 1
        @test count(x -> x == "3RD", placements) == 1
        @test count(x -> x == "4TH", placements) == 1
    end

end
