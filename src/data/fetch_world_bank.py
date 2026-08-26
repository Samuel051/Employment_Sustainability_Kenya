import requests
import pandas as pd

url = "https://api.worldbank.org/v2/country/KEN/indicator/SL.UEM.TOTL.ZS"

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
        "value": "unemployment"
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

print("\nData types:")
print(df.dtypes)

print("\nMissing values:")
print(df.isna().sum())

print("\nYear range:")
print(df["year"].min(), "to", df["year"].max())

print(
    df.loc[df["unemployment"].notna(), ["year", "unemployment"]]
      .head(10)
)

valid_df = df[df["unemployment"].notna()]

print("First valid year:", valid_df["year"].min())
print("Last valid year:", valid_df["year"].max())
print("Number of valid observations:", len(valid_df))

df.to_csv(
    "data/raw/world_bank_unemployment_raw.csv",
    index=False
)

print("\nRaw unemployment data saved successfully.")