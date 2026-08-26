import requests
import pandas as pd

url = "https://api.worldbank.org/v2/country/KEN/indicator/SP.POP.GROW"

params = {
    "format": "json",
    "per_page": 100
}

response = requests.get(url, params=params, timeout=60)

print("Status code:", response.status_code)

response.raise_for_status()

data = response.json()

observations = data[1]

df = pd.DataFrame(observations)

df = df[["date", "value"]]

df = df.rename(
    columns={
        "date": "year",
        "value": "population_growth"
    }
)

df["year"] = df["year"].astype(int)

df = df.sort_values("year").reset_index(drop=True)

print("\nFirst observations:")
print(df.head())

print("\nLast observations:")
print(df.tail())

print("\nShape:")
print(df.shape)

print("\nMissing values:")
print(df.isna().sum())

valid_df = df[df["population_growth"].notna()]

print("\nValid observations:", len(valid_df))

if not valid_df.empty:
    print("First valid year:", valid_df["year"].min())
    print("Last valid year:", valid_df["year"].max())

df.to_csv(
    "data/raw/world_bank_population_growth_raw.csv",
    index=False
)

print("\nRaw population-growth data saved successfully.")