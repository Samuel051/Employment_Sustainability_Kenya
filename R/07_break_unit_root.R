# ============================================================
# 07_break_unit_root.R
# Lee--Strazicich one-break unit-root tests
# Kenya Employment Sustainability Research
# ============================================================

library(readr)
library(dplyr)

source("src/econometrics/lee_strazicich_one_break.R")

data <- read_csv("Data/final/kenya_employment_model.csv", show_col_types = FALSE)

model_vars <- c(
  "unemployment_ilo",
  "gdp_growth",
  "inflation",
  "investment_gfcf",
  "labour_participation"
)

# All series share the project's 1991--2025 annual window. Do not pool later
# data or silently shorten the sample: this is intentionally a 35-observation
# structural-break diagnostic.
ts_data <- data %>%
  select(year, all_of(model_vars)) %>%
  filter(if_all(all_of(model_vars), ~ !is.na(.))) %>%
  arrange(year)

stopifnot(nrow(ts_data) == 35L)
stopifnot(all(ts_data$year == 1991:2025))

dir.create("outputs/tables", recursive = TRUE, showWarnings = FALSE)

# A fixed zero-lag augmentation preserves degrees of freedom in this short
# annual sample. Results are asymptotic and should be interpreted alongside
# the ADF/PP/KPSS evidence, rather than as stand-alone proof of stationarity.
break_results <- bind_rows(lapply(model_vars, function(variable) {
  test <- lee_strazicich_one_break(ts_data[[variable]], trim = 0.15, lags = 0L)
  critical_5pct <- unname(test$critical_values["5%"])
  tibble(
    variable = variable,
    observations = nrow(ts_data),
    model = "Model C: level + trend break",
    lm_t_statistic = round(test$statistic, 4),
    estimated_break_year = ts_data$year[test$break_position],
    break_fraction = round(test$break_fraction, 3),
    lags = test$lags,
    critical_value_5pct = round(critical_5pct, 3),
    decision_5pct = if_else(
      test$statistic < critical_5pct,
      "Reject unit root (break-stationary)",
      "Do not reject unit root"
    )
  )
}))

print(break_results, n = Inf)

write_csv(
  break_results,
  "outputs/tables/lee_strazicich_one_break_results.csv"
)
