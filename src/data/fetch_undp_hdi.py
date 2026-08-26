import pandas as pd
import os

# Define paths
RAW_PATH = "data/raw/hdr-data.xlsx"
OUTPUT_PATH = "data/raw/hdr_kenya_hdi_raw.csv"

# Read the Excel file (no requests needed!)
df = pd.read_excel(RAW_PATH, sheet_name="Data")

# Filter for Kenya and extract year + actualValue
df_kenya = df[df["country"] == "Kenya"][["year", "actualValue"]].copy()
df_kenya = df_kenya.rename(columns={"year": "year", "actualValue": "hdi"})

# Clean and sort
df_kenya["year"] = df_kenya["year"].astype(int)
df_kenya = df_kenya.sort_values("year").reset_index(drop=True)

# Save to raw
df_kenya.to_csv(OUTPUT_PATH, index=False)

print(f"✅ Extracted HDI data to: {OUTPUT_PATH}")
print(f"📊 Years: {df_kenya['year'].min()} to {df_kenya['year'].max()}")
print(f"📈 Observations: {len(df_kenya)}")