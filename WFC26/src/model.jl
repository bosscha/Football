module Model

using Distributions
using Random
using ..Teams

export MatchResult, sample_ratings, simulate_match

struct MatchResult
    goals_a::Int
    goals_b::Int
    regular_goals_a::Int
    regular_goals_b::Int
    extra_goals_a::Int
    extra_goals_b::Int
    penalties_a::Int
    penalties_b::Int
    winner::Int # 1 for team A, 2 for team B, 0 for draw (only in group stage)
end

# Calculate expected ratings based on historical stats and FIFA points
function get_expected_ratings(team::Team)
    # Scale based on FIFA points (median around 1500, scale factor 250)
    w = exp((team.fifa_points - 1500.0) / 250.0)
    
    # Expected offense and defense
    exp_off = team.goals_scored_avg * sqrt(w)
    exp_def = team.goals_conceded_avg / sqrt(w)
    
    # Ensure they don't go to zero or negative
    exp_off = max(exp_off, 0.4)
    exp_def = max(exp_def, 0.4)
    
    return exp_off, exp_def
end

# Sample active offense and defense ratings for all teams (Bayesian parameter sampling)
# shape_k controls the degree of uncertainty. Larger = less variance.
function sample_ratings(teams::Vector{Team}; shape_k::Float64=12.0)
    sampled_off = Dict{String, Float64}()
    sampled_def = Dict{String, Float64}()
    
    for team in teams
        exp_off, exp_def = get_expected_ratings(team)
        
        # Gamma distribution: shape=k, scale=expected/k
        # This keeps the mean equal to expected_rating
        dist_off = Gamma(shape_k, exp_off / shape_k)
        dist_def = Gamma(shape_k, exp_def / shape_k)
        
        sampled_off[team.name] = rand(dist_off)
        sampled_def[team.name] = rand(dist_def)
    end
    
    return sampled_off, sampled_def
end

# Simulate a match between team A and team B
function simulate_match(team_a::Team, team_b::Team, off_ratings::Dict{String, Float64}, def_ratings::Dict{String, Float64}; knockout::Bool=false)
    # Retrieve ratings
    oa = off_ratings[team_a.name]
    da = def_ratings[team_a.name]
    ob = off_ratings[team_b.name]
    db = def_ratings[team_b.name]
    
    # Lambda values for Poisson (Expected Goals)
    lambda_a = oa * db
    lambda_b = ob * da
    
    # Ensure reasonable lambda values
    lambda_a = max(lambda_a, 0.1)
    lambda_b = max(lambda_b, 0.1)
    
    # Simulate 90 mins goals
    goals_a = rand(Poisson(lambda_a))
    goals_b = rand(Poisson(lambda_b))
    
    reg_a = goals_a
    reg_b = goals_b
    ext_a = 0
    ext_b = 0
    pen_a = 0
    pen_b = 0
    winner = 0
    
    if goals_a > goals_b
        winner = 1
    elseif goals_b > goals_a
        winner = 2
    else # Draw
        if knockout
            # Extra Time (30 mins) -> 1/3 of the rate
            ext_a = rand(Poisson(lambda_a / 3.0))
            ext_b = rand(Poisson(lambda_b / 3.0))
            
            goals_a += ext_a
            goals_b += ext_b
            
            if goals_a > goals_b
                winner = 1
            elseif goals_b > goals_a
                winner = 2
            else
                # Penalty Shootout
                # Probability of scoring adjusted slightly by FIFA rank
                diff = team_a.fifa_points - team_b.fifa_points
                p_a = 0.75 + 0.05 * tanh(diff / 200.0)
                p_b = 0.75 - 0.05 * tanh(diff / 200.0)
                
                # First 5 rounds
                for round in 1:5
                    pen_a += rand() < p_a ? 1 : 0
                    pen_b += rand() < p_b ? 1 : 0
                end
                
                # Sudden death if still tied
                while pen_a == pen_b
                    k_a = rand() < p_a ? 1 : 0
                    k_b = rand() < p_b ? 1 : 0
                    pen_a += k_a
                    pen_b += k_b
                end
                
                winner = pen_a > pen_b ? 1 : 2
            end
        else
            winner = 0
        end
    end
    
    return MatchResult(goals_a, goals_b, reg_a, reg_b, ext_a, ext_b, pen_a, pen_b, winner)
end

end
