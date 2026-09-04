# ============================================================
# 17_forecasting_setup.R
# ARDL forecasting setup and out-of-sample validation
# Kenya Employment Sustainability Research
# ============================================================

library(ARDL)
library(readr)
library(dplyr)
library(forecast)

# ------------------------------------------------------------
# 1. Load data
# ------------------------------------------------------------

data <- read_csv(
  "Data/final/kenya_employment_model.csv",
  show_col_types = FALSE
)

model_vars <- c(
  "unemployment_ilo",
  "gdp_growth",
  "inflation",
  "investment_gfcf",
  "labour_participation"
)

ardl_data <- data %>%
  select(year, all_of(model_vars)) %>%
  filter(if_all(all_of(model_vars), ~ !is.na(.))) %>%
  arrange(year)

stopifnot(nrow(ardl_data) == 35L)
stopifnot(all(ardl_data$year == 1991:2025))

# ------------------------------------------------------------
# 2. Define training and test samples
# ------------------------------------------------------------
#
# We reserve the final 5 observations for genuine
# out-of-sample evaluation:
#
# Training: 1991-2020
# Testing:  2021-2025
#
# ------------------------------------------------------------

train_data <- ardl_data %>%
  filter(year <= 2020)

test_data <- ardl_data %>%
  filter(year >= 2021)

stopifnot(nrow(train_data) == 30L)
stopifnot(nrow(test_data) == 5L)

# ------------------------------------------------------------
# 3. Baseline ARDL
# ------------------------------------------------------------

baseline_model <- ardl(
  unemployment_ilo ~
    gdp_growth +
    inflation +
    investment_gfcf +
    labour_participation,
  data = train_data,
  order = c(1, 1, 1, 1, 1)
)

summary(baseline_model)

# ------------------------------------------------------------
# 4. BIC-selected ARDL
# ------------------------------------------------------------

bic_model <- ardl(
  unemployment_ilo ~
    gdp_growth +
    inflation +
    investment_gfcf +
    labour_participation,
  data = train_data,
  order = c(1, 1, 2, 0, 1)
)

summary(bic_model)

# ------------------------------------------------------------
# 5. Prepare test data
# ------------------------------------------------------------

test_data

# ------------------------------------------------------------
# 6. Save train/test datasets
# ------------------------------------------------------------

dir.create(
  "outputs/tables",
  recursive = TRUE,
  showWarnings = FALSE
)

write_csv(
  train_data,
  "outputs/tables/forecast_training_data.csv"
)

write_csv(
  test_data,
  "outputs/tables/forecast_test_data.csv"
)

cat("\nForecasting setup completed successfully.\n")
cat("Training period: 1991-2020\n")
cat("Testing period: 2021-2025\n")