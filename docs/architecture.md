# F1 Analytics – Project Architecture

## Overview

The F1 Analytics project is an end-to-end historical Formula 1 data analytics solution built using Python, PostgreSQL, SQL and Microsoft Power BI.

The project transforms cleaned historical Formula 1 datasets into a relational database, performs analytical processing using SQL and presents performance insights through an interactive Power BI dashboard.

## Technology Stack

| Technology | Purpose |
|---|---|
| Python | Data preparation and preprocessing |
| Pandas | Data cleaning and manipulation |
| PostgreSQL | Relational database management |
| SQL | Data querying and analytical processing |
| Microsoft Power BI | Interactive dashboard development |
| DAX | Dashboard calculations and custom prediction metrics |
| Power Query | Data transformation and PostgreSQL connectivity |
| Git and GitHub | Version control and project documentation |

## Data Pipeline

The project follows this workflow:

```text
Historical Formula 1 Datasets
            |
            v
     Python / Pandas
            |
            v
    Data Cleaning and
       Preprocessing
            |
            v
     Cleaned CSV Files
            |
            v
        PostgreSQL
            |
            v
      Relational Tables
            |
            v
     SQL Analytical Views
            |
            v
       Power BI Desktop
            |
            v
   Interactive F1 Dashboard
```

## 1. Data Preparation

Historical Formula 1 datasets are processed using Python and Pandas.

The preparation stage includes:

- Cleaning and standardising datasets.
- Handling missing values.
- Preparing relational identifiers.
- Creating derived analytical columns.
- Exporting cleaned datasets as CSV files.

## 2. Database Layer

PostgreSQL is used as the central relational database.

The database contains 14 tables covering:

- Seasons and circuits.
- Drivers and constructors.
- Races and results.
- Qualifying sessions.
- Pit stops and lap times.
- Driver and constructor standings.

Primary keys and foreign keys establish relationships between the datasets.

## 3. SQL Analytics Layer

PostgreSQL analytical views provide reusable datasets for historical performance analysis.

The SQL implementation includes:

- Driver and constructor performance aggregation.
- Race and circuit analysis.
- Qualifying and race-result comparisons.
- Pit strategy analysis.
- Lap pace analysis.
- Championship rankings and standings movement.

Advanced SQL concepts include window functions, CTEs, ranking functions and aggregations.

## 4. Power BI Reporting Layer

Power BI Desktop connects directly to the PostgreSQL database.

The dashboard uses PostgreSQL data through Power Query and retains the existing DAX calculations and analytical model.

### Dashboard modules

1. Overview
2. Driver Analytics
3. Constructor Analytics
4. Circuit Insights
5. Race Strategy
6. Recent Form
7. Prediction Model
8. Race Prediction

## 5. Driver Prediction Model

The project includes a custom weighted driver prediction model designed to evaluate historical driver performance and estimate potential race outcomes.

The model combines five performance dimensions:

| Factor | Weight |
|---|---:|
| Circuit Performance | 30% |
| Recent Form | 30% |
| Qualifying | 15% |
| Racecraft | 15% |
| Strategy | 10% |
| **Total** | **100%** |

The weighted model combines these dimensions into a driver prediction score.

The model is intended for historical-data-based analysis and does not represent a live race prediction service.

## 6. Data Refresh

Power BI retrieves data from the PostgreSQL database.

When the underlying database is updated, the dashboard can be refreshed to retrieve the latest available records.

The project currently analyses historical Formula 1 data rather than live race telemetry or live race feeds.

## 7. Repository Structure

```text
F1-Analytics/
│
├── data/
│   └── cleaned_csv/
│
├── python/
│   └── data preparation scripts
│
├── sql/
│   ├── 01_create_tables.sql
│   ├── 02_analytics_views.sql
│   └── 03_advanced_analytics.sql
│
├── docs/
│   ├── database_schema.md
│   ├── sql_views.md
│   └── architecture.md
│
├── powerbi/
│   └── F1_Analytics.pbix
│
├── requirements.txt
└── README.md
```

## 8. Project Objectives

The project demonstrates an end-to-end analytics workflow involving:

- Historical data preparation using Python.
- Relational database design using PostgreSQL.
- Advanced analytical querying using SQL.
- Interactive dashboard development using Power BI.
- Custom weighted driver performance prediction.
- Data modelling, reporting and visual analytics.

## Conclusion

The F1 Analytics project combines data engineering, relational database management, analytical SQL and business intelligence to explore historical Formula 1 performance.

It provides a structured and extensible foundation for driver, constructor, circuit, race strategy and championship analysis.