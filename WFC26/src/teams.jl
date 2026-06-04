module Teams

export Team, get_teams

struct Team
    name::String
    fifa_points::Float64
    group::String
    goals_scored_avg::Float64
    goals_conceded_avg::Float64
end

function get_teams()
    return [
        # Group A
        Team("Mexico", 1681.03, "A", 1.7, 1.1),
        Team("South Africa", 1307.20, "A", 1.1, 1.4),
        Team("South Korea", 1542.81, "A", 1.6, 1.2),
        Team("Czechia", 1505.24, "A", 1.5, 1.2),
        
        # Group B
        Team("Canada", 1461.38, "B", 1.4, 1.3),
        Team("Bosnia and Herzegovina", 1395.20, "B", 1.2, 1.5),
        Team("Qatar", 1235.30, "B", 1.0, 1.6),
        Team("Switzerland", 1649.40, "B", 1.7, 1.1),
        
        # Group C
        Team("Brazil", 1761.16, "C", 2.1, 0.8),
        Team("Morocco", 1755.87, "C", 1.9, 0.7),
        Team("Haiti", 1242.10, "C", 0.9, 1.7),
        Team("Scotland", 1492.30, "C", 1.4, 1.3),
        
        # Group D
        Team("United States", 1673.13, "D", 1.8, 1.0),
        Team("Paraguay", 1421.10, "D", 1.1, 1.3),
        Team("Australia", 1533.12, "D", 1.6, 1.1),
        Team("Turkey", 1555.43, "D", 1.7, 1.2),
        
        # Group E
        Team("Germany", 1730.37, "E", 2.2, 0.9),
        Team("Curaçao", 1255.40, "E", 0.8, 1.8),
        Team("Ivory Coast", 1470.50, "E", 1.4, 1.2),
        Team("Ecuador", 1482.10, "E", 1.3, 1.1),
        
        # Group F
        Team("Netherlands", 1757.87, "F", 2.2, 0.9),
        Team("Japan", 1660.43, "F", 1.9, 1.0),
        Team("Sweden", 1580.22, "F", 1.6, 1.2),
        Team("Tunisia", 1445.60, "F", 1.2, 1.3),
        
        # Group G
        Team("Belgium", 1734.71, "G", 2.1, 0.9),
        Team("Egypt", 1515.64, "G", 1.5, 1.1),
        Team("Iran", 1475.22, "G", 1.4, 1.2),
        Team("New Zealand", 1205.10, "G", 0.9, 1.7),
        
        # Group H
        Team("Spain", 1876.40, "H", 2.3, 0.7),
        Team("Cape Verde", 1322.10, "H", 1.1, 1.5),
        Team("Saudi Arabia", 1388.40, "H", 1.2, 1.4),
        Team("Uruguay", 1673.07, "H", 1.8, 1.0),
        
        # Group I
        Team("France", 1877.32, "I", 2.4, 0.8),
        Team("Senegal", 1688.99, "I", 1.7, 0.9),
        Team("Iraq", 1382.10, "I", 1.3, 1.3),
        Team("Norway", 1530.50, "I", 1.8, 1.2),
        
        # Group J
        Team("Argentina", 1874.81, "J", 2.2, 0.6),
        Team("Algeria", 1485.12, "J", 1.5, 1.2),
        Team("Austria", 1560.12, "J", 1.7, 1.1),
        Team("Jordan", 1215.20, "J", 1.0, 1.6),
        
        # Group K
        Team("Portugal", 1763.83, "K", 2.3, 0.8),
        Team("DR Congo", 1352.12, "K", 1.1, 1.4),
        Team("Uzbekistan", 1375.30, "K", 1.2, 1.3),
        Team("Colombia", 1693.09, "K", 1.8, 0.9),
        
        # Group L
        Team("England", 1825.97, "L", 2.2, 0.7),
        Team("Croatia", 1717.07, "L", 1.8, 0.9),
        Team("Ghana", 1345.50, "L", 1.2, 1.5),
        Team("Panama", 1435.20, "L", 1.3, 1.4)
    ]
end

end
