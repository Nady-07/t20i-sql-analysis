# T20I 2024 — SQL Server Analysis

A SQL project that answers 10 business-style questions about **122 men's T20 international matches played in 2024** (11 Jan – 16 Nov 2024), using T-SQL on Microsoft SQL Server.

It includes the 2024 T20 World Cup in the USA & West Indies as well as bilateral series, and is built to practice the SQL a data analyst uses every day: filtering, aggregation, text parsing, CTEs and window functions.

## Skills demonstrated

| Area | Used for |
|---|---|
| Aggregation | `COUNT`, `SUM`, `AVG`, `GROUP BY` |
| Window functions | `DENSE_RANK`, `RANK() OVER (PARTITION BY …)`, `AVG() OVER (PARTITION BY …)` |
| CTEs | multi-step logic for margins, win %, per-ground winners |
| String parsing | extracting numbers from text (`'13 runs'`, `'5 wickets'`) with `LEFT`, `CHARINDEX`, `TRY_CAST` |
| Date functions | `YEAR`, `DATENAME` |
| T-SQL features | `DECLARE` variables, `TOP … WITH TIES`, `UNION ALL` |
| Data quality | handling non-team values (`tied`, `no result`) and `'-'` margins |

## Dataset

One table, `T20I`, in a database called `league`.

| Column | Type | Description |
|---|---|---|
| `Team1` | VARCHAR(50) | First team listed |
| `Team2` | VARCHAR(50) | Second team listed |
| `Winner` | VARCHAR(50) | Winning team, or `tied` / `no result` |
| `Margin` | VARCHAR(50) | Text such as `13 runs`, `1 run`, `5 wickets`, or `-` when there is no winner |
| `MatchDate` | DATE | Match date |
| `Ground` | VARCHAR(50) | Venue city / ground |

**Things worth knowing about the data**
- 3 matches were `tied` and 2 had `no result`, so `Winner` is not always a team. Win counts filter on `Winner IN (Team1, Team2)`.
- `Margin` is text, so the number has to be parsed before it can be averaged.
- A win by *wickets* means the winner was chasing; a win by *runs* means they batted first.

## Project structure

```
T20I-SQL-Analysis/
├── README.md
└── sql/
    ├── 01_create_and_load_data.sql   # creates database + table, loads 122 matches
    └── 02_analysis_queries.sql       # Q1–Q10 analysis queries
```

## How to run

1. Open **SQL Server Management Studio** (or Azure Data Studio) connected to a SQL Server instance.
2. Run `sql/01_create_and_load_data.sql` — it (re)creates the `league` database and loads the data. Re-running is safe.
3. Run `sql/02_analysis_queries.sql` and execute each question separately.

## Questions and key findings

| # | Question | Result |
|---|---|---|
| 1 | Matches between India and South Africa in 2024 | 5 matches: India won 4, South Africa won 1 |
| 2 | Team with the most wins in 2024 | **India — 22 wins** |
| 3 | Rank teams by wins | India 1st (22), Australia 2nd (15), West Indies 3rd (12); England, South Africa and Sri Lanka share 4th (9) |
| 4 | Highest average winning margin (runs) | **India — 55.7 runs** per win by runs (15 such wins) |
| 4.1 | Highest average winning margin (wickets) | **India — 7.3 wickets** (7 such wins) |
| 5 | Matches with a margin above the average | 25 wins by runs (avg 33.7) and 30 wins by wickets (avg 6.5) beat their own average |
| 6 | Most wins when chasing | **India and England tie — 7 each** |
| 7 | England vs Australia head-to-head | Australia 2, England 1 |
| 8 | Busiest month | **June — 36 matches** (T20 World Cup month) |
| 9 | Matches played and win % per team | India 84.6% (22 of 26), Australia 78.9% (15 of 19), England 60.0% (9 of 15) |
| 10 | Most successful team at each ground | Sri Lanka at Dambulla (5 wins) leads; India at Harare and West Indies at Tarouba follow with 4 each |

**Takeaways**
- India dominated 2024: the most wins, the best win percentage and the biggest average winning margins in both runs and wickets.
- June alone held almost 30% of the year's matches because of the T20 World Cup.
- Chasing was common among top teams — India and England won the most matches by wickets.

## Query design notes

A few choices that keep the results correct:

- **`TOP (1) WITH TIES`** instead of `TOP 1`, so tied leaders (e.g. Q6) are not hidden.
- **`Winner IN (Team1, Team2)`** removes `tied` / `no result` from win counts. Without it, those labels get ranked like teams.
- **`TRY_CAST` with `CHARINDEX(' ', Margin + ' ')`** safely parses margins and returns `NULL` for `'-'` instead of failing.
- **Q5 compares runs with runs and wickets with wickets**, because averaging the two units together would be meaningless.
- **Q9 counts each match once per team via `UNION ALL`**, so matches played and wins come from the same set of rows; ties and no-results count as played but not won.
- **Q10 uses `RANK() OVER (PARTITION BY Ground …)`** to return the top team per ground, keeping ties.

## Possible extensions

- Add a Power BI dashboard on top of this table (team form, venue performance, monthly volume).
- Add toss and player data to analyse batting-first vs chasing advantage.
- Extend the dataset to other years to compare trends.

## Author

**[Mohamed Al Nady](https://github.com/Nady-07)** — data analyst focused on SQL, Power BI and DAX.
