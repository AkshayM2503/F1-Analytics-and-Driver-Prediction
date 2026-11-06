# F1 Analytics – SQL Views and Advanced Analytics

## Overview

The project uses PostgreSQL views to simplify analytical queries and provide reusable datasets for Formula 1 performance analysis.

The SQL implementation is organised into three scripts:

| Script | Purpose |
|---|---|
| `01_create_tables.sql` | Creates database tables, constraints and indexes. |
| `02_analytics_views.sql` | Creates 12 analytical views. |
| `03_advanced_analytics.sql` | Creates 6 advanced analytical views. |

**Total analytical views: 18**

## 1. Core Analytical Views

The following views are defined in `02_analytics_views.sql`.

| View | Purpose |
|---|---|
| `vw_driver_performance` | Aggregates driver race entries, points, wins, podiums and top-10 finishes. |
| `vw_constructor_performance` | Summarises constructor race entries, points, wins and podiums. |
| `vw_race_summary` | Provides race-level summary information. |
| `vw_circuit_performance` | Supports circuit-level performance comparisons. |
| `vw_driver_qualifying_performance` | Analyses driver qualifying performance. |
| `vw_qualifying_vs_race_result` | Compares qualifying positions with final race results. |
| `vw_pit_strategy_analysis` | Supports pit-stop and race strategy analysis. |
| `vw_driver_lap_pace` | Provides driver lap-time performance analysis. |
| `vw_driver_championship_progress` | Tracks driver championship performance. |
| `vw_constructor_championship_progress` | Tracks constructor championship performance. |
| `vw_race_results_detail` | Provides detailed race result information. |
| `vw_constructor_race_points` | Summarises constructor points across races. |

## 2. Advanced Analytical Views

The following views are defined in `03_advanced_analytics.sql`.

| View | Purpose | SQL concepts |
|---|---|---|
| `vw_driver_season_rankings` | Ranks drivers by season performance. | RANK, DENSE_RANK |
| `vw_constructor_season_rankings` | Ranks constructors by season performance. | RANK |
| `vw_driver_standings_movement` | Analyses changes in driver championship standings. | LAG |
| `vw_constructor_standings_movement` | Analyses changes in constructor standings. | LAG |
| `vw_driver_circuit_rankings` | Compares driver performance across circuits. | PARTITION BY, RANK |
| `vw_driver_racecraft_analysis` | Supports analysis of driver racecraft and performance trends. | Window functions |

## 3. SQL Concepts Demonstrated

### Data aggregation
- GROUP BY
- COUNT()
- SUM()
- AVG()
- FILTER

### Joins
- INNER JOIN
- LEFT JOIN
- Relational key-based data integration

### Window functions
- RANK()
- DENSE_RANK()
- LAG()
- PARTITION BY
- ORDER BY within window functions

### Query organisation
- Common Table Expressions (CTEs)
- CREATE OR REPLACE VIEW
- Analytical subqueries

## 4. Analytical Applications

These views support several types of historical Formula 1 analysis:

- Driver performance comparisons.
- Constructor performance comparisons.
- Season-wise championship rankings.
- Circuit-specific performance.
- Qualifying versus race-result comparisons.
- Pit-stop strategy analysis.
- Lap pace analysis.
- Championship position movement.
- Historical race performance trends.

## 5. Execution Order

Run the SQL scripts in the following order when setting up a new database:

1. `01_create_tables.sql`
2. Import the cleaned CSV datasets into the corresponding tables.
3. `02_analytics_views.sql`
4. `03_advanced_analytics.sql`

The analytical views depend on the underlying database tables being populated.

## 6. Verification

To list all analytical views:

```sql
SELECT table_name
FROM information_schema.views
WHERE table_schema = 'public'
  AND table_name LIKE 'vw_%'
ORDER BY table_name;
```

The expected result is 18 views.

## Purpose

The SQL views separate reusable analytical logic from dashboard presentation, making the database easier to query, maintain and extend.