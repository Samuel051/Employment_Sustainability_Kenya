import requests
import pandas as pd

url = "https://api.worldbank.org/v2/country/KEN/indicator/HD.HCI.OVRL"

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
        "value": "human_capital_index"
    }
)

df["year"] = df["year"].astype(int)

df = df.sort_values("year").reset_index(drop=True)

print("\nFirst observations:")
print(df.head(10))

print("\nLast observations:")
print(df.tail(10))

print("\nShape:")
print(df.shape)

print("\nMissing values:")
print(df.isna().sum())

print("\nValid observations:")
print(df["human_capital_index"].notna().sum())

valid_df = df[df["human_capital_index"].notna()]

if not valid_df.empty:
    print("\nFirst valid year:", valid_df["year"].min())
    print("Last valid year:", valid_df["year"].max())

df.to_csv(
    "data/raw/world_bank_human_capital_raw.csv",
    index=False
)

print("\nRaw human capital data saved successfully.")