"""
Prepare cleaned Formula 1 CSV files for the F1 Analytics project.

Expected input:
    data/raw_csv/
        seasons.csv
        races.csv
        results.csv
        drivers.csv
        constructors.csv
        circuits.csv
        qualifying.csv
        pit_stops.csv
        driver_standings.csv
        constructor_standings.csv
        constructor_results.csv
        status.csv
        lap_times.csv
        pit_strategy_summary.csv   (optional, if already generated)

Output:
    data/cleaned_csv/*_clean.csv
    data/cleaning_report.csv

This script performs conservative, repeatable cleaning:
- trims whitespace from text values and column labels
- converts common textual null markers to missing values
- removes fully duplicated rows
- preserves column names and values otherwise, so IDs and Power BI fields
  are not silently renamed or recast

It does not invent missing values or derive pit-strategy metrics.
"""

from pathlib import Path
import logging
import pandas as pd


PROJECT_ROOT = Path(__file__).resolve().parents[1]
RAW_DIR = PROJECT_ROOT / "data" / "raw_csv"
CLEAN_DIR = PROJECT_ROOT / "data" / "cleaned_csv"
REPORT_PATH = PROJECT_ROOT / "data" / "cleaning_report.csv"

# Raw source filename -> cleaned output filename
FILE_MAP = {
    "seasons.csv": "seasons_clean.csv",
    "races.csv": "races_clean.csv",
    "results.csv": "results_clean.csv",
    "drivers.csv": "drivers_clean.csv",
    "constructors.csv": "constructors_clean.csv",
    "circuits.csv": "circuits_clean.csv",
    "qualifying.csv": "qualifying_clean.csv",
    "pit_stops.csv": "pit_stops_clean.csv",
    "driver_standings.csv": "driver_standings_clean.csv",
    "constructor_standings.csv": "constructor_standings_clean.csv",
    "constructor_results.csv": "constructor_results_clean.csv",
    "status.csv": "status_clean.csv",
    "lap_times.csv": "lap_times_clean.csv",
    "pit_strategy_summary.csv": "pit_strategy_summary.csv",
}

NULL_MARKERS = {"", "na", "n/a", "null", "none", "nan"}


def clean_dataframe(df: pd.DataFrame) -> tuple[pd.DataFrame, dict]:
    """Apply conservative cleaning without changing the dataset schema."""
    original_rows = len(df)

    # Remove accidental spaces around column names, without changing naming style.
    df.columns = [str(column).strip() for column in df.columns]

    # Trim text fields and standardise common textual null markers.
    for column in df.select_dtypes(include=["object", "string"]).columns:
        values = df[column].astype("string").str.strip()
        df[column] = values.mask(values.str.casefold().isin(NULL_MARKERS), pd.NA)

    # Remove only fully identical records; do not deduplicate on IDs alone.
    duplicate_rows = int(df.duplicated().sum())
    df = df.drop_duplicates().reset_index(drop=True)

    stats = {
        "rows_before": original_rows,
        "duplicate_rows_removed": duplicate_rows,
        "rows_after": len(df),
        "columns": len(df.columns),
        "missing_cells_after": int(df.isna().sum().sum()),
    }
    return df, stats


def main() -> None:
    logging.basicConfig(
        level=logging.INFO,
        format="%(levelname)s: %(message)s",
    )

    if not RAW_DIR.exists():
        raise FileNotFoundError(
            f"Raw data folder not found: {RAW_DIR}\n"
            "Create data/raw_csv and place the original CSV files there."
        )

    CLEAN_DIR.mkdir(parents=True, exist_ok=True)
    report_rows = []
    processed = 0

    for raw_name, clean_name in FILE_MAP.items():
        source_path = RAW_DIR / raw_name

        if not source_path.exists():
            logging.warning("Skipping missing source file: %s", raw_name)
            continue

        logging.info("Processing %s", raw_name)

        try:
            df = pd.read_csv(source_path, low_memory=False)
            cleaned_df, stats = clean_dataframe(df)

            output_path = CLEAN_DIR / clean_name
            cleaned_df.to_csv(output_path, index=False)

            report_rows.append({
                "source_file": raw_name,
                "output_file": clean_name,
                **stats,
                "status": "success",
            })
            processed += 1
            logging.info(
                "Saved %s (%s -> %s rows)",
                output_path.name,
                stats["rows_before"],
                stats["rows_after"],
            )

        except Exception as exc:
            logging.exception("Failed to process %s", raw_name)
            report_rows.append({
                "source_file": raw_name,
                "output_file": clean_name,
                "rows_before": None,
                "duplicate_rows_removed": None,
                "rows_after": None,
                "columns": None,
                "missing_cells_after": None,
                "status": f"failed: {exc}",
            })

    if report_rows:
        pd.DataFrame(report_rows).to_csv(REPORT_PATH, index=False)

    logging.info("Finished. Successfully processed %d file(s).", processed)
    logging.info("Cleaning report: %s", REPORT_PATH)

    if processed == 0:
        raise RuntimeError(
            "No input CSV files were processed. Check filenames in data/raw_csv."
        )


if __name__ == "__main__":
    main()
