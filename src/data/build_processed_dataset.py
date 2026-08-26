from pathlib import Path
import pandas as pd


# ---------------------------------------------------------
# Project paths
# ---------------------------------------------------------

PROJECT_ROOT = Path(__file__).resolve().parents[2]

RAW_DIR = PROJECT_ROOT / "data" / "raw"
PROCESSED_DIR = PROJECT_ROOT / "data" / "processed"

PROCESSED_DIR.mkdir(parents=True, exist_ok=True)


# ---------------------------------------------------------
# Read datasets
# ---------------------------------------------------------

unemployment = pd.read_csv(
    RAW_DIR / "ilo_kenya_unemployment_raw.csv"
)

gdp = pd.read_csv(
    RAW_DIR / "world_bank_gdp_growth_raw.csv"
)

inflation = pd.read_csv(
    RAW_DIR / "world_bank_inflation_raw.csv"
)

investment = pd.read_csv(
    RAW_DIR / "world_bank_investment_gfcf_raw.csv"
)

hdi = pd.read_csv(
    RAW_DIR / "hdr_kenya_hdi_raw.csv"
)

labour_force = pd.read_csv(
    RAW_DIR / "ilo_kenya_labour_participation_raw.csv"
)

employment_population = pd.read_csv(
    RAW_DIR / "ilo_employment_population_raw.csv"
)

youth_neet = pd.read_csv(
    RAW_DIR / "ilo_kenya_youth_neet_raw.csv"
)


# ---------------------------------------------------------
# Select relevant columns
# ---------------------------------------------------------

unemployment = unemployment[["year", "unemployment_ilo"]]

gdp = gdp[["year", "gdp_growth"]]

inflation = inflation[["year", "inflation"]]

investment = investment[["year", "investment_gfcf"]]

hdi = hdi[["year", "hdi"]]

labour_force = labour_force[
    ["year", "labour_participation"]
]

employment_population = employment_population[
    ["year", "Employment_to_population"]
]

youth_neet = youth_neet[
    ["year", "youth_neet_rate"]
]


# ---------------------------------------------------------
# Merge datasets
# ---------------------------------------------------------

data = unemployment.copy()

datasets = [
    gdp,
    inflation,
    investment,
    hdi,
    labour_force,
    employment_population,
    youth_neet
]

for df in datasets:
    data = data.merge(
        df,
        on="year",
        how="left"
    )


# ---------------------------------------------------------
# Sort
# ---------------------------------------------------------

data = data.sort_values("year").reset_index(drop=True)


# ---------------------------------------------------------
# Basic validation
# ---------------------------------------------------------

print("\nDataset shape:")
print(data.shape)

print("\nColumns:")
print(data.columns.tolist())

print("\nYear range:")
print(data["year"].min(), "to", data["year"].max())

print("\nMissing values:")
print(data.isna().sum())

print("\nDuplicate years:")
print(data["year"].duplicated().sum())


# ---------------------------------------------------------
# Save processed candidate dataset
# ---------------------------------------------------------

output_path = (
    PROCESSED_DIR /
    "kenya_employment_candidate_dataset.csv"
)

data.to_csv(output_path, index=False)

print(
    f"\nProcessed dataset saved to:\n{output_path}"
)

coverage = []

for column in data.columns:
    if column == "year":
        continue

    valid = data[column].notna()

    coverage.append({
        "variable": column,
        "first_valid_year": (
            data.loc[valid, "year"].min()
            if valid.any() else None
        ),
        "last_valid_year": (
            data.loc[valid, "year"].max()
            if valid.any() else None
        ),
        "valid_observations": int(valid.sum()),
        "missing_observations": int((~valid).sum())
    })

coverage_df = pd.DataFrame(coverage)

coverage_path = (
    PROCESSED_DIR /
    "data_coverage_report.csv"
)

coverage_df.to_csv(
    coverage_path,
    index=False
)

print("\nData coverage:")
print(coverage_df)

print(
    f"\nCoverage report saved to:\n{coverage_path}"
)