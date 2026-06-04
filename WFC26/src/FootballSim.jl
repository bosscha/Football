module FootballSim

include("teams.jl")
include("model.jl")
include("tournament.jl")

using .Teams
using .Model
using .Tournament

export Team, get_teams
export MatchResult, sample_ratings, simulate_match
export GroupStanding, GroupResults, run_group_stage, get_advancing_teams, run_knockout_stage, run_tournament

end
