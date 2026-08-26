from pathlib import Path
import pandas as pd


# ---------------------------------------------------------
# Project paths
# ---------------------------------------------------------

PROJECT_ROOT = Path(__file__).resolve().parents[2]

PROCESSED_DIR = PROJECT_ROOT / "data" / "processed"
FINAL_DIR = PROJECT_ROOT / "data" / "final"

FINAL_DIR.mkdir(parents=True, exist_ok=True)


# ---------------------------------------------------------
# Load processed candidate dataset
# ---------------------------------------------------------

df = pd.read_csv(
    PROCESSED_DIR / "kenya_employment_candidate_dataset.csv"
)

df = df.sort_values("year").reset_index(drop=True)


# ---------------------------------------------------------
# Basic validation
# ---------------------------------------------------------

assert df["year"].is_unique, "Duplicate years detected."

print("Master dataset shape:", df.shape)

print("\nMissing values in master dataset:")
print(df.isna().sum())


# ---------------------------------------------------------
# 1. Save COMPLETE MASTER DATASET
# ---------------------------------------------------------

master_columns = [
    "year",
    "unemployment_ilo",
    "gdp_growth",
    "inflation",
    "investment_gfcf",
    "hdi",
    "labour_participation",
    "Employment_to_population",
    "youth_neet_rate"
]

master = df[master_columns].copy()

master_path = (
    FINAL_DIR /
    "kenya_employment_master.csv"
)

master.to_csv(
    master_path,
    index=False
)

print(
    f"\nMaster dataset saved to:\n{master_path}"
)

print("\nMaster dataset columns:")
print(master.columns.tolist())


# ---------------------------------------------------------
# 2. Create PRIMARY MODEL DATASET
# ---------------------------------------------------------

model_columns = [
    "year",
    "unemployment_ilo",
    "gdp_growth",
    "inflation",
    "investment_gfcf",
    "labour_participation"
]

model = df[model_columns].copy()

model_path = (
    FINAL_DIR /
    "kenya_employment_model.csv"
)

model.to_csv(
    model_path,
    index=False
)

print(
    f"\nModel dataset saved to:\n{model_path}"
)

print("\nModel dataset columns:")
print(model.columns.tolist())

print("\nModel dataset missing values:")
print(model.isna().sum())