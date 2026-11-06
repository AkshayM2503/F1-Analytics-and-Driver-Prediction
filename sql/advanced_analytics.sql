-- F1 Analytics Dashboard - Advanced SQL Analytics
-- Run after 01_create_tables.sql, CSV imports, and 02_analytics_views.sql.
-- Uses the existing PostgreSQL table and column names.
-- These are additional views; they do not replace the existing dashboard model.

-- 1. Driver points and wins by season, with season ranking.
CREATE OR REPLACE VIEW vw_driver_season_rankings AS
WITH driver_season AS (
    SELECT
        season,
        driver_id,
        driver_name,
        COUNT(*) AS race_entries,
        SUM(COALESCE(race_points, 0)) AS season_points,
        COUNT(*) FILTER (WHERE is_winner = 1) AS wins,
        COUNT(*) FILTER (WHERE is_podium = 1) AS podiums
    FROM results
    WHERE season IS NOT NULL
    GROUP BY season, driver_id, driver_name
)
SELECT
    season,
    driver_id,
    driver_name,
    race_entries,
    season_points,
    wins,
    podiums,
    RANK() OVER (PARTITION BY season ORDER BY season_points DESC) AS points_rank,
    DENSE_RANK() OVER (PARTITION BY season ORDER BY wins DESC, season_points DESC) AS win_rank
FROM driver_season;

-- 2. Constructor points and wins by season, with season ranking.
CREATE OR REPLACE VIEW vw_constructor_season_rankings AS
WITH constructor_season AS (
    SELECT
        season,
        constructor_id,
        constructor_name,
        COUNT(*) AS race_entries,
        SUM(COALESCE(race_points, 0)) AS season_points,
        COUNT(*) FILTER (WHERE is_winner = 1) AS wins,
        COUNT(*) FILTER (WHERE is_podium = 1) AS podiums
    FROM results
    WHERE season IS NOT NULL
    GROUP BY season, constructor_id, constructor_name
)
SELECT
    season,
    constructor_id,
    constructor_name,
    race_entries,
    season_points,
    wins,
    podiums,
    RANK() OVER (PARTITION BY season ORDER BY season_points DESC) AS points_rank
FROM constructor_season;

-- 3. Race-by-race change in each driver's championship points and position.
CREATE OR REPLACE VIEW vw_driver_standings_movement AS
SELECT
    season,
    driver_id,
    driver_name,
    race_round,
    race_id,
    race_name,
    points,
    championship_position,
    wins,
    points - LAG(points) OVER (
        PARTITION BY season, driver_id ORDER BY race_round, race_id
    ) AS points_gained_since_previous_round,
    LAG(championship_position) OVER (
        PARTITION BY season, driver_id ORDER BY race_round, race_id
    ) - championship_position AS position_change
FROM vw_driver_championship_progress;

-- 4. Race-by-race change in each constructor's championship points and position.
CREATE OR REPLACE VIEW vw_constructor_standings_movement AS
SELECT
    season,
    constructor_id,
    constructor_name,
    race_round,
    race_id,
    race_name,
    points,
    championship_position,
    wins,
    points - LAG(points) OVER (
        PARTITION BY season, constructor_id ORDER BY race_round, race_id
    ) AS points_gained_since_previous_round,
    LAG(championship_position) OVER (
        PARTITION BY season, constructor_id ORDER BY race_round, race_id
    ) - championship_position AS position_change
FROM vw_constructor_championship_progress;

-- 5. Driver performance at each circuit, ranked by wins at that circuit.
CREATE OR REPLACE VIEW vw_driver_circuit_rankings AS
WITH driver_circuit AS (
    SELECT
        circuit_id,
        circuit_name,
        country,
        driver_id,
        driver_name,
        COUNT(*) AS race_entries,
        SUM(COALESCE(race_points, 0)) AS total_points,
        COUNT(*) FILTER (WHERE is_winner = 1) AS wins,
        COUNT(*) FILTER (WHERE is_podium = 1) AS podiums
    FROM results
    WHERE circuit_id IS NOT NULL
    GROUP BY circuit_id, circuit_name, country, driver_id, driver_name
)
SELECT
    circuit_id,
    circuit_name,
    country,
    driver_id,
    driver_name,
    race_entries,
    total_points,
    wins,
    podiums,
    RANK() OVER (
        PARTITION BY circuit_id ORDER BY wins DESC, total_points DESC
    ) AS circuit_driver_rank
FROM driver_circuit;

-- 6. Race finishing position compared with grid position.
-- Positive position_gain means the driver finished ahead of their grid slot.
CREATE OR REPLACE VIEW vw_driver_racecraft_analysis AS
SELECT
    season,
    race_round,
    race_id,
    race_name,
    driver_id,
    driver_name,
    constructor_id,
    constructor_name,
    grid,
    finish_position,
    position_gain,
    race_points,
    AVG(position_gain) OVER (
        PARTITION BY season, driver_id
        ORDER BY race_round, race_id
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS season_avg_position_gain_to_date
FROM results
WHERE grid IS NOT NULL AND finish_position IS NOT NULL;

-- 7. Verify the six advanced views created by this script.
SELECT table_name AS view_name
FROM information_schema.views
WHERE table_schema = 'public'
  AND table_name IN (
      'vw_driver_season_rankings',
      'vw_constructor_season_rankings',
      'vw_driver_standings_movement',
      'vw_constructor_standings_movement',
      'vw_driver_circuit_rankings',
      'vw_driver_racecraft_analysis'
  )
ORDER BY table_name;
