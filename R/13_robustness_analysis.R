# ============================================================
# ARDL robustness: lag-order selection
# ============================================================

library(ARDL)
library(readr)
library(dplyr)

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

# Search a deliberately small lag space.
# Maximum lag = 2 because of the small sample.

lag_selection <- auto_ardl(
  unemployment_ilo ~
    gdp_growth +
    inflation +
    investment_gfcf +
    labour_participation,
  data = ardl_data,
  max_order = c(2, 2, 2, 2, 2),
  selection = "AIC"
)

summary(lag_selection$best_model)

lag_selection$best_order

# Checking BIC

lag_selection_bic <- auto_ardl(
  unemployment_ilo ~
    gdp_growth +
    inflation +
    investment_gfcf +
    labour_participation,
  data = ardl_data,
  max_order = c(2, 2, 2, 2, 2),
  selection = "BIC"
)

summary(lag_selection_bic$best_model)

lag_selection_bic$best_order

# ============================================================
# ARDL robustness: bounds tests
# ============================================================

# AIC-selected model
bounds_aic <- bounds_f_test(
  lag_selection$best_model,
  case = 3,
  exact = TRUE,
  R = 40000
)

print(bounds_aic)


# BIC-selected model
bounds_bic <- bounds_f_test(
  lag_selection_bic$best_model,
  case = 3,
  exact = TRUE,
  R = 40000
)

print(bounds_bic)


robustness_bounds <- tibble(
  model = c(
    "Baseline ARDL(1,1,1,1,1)",
    "AIC ARDL(1,1,2,0,2)",
    "BIC ARDL(1,1,2,0,1)"
  ),
  bounds_F = c(
    bounds_result$statistic,
    bounds_aic$statistic,
    bounds_bic$statistic
  ),
  p_value = c(
    bounds_result$p.value,
    bounds_aic$p.value,
    bounds_bic$p.value
  )
)

print(robustness_bounds)

write_csv(
  robustness_bounds,
  "outputs/tables/ardl_robustness_bounds_tests.csv"
)





