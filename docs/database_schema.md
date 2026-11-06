# F1 Analytics Database Schema

## Overview

The F1 Analytics project uses PostgreSQL as its relational database to store, organise and analyse historical Formula 1 racing data.

The database is named `f1_analytics` and contains 14 tables covering seasons, circuits, drivers, constructors, races, race results, qualifying sessions, pit stops, lap times and championship standings.

**Database:** PostgreSQL  
**Database name:** `f1_analytics`  
**Tables:** 14

## Database Tables

| Table | Description |
|---|---|
| `seasons` | Stores available Formula 1 seasons. |
| `circuits` | Contains circuit information, locations and geographical details. |
| `drivers` | Stores driver information and identification details. |
| `constructors` | Contains Formula 1 constructor and team information. |
| `status` | Stores race result status descriptions. |
| `races` | Contains race schedules, season information and circuit references. |
| `results` | Stores individual driver race results, points, positions and performance indicators. |
| `qualifying` | Contains qualifying session results. |
| `pit_stops` | Stores pit stop information, including timing and duration. |
| `pit_strategy_summary` | Contains aggregated pit strategy information. |
| `lap_times` | Stores individual lap timing information. |
| `driver_standings` | Contains historical driver championship standings. |
| `constructor_standings` | Contains historical constructor championship standings. |
| `constructor_results` | Stores constructor race results and points. |

## Primary and Foreign Key Relationships

The database uses primary keys and foreign keys to maintain relational integrity.

### Main relationships

- `races.season` → `seasons.year`
- `races.circuit_id` → `circuits.circuit_id`
- `results.race_id` → `races.race_id`
- `results.driver_id` → `drivers.driver_id`
- `results.constructor_id` → `constructors.constructor_id`
- `results.status_id` → `status.status_id`

Other race-related tables use race, driver and constructor identifiers where applicable.

## Indexing

Indexes are created on frequently referenced identifier columns to improve query performance.

These include race, driver, constructor and circuit identifiers.

## Data Validation

The imported database was validated using SQL queries.

Verified row counts:

| Table | Records |
|---|---:|
| seasons | 75 |
| circuits | 77 |
| drivers | 859 |
| constructors | 212 |
| status | 139 |
| races | 1,125 |
| results | 26,539 |
| qualifying | 10,274 |
| pit_stops | 11,030 |
| pit_strategy_summary | 5,366 |
| lap_times | 575,989 |
| driver_standings | 34,616 |
| constructor_standings | 13,281 |
| constructor_results | 12,515 |

**Total imported records: 1,261,897**

The results table was also checked for missing race, driver and constructor references.

All three missing-reference checks returned zero.

## Purpose

The relational database provides a structured foundation for historical F1 analysis and supports reusable SQL queries, analytical views and Power BI reporting.