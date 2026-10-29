USE league;


GO
--Q1 Identify matches played between two specific teams (e.g., India and South Africa) in 2024 and their results.
--output: *
--method: WHERE()
SELECT *
FROM   T20I
WHERE  ((Team1 = 'South Africa'
         AND Team2 = 'India')
        OR (Team2 = 'South Africa'
            AND Team1 = 'India'))
       AND YEAR(MatchDate) = 2024;

--Q2 Find the team with the highest number of wins in 2024 and the total matches it won.
--output: Winner, total_wins
--method: COUNT(*) WHERE(YEAR()) GROUP BY (winner)
SELECT   TOP 1 Winner,
               COUNT(*) AS 'total_wins'
FROM     T20I
WHERE    YEAR(MatchDate) = 2024
GROUP BY Winner
ORDER BY total_wins DESC;

--Q3 Rank the teams based on the total number of wins in 2024.
--output: winner, total_wins, team_rank
--method: COUNT(*), DENSE_RANK, WHERE(YEAR()), GROUP BY(winner)
SELECT   Winner,
         COUNT(*) AS total_wins,
         DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) AS team_rank
FROM     T20I
WHERE    YEAR(MatchDate) = 2024
         AND (Winner = Team1)
         OR (Winner = Team2)
GROUP BY Winner;

--Q4 Which team had the highest average winning margin (in runs), and what was the average margin?
--output: team, highest_avg_wins, average_margin
--method: GROUP BY(team), WHERE(runs)
SELECT   TOP 1 Winner,
               AVG(CAST (REPLACE(REPLACE(Margin, ' runs', ''), (' run'), '') AS DECIMAL (10, 2))) AS highest_avg_wins
FROM     T20I
WHERE    Margin LIKE '%run%'
GROUP BY Winner
ORDER BY highest_avg_wins DESC;

--Q4.1 Which team had the highest average winning margin (in wickets), and what was the average margin?
SELECT   TOP 1 Winner,
               AVG(CAST (LEFT(Margin, CHARINDEX(' ', Margin) - 1) AS DECIMAL (10, 2))) AS highest_avg_wins
FROM     T20I
WHERE    Margin LIKE '%wicket%'
GROUP BY Winner
ORDER BY highest_avg_wins DESC;

--Q5 List all matches where the winning margin was greater than the average margin across all matches.
--output: *
--method: CTE[AVG Margin of all matches, LEFT(Charindex)], CTE[WHERE CTE2 AVG > CTE1 AVG]
SELECT *
FROM   T20I;

SELECT Team1,
       Team2,
       Winner,
       CAST (LEFT(Margin, CHARINDEX(' ', Margin) - 1) AS INT) AS Margin_Value
FROM   T20I
WHERE  Margin IS NOT NULL
       AND CHARINDEX(' ', Margin) > 0;

--Q6 Find the team with the most wins when chasing a target (wins by wickets)
--output: winner, total_wins,
--method: GROUP BY(winner), COUNT(*), WHERE(LIKE '%wickets%)
SELECT   TOP 2 Winner,
               COUNT(*) AS total_wins
FROM     T20I
WHERE    Margin LIKE '%wicket%'
GROUP BY Winner
ORDER BY total_wins DESC;

--Q7 Head-to-head record between two selected teams (e.g., England vs Australia).
--output: winner, total_wins
--method: DECLARE(England, australia), GROUP BY (winner), COUNT(*)
DECLARE @TeamA AS VARCHAR (30) = 'England', @TeamB AS VARCHAR (30) = 'Australia';

SELECT   Winner,
         COUNT(*) AS total_matches
FROM     T20I
WHERE    (Team1 = @TeamA)
         AND (Team2 = @TeamB)
         OR (Team1 = @TeamB)
            AND (Team2 = @TeamA)
GROUP BY Winner;

--Q8 Identify the month in 2024 with the highest number of T20I matches played.
--output: year, month, total_matches
--method: year(), DATENAME(), COUNT(*), GROUP BY(Date)
SELECT   YEAR(MatchDate) AS year,
         DATENAME(MONTH, MatchDate) AS month_name,
         COUNT(*) AS total_matches
FROM     T20I
WHERE    YEAR(MatchDate) = 2024
GROUP BY YEAR(MatchDate), DATENAME(MONTH, MatchDate)
ORDER BY total_matches DESC;

--Q9 For each team, find how many matches they played in 2024 and their win percentage.
--output: team, total_matches, Win_pct
--method: 
--CTE['How Many matches the played in 2024 each team']
--CTE['How many matches they win in 2024 each team']
WITH     cte_total_matches_sep
AS       (SELECT   Team1 AS team,
                   COUNT(*) AS total_matches
          FROM     T20I
          WHERE    YEAR(MatchDate) = 2024
          GROUP BY Team1
          UNION ALL
          SELECT   Team2 AS team,
                   COUNT(*) AS total_matches
          FROM     T20I
          WHERE    YEAR(MatchDate) = 2024
          GROUP BY Team2),
         cte_total_matches
AS       (SELECT   Team,
                   SUM(total_matches) AS total_matches
          FROM     cte_total_matches_sep
          GROUP BY Team),
         cte_total_wins
AS       (SELECT   Winner,
                   COUNT(*) AS total_wins
          FROM     T20I
          GROUP BY Winner)
SELECT   c.team,
         COALESCE (c.total_matches, 0) AS total_matches,
         COALESCE (ct.total_wins, 0) AS total_wins,
         CAST (COALESCE (ct.total_wins, 0) * 100.0 / COALESCE (c.total_matches, 0) AS DECIMAL (10, 2)) AS winning
FROM     cte_total_matches AS c
         LEFT OUTER JOIN
         cte_total_wins AS ct
         ON c.team = ct.Winner
ORDER BY winning DESC;

--Q10 Identify the most successful team at each ground (team with most wins per ground)
--output: Ground, team, Total_wins
--method: GROUP BY(winner, ground) WHERE(winner =  team1 or winner = team2) COUNT(*)
SELECT   winner,
         ground,
         COUNT(*) AS total_wins
FROM     T20I
WHERE    Winner = Team1
         OR Winner = Team2
GROUP BY Winner, Ground
ORDER BY total_wins DESC;