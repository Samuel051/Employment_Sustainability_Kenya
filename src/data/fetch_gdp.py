import requests
import pandas as pd

url = "https://api.worldbank.org/v2/country/KEN/indicator/NY.GDP.MKTP.KD.ZG"

params = {
    "format": "json",
    "per_page": 100
}

response = requests.get(url, params=params)

print("Status code:", response.status_code)

data = response.json()

observations = data[1]

print("Number of observations:", len(observations))

df = pd.DataFrame(observations)

df = df[["date", "value"]]

df = df.rename(
    columns={
        "date": "year",
        "value": "gdp_growth"
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

print("\nYear range:")
print(df["year"].min(), "to", df["year"].max())

df. to_csv(
    "data/raw/world_bank_gdp_growth_raw.csv",
    index=False
)

print("\nRaw gdp growth data saved succesfully.") 