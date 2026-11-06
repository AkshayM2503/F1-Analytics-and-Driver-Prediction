-- F1 Analytics Dashboard - Analytical SQL Views
-- Database: f1_analytics
-- Run after 01_create_tables.sql and after importing all CSV data.
-- Compatibility note: the first two views retain the original column names used when they were created in this project.
-- Safe to rerun against the current database schema.

-- 1. Driver career performance
CREATE OR REPLACE VIEW vw_driver_performance AS
SELECT
    driver_id,
    driver_name,
    COUNT(*) AS total_races,
    SUM(race_points) AS total_points,
    AVG(race_points) AS avg_points,
    COUNT(*) FILTER (WHERE is_winner = 1) AS wins,
    COUNT(*) FILTER (WHERE is_podium = 1) AS podiums,
    COUNT(*) FILTER (WHERE is_top10 = 1) AS top10_finishes
FROM results
GROUP BY driver_id, driver_name;

-- 2. Constructor career performance
CREATE OR REPLACE VIEW vw_constructor_performance AS
SELECT
    constructor_id,
    constructor_name,
    COUNT(*) AS total_race_entries,
    SUM(race_points) AS total_points,
    AVG(race_points) AS avg_points,
    COUNT(*) FILTER (WHERE is_winner = 1) AS wins,
    COUNT(*) FILTER (WHERE is_podium = 1) AS podiums,
    COUNT(*) FILTER (WHERE is_top10 = 1) AS top10_finishes
FROM results
GROUP BY constructor_id, constructor_name;

-- 3. Race-level summary
CREATE OR REPLACE VIEW vw_race_summary AS
SELECT
    r.race_id,
    r.season,
    r.race_round,
    r.race_name,
    r.race_date,
    r.circuit_id,
    c.circuit_name,
    c.country,
    COUNT(res.result_id) AS total_entries,
    COUNT(*) FILTER (WHERE res.is_finished = 1) AS classified_finishers,
    COUNT(*) FILTER (WHERE res.is_dnf = 1) AS dnfs,
    COUNT(*) FILTER (WHERE res.is_winner = 1) AS winner_count,
    MAX(res.race_points) AS highest_points_awarded,
    AVG(res.fastest_lap_speed) AS avg_fastest_lap_speed
FROM races r
LEFT JOIN circuits c ON r.circuit_id = c.circuit_id
LEFT JOIN results res ON r.race_id = res.race_id
GROUP BY r.race_id, r.season, r.race_round, r.race_name,
         r.race_date, r.circuit_id, c.circuit_name, c.country;

-- 4. Circuit performance
CREATE OR REPLACE VIEW vw_circuit_performance AS
SELECT
    circuit_id,
    circuit_name,
    country,
    COUNT(DISTINCT race_id) AS races_held,
    COUNT(*) AS total_driver_entries,
    COUNT(*) FILTER (WHERE is_winner = 1) AS winner_finishes,
    COUNT(*) FILTER (WHERE is_podium = 1) AS podium_finishes,
    AVG(race_points) AS avg_points_per_entry,
    AVG(fastest_lap_speed) AS avg_fastest_lap_speed,
    COUNT(*) FILTER (WHERE is_dnf = 1) AS dnfs
FROM results
GROUP BY circuit_id, circuit_name, country;

-- 5. Driver qualifying performance
CREATE OR REPLACE VIEW vw_driver_qualifying_performance AS
SELECT
    q.driver_id,
    q.driver_name,
    COUNT(*) AS qualifying_sessions,
    AVG(q.qualifying_position) AS avg_qualifying_position,
    MIN(q.qualifying_position) AS best_qualifying_position,
    COUNT(*) FILTER (WHERE q.qualifying_position = 1) AS pole_positions,
    COUNT(*) FILTER (WHERE q.qualifying_position <= 3) AS front_row_or_top3_qualifying
FROM qualifying q
GROUP BY q.driver_id, q.driver_name;

-- 6. Race-by-race qualifying versus finishing position
CREATE OR REPLACE VIEW vw_qualifying_vs_race_result AS
SELECT
    r.season,
    r.race_round,
    r.race_id,
    r.race_name,
    r.race_date,
    q.driver_id,
    q.driver_name,
    q.constructor_name,
    q.qualifying_position,
    res.finish_position,
    res.position_gain,
    res.race_points,
    res.is_podium,
    res.is_winner
FROM qualifying q
JOIN races r ON q.race_id = r.race_id
LEFT JOIN results res
    ON q.race_id = res.race_id
   AND q.driver_id = res.driver_id;

-- 7. Pit strategy analysis
CREATE OR REPLACE VIEW vw_pit_strategy_analysis AS
SELECT
    ps.race_id,
    r.season,
    r.race_round,
    r.race_name,
    r.race_date,
    ps.driver_id,
    d.driver_name,
    ps.pit_stop_count,
    ps.first_pit_lap,
    ps.last_pit_lap,
    ps.average_pit_stop_duration,
    ps.strategy_type
FROM pit_strategy_summary ps
JOIN races r ON ps.race_id = r.race_id
JOIN drivers d ON ps.driver_id = d.driver_id;

-- 8. Driver lap pace summary
CREATE OR REPLACE VIEW vw_driver_lap_pace AS
SELECT
    lt.race_id,
    r.season,
    r.race_round,
    r.race_name,
    lt.driver_id,
    d.driver_name,
    COUNT(*) AS recorded_laps,
    AVG(lt.lap_time_milliseconds) AS avg_lap_time_ms,
    MIN(lt.lap_time_milliseconds) AS fastest_lap_time_ms,
    MAX(lt.lap_time_milliseconds) AS slowest_lap_time_ms,
    STDDEV_POP(lt.lap_time_milliseconds) AS lap_time_stddev_ms
FROM lap_times lt
JOIN races r ON lt.race_id = r.race_id
JOIN drivers d ON lt.driver_id = d.driver_id
WHERE lt.lap_time_milliseconds IS NOT NULL
GROUP BY lt.race_id, r.season, r.race_round, r.race_name,
         lt.driver_id, d.driver_name;

-- 9. Driver championship progress by season
CREATE OR REPLACE VIEW vw_driver_championship_progress AS
SELECT
    ds.driver_standings_id,
    r.season,
    r.race_round,
    r.race_id,
    r.race_name,
    ds.driver_id,
    d.driver_name,
    ds.points,
    ds.championship_position,
    ds.wins
FROM driver_standings ds
JOIN races r ON ds.race_id = r.race_id
JOIN drivers d ON ds.driver_id = d.driver_id;

-- 10. Constructor championship progress by season
CREATE OR REPLACE VIEW vw_constructor_championship_progress AS
SELECT
    cs.constructor_standings_id,
    r.season,
    r.race_round,
    r.race_id,
    r.race_name,
    cs.constructor_id,
    c.constructor_name,
    cs.points,
    cs.championship_position,
    cs.wins
FROM constructor_standings cs
JOIN races r ON cs.race_id = r.race_id
JOIN constructors c ON cs.constructor_id = c.constructor_id;

-- 11. Detailed race results with descriptive dimensions
CREATE OR REPLACE VIEW vw_race_results_detail AS
SELECT
    res.result_id,
    r.season,
    r.race_round,
    r.race_id,
    r.race_name,
    r.race_date,
    ci.circuit_id,
    ci.circuit_name,
    ci.country,
    d.driver_id,
    d.driver_name,
    co.constructor_id,
    co.constructor_name,
    res.grid,
    res.finish_position,
    res.position_text,
    res.position_gain,
    res.race_points,
    res.laps,
    res.fastest_lap_time,
    res.fastest_lap_speed,
    st.status AS finish_status,
    res.is_winner,
    res.is_podium,
    res.is_top5,
    res.is_top10,
    res.is_dnf,
    res.is_finished,
    res.is_disqualified
FROM results res
JOIN races r ON res.race_id = r.race_id
JOIN circuits ci ON r.circuit_id = ci.circuit_id
JOIN drivers d ON res.driver_id = d.driver_id
JOIN constructors co ON res.constructor_id = co.constructor_id
LEFT JOIN status st ON res.status_id = st.status_id;

-- 12. Constructor race-by-race points
CREATE OR REPLACE VIEW vw_constructor_race_points AS
SELECT
    cr.constructor_results_id,
    r.season,
    r.race_round,
    r.race_id,
    r.race_name,
    cr.constructor_id,
    c.constructor_name,
    cr.points
FROM constructor_results cr
JOIN races r ON cr.race_id = r.race_id
JOIN constructors c ON cr.constructor_id = c.constructor_id;

-- Quick verification: list all created views
SELECT table_name AS view_name
FROM information_schema.views
WHERE table_schema = 'public'
  AND table_name LIKE 'vw_%'
ORDER BY table_name;
