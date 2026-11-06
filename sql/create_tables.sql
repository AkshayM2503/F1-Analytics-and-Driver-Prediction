-- F1 Analytics Dashboard
-- PostgreSQL table definitions based on the supplied cleaned CSV headers.
-- Run this script in an empty F1 database before loading the CSV files.
-- Source CSVs are not modified by this script.

BEGIN;

CREATE TABLE IF NOT EXISTS seasons (
    year INTEGER PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS circuits (
    circuit_id INTEGER PRIMARY KEY,
    circuit_ref TEXT,
    circuit_name TEXT NOT NULL,
    location TEXT,
    country TEXT,
    latitude NUMERIC(10, 6),
    longitude NUMERIC(10, 6),
    altitude INTEGER
);

CREATE TABLE IF NOT EXISTS drivers (
    driver_id INTEGER PRIMARY KEY,
    driver_ref TEXT,
    driver_name TEXT NOT NULL,
    number NUMERIC(6, 1),
    code TEXT,
    dob DATE,
    nationality TEXT
);

CREATE TABLE IF NOT EXISTS constructors (
    constructor_id INTEGER PRIMARY KEY,
    constructor_ref TEXT,
    constructor_name TEXT NOT NULL,
    nationality TEXT
);

CREATE TABLE IF NOT EXISTS status (
    status_id INTEGER PRIMARY KEY,
    status TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS races (
    race_id INTEGER PRIMARY KEY,
    season INTEGER NOT NULL REFERENCES seasons(year),
    race_round INTEGER,
    circuit_id INTEGER REFERENCES circuits(circuit_id),
    race_name TEXT NOT NULL,
    race_date DATE,
    race_time TIME,
    fp1_date DATE,
    fp1_time TIME,
    fp2_date DATE,
    fp2_time TIME,
    fp3_date DATE,
    fp3_time TIME,
    qualifying_date DATE,
    qualifying_time TIME
);

CREATE TABLE IF NOT EXISTS results (
    result_id INTEGER PRIMARY KEY,
    race_id INTEGER NOT NULL REFERENCES races(race_id),
    driver_id INTEGER NOT NULL REFERENCES drivers(driver_id),
    constructor_id INTEGER NOT NULL REFERENCES constructors(constructor_id),
    grid INTEGER,
    position NUMERIC(6, 2),
    position_text TEXT,
    finish_position INTEGER,
    race_points NUMERIC(10, 3),
    laps INTEGER,
    time TEXT,
    milliseconds NUMERIC(15, 2),
    fastest_lap NUMERIC(8, 2),
    rank NUMERIC(8, 2),
    fastest_lap_time TEXT,
    fastest_lap_speed NUMERIC(10, 3),
    status_id INTEGER REFERENCES status(status_id),
    position_gain INTEGER,
    is_winner SMALLINT,
    is_podium SMALLINT,
    is_top5 SMALLINT,
    is_top10 SMALLINT,
    driver_name TEXT,
    constructor_name TEXT,
    season INTEGER,
    race_round INTEGER,
    race_date DATE,
    race_name TEXT,
    circuit_id INTEGER,
    circuit_name TEXT,
    country TEXT,
    race_status TEXT,
    finish_status_category TEXT,
    is_dnf SMALLINT,
    is_finished SMALLINT,
    is_disqualified SMALLINT,
    fastest_lap_time_milliseconds BIGINT
);

CREATE TABLE IF NOT EXISTS qualifying (
    qualify_id INTEGER PRIMARY KEY,
    race_id INTEGER NOT NULL REFERENCES races(race_id),
    driver_id INTEGER NOT NULL REFERENCES drivers(driver_id),
    constructor_id INTEGER NOT NULL REFERENCES constructors(constructor_id),
    qualifying_position INTEGER,
    q1_time TEXT,
    q2_time TEXT,
    q3_time TEXT,
    q1_milliseconds BIGINT,
    q2_milliseconds BIGINT,
    q3_milliseconds BIGINT,
    driver_name TEXT,
    constructor_name TEXT
);

CREATE TABLE IF NOT EXISTS pit_stops (
    race_id INTEGER NOT NULL REFERENCES races(race_id),
    driver_id INTEGER NOT NULL REFERENCES drivers(driver_id),
    stop_number INTEGER NOT NULL,
    lap INTEGER,
    pit_stop_time TIME,
    pit_stop_duration_seconds NUMERIC(10, 3),
    pit_stop_duration_milliseconds BIGINT,
    PRIMARY KEY (race_id, driver_id, stop_number)
);

CREATE TABLE IF NOT EXISTS pit_strategy_summary (
    race_id INTEGER NOT NULL REFERENCES races(race_id),
    driver_id INTEGER NOT NULL REFERENCES drivers(driver_id),
    pit_stop_count INTEGER,
    first_pit_lap INTEGER,
    last_pit_lap INTEGER,
    average_pit_stop_duration NUMERIC(10, 3),
    strategy_type TEXT,
    PRIMARY KEY (race_id, driver_id)
);

CREATE TABLE IF NOT EXISTS lap_times (
    race_id INTEGER NOT NULL REFERENCES races(race_id),
    driver_id INTEGER NOT NULL REFERENCES drivers(driver_id),
    lap INTEGER NOT NULL,
    position INTEGER,
    lap_time TEXT,
    lap_time_milliseconds BIGINT,
    PRIMARY KEY (race_id, driver_id, lap)
);

CREATE TABLE IF NOT EXISTS driver_standings (
    driver_standings_id INTEGER PRIMARY KEY,
    race_id INTEGER NOT NULL REFERENCES races(race_id),
    driver_id INTEGER NOT NULL REFERENCES drivers(driver_id),
    points NUMERIC(10, 3),
    championship_position INTEGER,
    wins INTEGER
);

CREATE TABLE IF NOT EXISTS constructor_standings (
    constructor_standings_id INTEGER PRIMARY KEY,
    race_id INTEGER NOT NULL REFERENCES races(race_id),
    constructor_id INTEGER NOT NULL REFERENCES constructors(constructor_id),
    points NUMERIC(10, 3),
    championship_position INTEGER,
    wins INTEGER
);

CREATE TABLE IF NOT EXISTS constructor_results (
    constructor_results_id INTEGER PRIMARY KEY,
    race_id INTEGER NOT NULL REFERENCES races(race_id),
    constructor_id INTEGER NOT NULL REFERENCES constructors(constructor_id),
    points NUMERIC(10, 3)
);

-- Helpful indexes for common joins and dashboard filters.
CREATE INDEX IF NOT EXISTS idx_races_season ON races(season);
CREATE INDEX IF NOT EXISTS idx_races_circuit_id ON races(circuit_id);
CREATE INDEX IF NOT EXISTS idx_results_race_id ON results(race_id);
CREATE INDEX IF NOT EXISTS idx_results_driver_id ON results(driver_id);
CREATE INDEX IF NOT EXISTS idx_results_constructor_id ON results(constructor_id);
CREATE INDEX IF NOT EXISTS idx_qualifying_race_driver ON qualifying(race_id, driver_id);
CREATE INDEX IF NOT EXISTS idx_pit_stops_race_driver ON pit_stops(race_id, driver_id);
CREATE INDEX IF NOT EXISTS idx_driver_standings_race_driver ON driver_standings(race_id, driver_id);
CREATE INDEX IF NOT EXISTS idx_constructor_standings_race_constructor
    ON constructor_standings(race_id, constructor_id);

COMMIT;
