import io
import os
import requests
import pandas as pd

# Correct API endpoint and parameter
url = "https://rplumber.ilo.org/data/indicator"
params = {"id": "EIP_2EET_SEX_RT"}  # Exactly EIP_2EET_SEX_RT

print("Fetching Youth NEET Rate data...")
response = requests.get(url, params=params, timeout=60)

# Check status and print debugging details if it fails
print("Status code:", response.status_code)
response.raise_for_status()

# Read the full dataset
df = pd.read_csv(io.StringIO(response.text))

# Filter specifically for Kenya (KEN) and Total Sex (SEX_T)
kenya = df[
    (df["ref_area"] == "KEN") & 
    (df["sex"] == "SEX_T")
].copy()

# Filter research years (1991 - 2025)
kenya = kenya[kenya["time"].astype(str).str[:4].astype(int).between(1991, 2025)].copy()

# Keep only the year and data column, then rename
kenya = kenya[["time", "obs_value"]].rename(columns={"time": "year", "obs_value": "youth_neet_rate"})
kenya["year"] = kenya["year"].astype(int)
kenya = kenya.sort_values("year").reset_index(drop=True)

# Visual confirmation
print("\nFirst observations:")
print(kenya.head())
print("\nShape of dataset:", kenya.shape)

# Save output
output_path = "data/raw/ilo_kenya_youth_neet_raw.csv"
os.makedirs(os.path.dirname(output_path), exist_ok=True)
kenya.to_csv(output_path, index=False)
print(f"\nSaved successfully to: {output_path}")
