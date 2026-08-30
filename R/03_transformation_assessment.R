# ============================================================
# Kenya Employment Sustainability Research
# 03 - Transformation Assessment
# ============================================================

# Load packages
library(tidyverse)
library(moments)

# Load the model dataset
df <- read.csv("Data/final/kenya_employment_model.csv")

# Inspect structure
str(df)

# Variables to assess
variables <- c(
  "unemployment_ilo",
  "gdp_growth",
  "inflation",
  "investment_gfcf",
  "labour_participation"
)

# Calculate skewness and kurtosis
transformation_stats <- data.frame(
  Variable = variables,
  Skewness = sapply(df[variables], skewness),
  Kurtosis = sapply(df[variables], kurtosis)
)

transformation_stats

# Distribution plots
ggplot(df, aes(x = unemployment_ilo)) +
  geom_histogram(bins = 10) +
  labs(
    title = "Distribution of Unemployment",
    x = "Unemployment (%)",
    y = "Frequency"
  )

ggplot(df, aes(x = inflation)) +
  geom_histogram(bins = 10) +
  labs(
    title = "Distribution of Inflation",
    x = "Inflation (%)",
    y = "Frequency"
  )

ggplot(df, aes(x = year, y = inflation)) +
  geom_line() +
  geom_point() +
  labs(
    title = "Kenya Inflation Trend, 1991–2025",
    x = "Year",
    y = "Inflation (%)"
  )

ggplot(df, aes(x = year, y = gdp_growth)) +
  geom_line() +
  geom_point() +
  labs(
    title = "Kenya GDP Growth Trend, 1991–2025",
    x = "Year",
    y = "GDP Growth (%)"
  )

ggplot(df, aes(x = year, y = investment_gfcf)) +
  geom_line() +
  geom_point() +
  labs(
    title = "Kenya Gross Fixed Capital Formation, 1991–2025",
    x = "Year",
    y = "GFCF (% of GDP)"
  )

ggplot(df, aes(x = year, y = labour_participation)) +
  geom_line() +
  geom_point() +
  labs(
    title = "Kenya Labour Force Participation Rate, 1991–2025",
    x = "Year",
    y = "Labour Force Participation (%)"
  )

# ============================================================
# Boxplots for extreme-value assessment
# ============================================================

df_long <- df %|>%
  select(year, all_of(variables)) %|>%
  pivot_longer(
    cols = -year,
    names_to = "Variable",
    values_to = "Value"
  )

ggplot(df_long, aes(x = Variable, y = Value)) +
  geom_boxplot() +
  labs(
    title = "Distribution and Potential Extreme Values",
    x = "Variable",
    y = "Value"
  ) +
  theme_minimal()
