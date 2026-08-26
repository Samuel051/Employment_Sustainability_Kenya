#========================================
# Kenya employment sustainability research
# Descriptive statistics
#========================================

library(tidyverse)

# import data

df <- read_csv(
  "data/final/kenya_employment_model.csv"
)

# Descriptive summary

summary(df)

library(moments)

descriptive_stats <- data.frame(
  Variable = c(
    "Unemployment",
    "GDP Growth",
    "Inflation",
    "GFCF",
    "Labour Force Participation"
  ),
  
  Mean = c(
    mean(df$unemployment_ilo),
    mean(df$gdp_growth),
    mean(df$inflation),
    mean(df$investment_gfcf),
    mean(df$labour_participation)
  ),
  
  Median = c(
    median(df$unemployment_ilo),
    median(df$gdp_growth),
    median(df$inflation),
    median(df$investment_gfcf),
    median(df$labour_participation)
  ),
  
  SD = c(
    sd(df$unemployment_ilo),
    sd(df$gdp_growth),
    sd(df$inflation),
    sd(df$investment_gfcf),
    sd(df$labour_participation)
  ),
  
  Minimum = c(
    min(df$unemployment_ilo),
    min(df$gdp_growth),
    min(df$inflation),
    min(df$investment_gfcf),
    min(df$labour_participation)
  ),
  
  Maximum = c(
    max(df$unemployment_ilo),
    max(df$gdp_growth),
    max(df$inflation),
    max(df$investment_gfcf),
    max(df$labour_participation)
  ),
  
  Skewness = c(
    skewness(df$unemployment_ilo),
    skewness(df$gdp_growth),
    skewness(df$inflation),
    skewness(df$investment_gfcf),
    skewness(df$labour_participation)
  ),
  
  Kurtosis = c(
    kurtosis(df$unemployment_ilo),
    kurtosis(df$gdp_growth),
    kurtosis(df$inflation),
    kurtosis(df$investment_gfcf),
    kurtosis(df$labour_participation)
  )
)

descriptive_stats

# ============================================================
# 3. Distribution Analysis
# ============================================================

ggplot(df, aes(x = unemployment_ilo)) +
  geom_histogram(
    bins = 8,
    aes(y = after_stat(density))
  ) +
  geom_density(linewidth = 1) +
  labs(
    title = "Distribution of Unemployment in Kenya, 1991–2025",
    x = "Unemployment Rate (%)",
    y = "Density"
  ) +
  theme_minimal()

# ============================================================
# 4. Time-Series Analysis
# ============================================================

# Unemployment over time

ggplot(df, aes(x = year, y = unemployment_ilo)) +
  geom_line(linewidth = 1) +
  geom_point() +
  labs(
    title = "Unemployment Rate in Kenya, 1991–2025",
    x = "Year",
    y = "Unemployment Rate (%)"
  ) +
  theme_minimal()
ggsave(
  "outputs/figures/unemployment_trend.png",
  width = 8,
  height = 5,
  dpi = 300
)

# GDP growth over time

ggplot(df, aes(x = year, y = gdp_growth)) +
  geom_line(linewidth = 1) +
  geom_point() +
  labs(
    title = "GDP Growth in Kenya, 1991–2025",
    x = "Year",
    y = "GDP Growth (%)"
  ) +
  theme_minimal()
ggsave(
  "outputs/figures/gdp_growth_trend.png",
  width = 8,
  height = 5,
  dpi = 300
)
## trend in inflation rate over time

ggplot(df, aes(x = year, y = inflation)) +
  geom_line(linewidth = 1) +
  geom_point() +
  labs(
    title = "Inflation in Kenya, 1991–2025",
    x = "Year",
    y = "Inflation (%)"
  ) +
  theme_minimal()
ggsave(
  "outputs/figures/inflation_trend.png",
  width = 8,
  height = 5,
  dpi = 300
)

## investment GFCF trend

ggplot(df, aes(x = year, y = investment_gfcf)) +
  geom_line(linewidth = 1) +
  geom_point() +
  labs(
    title = "Gross Fixed Capital Formation in Kenya, 1991–2025",
    x = "Year",
    y = "GFCF (% of GDP)"
  ) +
  theme_minimal()
ggsave(
  "outputs/figures/investment_gfcf_trend.png",
  width = 8,
  height = 5,
  dpi = 300
)

## Labor force participation trend

ggplot(df, aes(x = year, y = labour_participation)) +
  geom_line(linewidth = 1) +
  geom_point() +
  labs(
    title = "Labour Force Participation in Kenya, 1991–2025",
    x = "Year",
    y = "Labour Force Participation (%)"
  ) +
  theme_minimal()
ggsave(
  "outputs/figures/labour_participation_trend.png",
  width = 8,
  height = 5,
  dpi = 300
)



