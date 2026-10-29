# 🏏 T20I SQL Server Analysis

![SQL Server](https://img.shields.io/badge/SQL%20Server-T--SQL-CC2927?logo=microsoftsqlserver&logoColor=white)
![Questions](https://img.shields.io/badge/Questions-10-blue)
![Matches](https://img.shields.io/badge/Matches-122-green)
![Season](https://img.shields.io/badge/Season-2024-orange)

Ten business-style questions answered with T-SQL on **122 men's T20 international matches played in 2024** (11 Jan – 16 Nov), including the T20 World Cup in the USA & West Indies.

The project goes from raw match records to ranked, comparable team metrics — the same filtering, aggregation, text parsing, CTE and window-function work an analyst does daily.

---

## Contents

- [Business questions](#business-questions)
- [Dataset](#dataset)
- [Skills demonstrated](#skills-demonstrated)
- [Key findings](#key-findings)
- [Sample outputs](#sample-outputs)
- [Query design notes](#query-design-notes)
- [Project structure](#project-structure)
- [How to run](#how-to-run)
- [Possible extensions](#possible-extensions)

---

## Business questions

| # | Question | Techniques |
|---|---|---|
| 1 | Which matches were played between two chosen teams in 2024, and who won? | Symmetric `WHERE` on Team1/Team2 |
| 2 | Which team won the most matches in 2024? | `COUNT`, `GROUP BY`, `TOP 1 WITH TIES` |
| 3 | How do teams rank by total wins? | `DENSE_RANK() OVER` an aggregate |
| 4 | Which team had the highest average winning margin in runs? In wickets? | Text parsing, `AVG`, `TRY_CAST` |
| 5 | Which wins had a margin above the average margin? | CTEs, `AVG() OVER (PARTITION BY …)` |
| 6 | Which team won the most matches while chasing (wins by wickets)? | `LIKE`, `COUNT`, `WITH TIES` |
| 7 | What is the head-to-head record between two chosen teams? | `DECLARE` variables, `GROUP BY` |
| 8 | Which month had the most matches? | `YEAR`, `DATENAME`, `COUNT` |
| 9 | How many matches did each team play, and what is their win %? | `UNION ALL`, conditional `SUM`, CTE |
| 10 | Which team is the most successful at each ground? | CTE, `RANK() OVER (PARTITION BY …)` |

---

## Dataset

One table, `T20I`, in a database called `league` — one row per match.

| Column | Type | Description |
|---|---|---|
| `Team1` | `VARCHAR(50)` | First team listed |
| `Team2` | `VARCHAR(50)` | Second team listed |
| `Winner` | `VARCHAR(50)` | Winning team, or `tied` / `no result` |
| `Margin` | `VARCHAR(50)` | Text such as `13 runs`, `1 run`, `5 wickets`, or `-` when there is no winner |
| `MatchDate` | `DATE` | Match date |
| `Ground` | `VARCHAR(50)` | Venue |

**Data quirks handled in the queries**

- 3 matches were `tied` and 2 had `no result`, so `Winner` is not always a team name.
- `Margin` is free text, so the number must be parsed out before it can be averaged.
- A win **by wickets** means the winner chased; a win **by runs** means they batted first.

---

## Skills demonstrated

| Area | Used for |
|---|---|
| Aggregation | `COUNT`, `SUM`, `AVG`, `GROUP BY` |
| Window functions | `DENSE_RANK`, `RANK`, `AVG() OVER (PARTITION BY …)` |
| CTEs | Multi-step logic for margins, win % and per-ground winners |
| String parsing | `LEFT`, `CHARINDEX`, `TRY_CAST` on text margins |
| Date functions | `YEAR`, `DATENAME` |
| T-SQL features | `DECLARE`, `TOP … WITH TIES`, `UNION ALL` |
| Data quality | Excluding `tied` / `no result`, safe handling of `'-'` margins |

---

## Key findings

- **India dominated 2024** — most wins (22), best win rate (84.6%), and the highest average winning margin both by runs (55.7) and by wickets (7.3).
- **June held ~30% of the year's matches** (36 of 122), driven by the T20 World Cup.
- **Chasing was a strength of several teams** — India and England tied for the most wins by wickets (7 each).
- **Australia edged England 2–1** in their 2024 meetings.
- **Sri Lanka at Dambulla** was the single most dominant team-and-venue pair, with 5 wins.

| # | Result |
|---|---|
| 2 | India — 22 wins |
| 4 | India — 55.7 runs average margin (15 wins by runs) |
| 4.1 | India — 7.3 wickets average margin (7 wins by wickets) |
| 5 | 25 wins by runs (avg 33.7) and 30 wins by wickets (avg 6.5) beat their own average |
| 6 | India and England — 7 chasing wins each |
| 7 | Australia 2, England 1 |
| 8 | June — 36 matches |

---

## Sample outputs

**Q1 — India vs South Africa, 2024**

| Team1 | Team2 | Winner | Margin | MatchDate | Ground |
|---|---|---|---|---|---|
| India | South Africa | India | 7 runs | 2024-06-29 | Bridgetown |
| South Africa | India | India | 61 runs | 2024-11-08 | Durban |
| South Africa | India | South Africa | 3 wickets | 2024-11-10 | Gqeberha |
| South Africa | India | India | 11 runs | 2024-11-13 | Centurion |
| South Africa | India | India | 135 runs | 2024-11-15 | Johannesburg |

**Q3 — Team ranking by wins**

| Winner | total_wins | team_rank |
|---|---|---|
| India | 22 | 1 |
| Australia | 15 | 2 |
| West Indies | 12 | 3 |
| England | 9 | 4 |
| South Africa | 9 | 4 |
| Sri Lanka | 9 | 4 |
| Bangladesh | 8 | 5 |

**Q9 — Matches played and win % (top of the table)**

| team | total_matches | total_wins | win_pct |
|---|---|---|---|
| India | 26 | 22 | 84.62 |
| Australia | 19 | 15 | 78.95 |
| England | 15 | 9 | 60.00 |
| West Indies | 21 | 12 | 57.14 |

**Q10 — Most successful team per ground (top of the table)**

| Ground | team | total_wins |
|---|---|---|
| Dambulla | Sri Lanka | 5 |
| Harare | India | 4 |
| Tarouba | West Indies | 4 |

---

## Query design notes

- **`TOP (1) WITH TIES`** instead of `TOP 1`, so tied leaders (for example in Q6) are not silently dropped.
- **`Winner IN (Team1, Team2)`** removes `tied` / `no result` from win counts; otherwise those labels would be ranked like teams.
- **`TRY_CAST` with `CHARINDEX(' ', Margin + ' ')`** parses margins safely and returns `NULL` for `'-'` instead of raising an error.
- **Q5 compares runs with runs and wickets with wickets** — averaging the two units together would be meaningless.
- **Q9 counts each match once per team (`UNION ALL`)**, so matches played and wins come from the same rows. Ties and no-results count as played, not won.
- **Q10 uses `RANK() OVER (PARTITION BY Ground …)`** so a ground with tied leaders lists every leading team.

---

## Project structure

```
t20i-sql-analysis/
├── README.md
├── sql01_create_and_load_data.sql   # creates the database and table, loads 122 matches
└── sql02_analysis_queries.sql       # Q1–Q10 analysis queries
```

---

## How to run

**Requirements:** Microsoft SQL Server (2016 or later) and SSMS, Azure Data Studio, or `sqlcmd`.

**Option 1 — SSMS / Azure Data Studio**

1. Connect to your SQL Server instance.
2. Open and run `sql01_create_and_load_data.sql`. It creates the `league` database and loads the data, and is safe to re-run.
3. Open `sql02_analysis_queries.sql` and run each question on its own.

**Option 2 — Command line**

```bash
sqlcmd -S localhost -E -i sql01_create_and_load_data.sql
sqlcmd -S localhost -E -d league -i sql02_analysis_queries.sql
```

---

## Possible extensions

- Build a Power BI dashboard on this table (team form, venue performance, monthly volume).
- Add toss and player data to study batting-first versus chasing advantage.
- Extend the dataset to other years to compare trends over time.
