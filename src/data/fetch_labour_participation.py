import io
import requests
import pandas as pd


# ---------------------------------------------------------
# ILOSTAT API
# ---------------------------------------------------------

url = "https://rplumber.ilo.org/data/indicator"

params = {
    "id": "EAP_2WAP_SEX_AGE_RT"
}

response = requests.get(url, params=params, timeout=60)

print("Status code:", response.status_code)
print("Content-Type:", response.headers.get("Content-Type"))

response.raise_for_status()


# ---------------------------------------------------------
# Read CSV response
# ---------------------------------------------------------

df = pd.read_csv(io.StringIO(response.text))

print("\nFull dataset shape:")
print(df.shape)


# ---------------------------------------------------------
# Filter Kenya, total sex, age 15+
# ---------------------------------------------------------

kenya = df[
    (df["ref_area"] == "KEN") &
    (df["sex"] == "SEX_T") &
    (df["classif1"] == "AGE_YTHADULT_YGE15")
].copy()


# ---------------------------------------------------------
# Restrict to our research period
# ---------------------------------------------------------

kenya = kenya[
    kenya["time"].astype(str).str[:4].astype(int).between(1991, 2025)
].copy()


# ---------------------------------------------------------
# Keep relevant fields
# ---------------------------------------------------------

kenya = kenya[["time", "obs_value"]]

kenya = kenya.rename(
    columns={
        "time": "year",
        "obs_value": "labour_participation"
    }
)

kenya["year"] = kenya["year"].astype(int)

kenya = kenya.sort_values("year").reset_index(drop=True)


# ---------------------------------------------------------
# Inspect
# ---------------------------------------------------------

print("\nFirst observations:")
print(kenya.head())

print("\nLast observations:")
print(kenya.tail())

print("\nShape:")
print(kenya.shape)

print("\nMissing values:")
print(kenya.isna().sum())

print("\nYear range:")
print(kenya["year"].min(), "to", kenya["year"].max())


# ---------------------------------------------------------
# Save raw Kenya extraction
# ---------------------------------------------------------

kenya.to_csv(
    "data/raw/ilo_kenya_labour_participation_raw.csv",
    index=False
)

print("\nILO Kenya labour participation data saved successfully.")