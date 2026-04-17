--Q1 Find the total spending on players for each team:
Select * from IPLPlayers;
Select Team, sum(price_in_cr) As 'Total Spending'
from IPLPlayers
group by Team
order by 'Total Spending' DESC;

--Q2 Find the top 3 highest-paid 'All-rounders' across all teams: 
Select Player,Team,Price_in_cr
from IPLPlayers
where Role = 'All-rounder'
order by Price_in_cr Desc
Limit 3;

--Q3 Find the highest-priced player in each team:
Select * 
from IPLPlayers
order by price_in_cr

With CTE_MP As(
Select team,Max(Price_in_cr)
from IPLPlayers
group by team
)
Select i.Team, i.Player, c.MaxPrice
from IPLPlayers i
Join CTE_MP c ON i.Team = c.Team
where i.Price_in_cr = c.MaxPrice

--Q4 Rank players by their price within each team and list the top 2 for every team:
With RankedPlayers As (
Select Player,Team,Price_in_cr,
Row_Number() Over (Partition by Team Order By Price_in_cr Desc) 
As RankWithinTeam
from IPLPlayers
)
Select Player,Team,Price_in_cr,RankWithinTeam
from RankedPlayers
where RankWithinTeam <=2

--Q5 Find the most expensive player from each team, along with the second-most expensive player's name and price:

With RankedPlayers As (
Select Player,Team,Price_in_cr,
Row_Number() Over (Partition by Team Order By Price_in_cr Desc) As RankWithinTeam
from IPLPlayers
)
Select Team,
   Max(Case when RankWithinTeam = 1 Then Player End) As MostExpensivePlayer,
   Max(Case when RankWithinTeam = 1 Then Price_in_cr End) As HighestPrice,
   Max(Case when RankWithinTeam = 2 Then Player End) As SecondMostExpensivePlayer,
   Max(Case when RankWithinTeam = 2 Then Price_in_cr End) As SecondHighestPrice
from RankedPlayers
Group By Team

--Q6 Calculate the percentage contribution of each player's price to their team's total spending
Select Player,Team,Price_in_cr,
Cast(Price_in_cr/(Sum(Price_in_cr) over (Partition by Team) * 100 As Decimal(10,2))
As ContributionPercentage
from IPLPlayers

--Q7 Classify players as 'High', 'Medium', or 'Low' priced based on the following rules:
--High: Price > ₹15 crore
--Medium: Price between ₹5 crore and ₹15 crore
--Low: Price < ₹5 crore
--and find out the number of players in each bracket

With CTE_BR AS(
Select Team,Player,Price_in_cr,
Case
when Price_in_cr > 15 Then 'High'
when Price_in_cr Between 5 and 15 Then 'Medium'
Else 'Low'
End As PriceCategory
from IPLPlayers
)
Select Team,PriceCategory,count(*) As 'NoOfPlayers'
From CTE_BR
Group By Team,PriceCategory
order by Team,PriceCategory

--Q8 Find the average price of Indian players and compare it with overseas players using a subquery:
Select 
'Indian' As PlayerType,
(Select Avg(Price_in_cr) As AvgPrice
from IPLPlayers
where Type Like 'Indian%')
Union All
Select 
'Overseas' As PlayerType,
(Select Avg(Price_in_cr) As AvgPrice
from IPLPlayers
where Type Like 'Overseas%')

--Q9 Identify players who earn more than the average price of their team:
Select Player,Team, Price_in_cr
from IPLPlayers p
where Price_in_cr > (
Select Avg(Price_in_cr)
from IPLPlayers
where team = p.team)

--Q10 For each role, find the most expensive player and their price using a correlated subquery

Select Team, Role, Price_in_cr
from IPLPlayers p
where Price_in_cr = (
Select Max(Price_in_cr)
where role = p.role
)

