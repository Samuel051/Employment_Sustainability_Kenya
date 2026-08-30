# ============================================================
# 04_stationarity_tests.R
# Level stationarity tests
# Kenya Employment Sustainability Research
# ============================================================

library(readr)
library(dplyr)
library(tseries)

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

ts_data <- data %>%
  select(year, all_of(model_vars)) %>%
  filter(if_all(all_of(model_vars), ~ !is.na(.))) %>%
  arrange(year)

stopifnot(nrow(ts_data) == 35)

# ------------------------------------------------------------
# 2. Create output directory
# ------------------------------------------------------------

dir.create(
  "outputs/tables",
  recursive = TRUE,
  showWarnings = FALSE
)

# ------------------------------------------------------------
# 3. Stationarity testing function
# ------------------------------------------------------------

run_stationarity_tests <- function(x, variable) {

  # ADF
  adf <- suppressWarnings(adf.test(x))

  # Phillips-Perron
  pp <- suppressWarnings(pp.test(x))

  # KPSS: level stationarity
  kpss_level <- suppressWarnings(
    kpss.test(x, null = "Level")
  )

  # KPSS: trend stationarity
  kpss_trend <- suppressWarnings(
    kpss.test(x, null = "Trend")
  )

  # Extract statistics and p-values
  adf_stat <- unname(adf$statistic)
  adf_p <- unname(adf$p.value)

  pp_stat <- unname(pp$statistic)
  pp_p <- unname(pp$p.value)

  kpss_level_stat <- unname(kpss_level$statistic)
  kpss_level_p <- unname(kpss_level$p.value)

  kpss_trend_stat <- unname(kpss_trend$statistic)
  kpss_trend_p <- unname(kpss_trend$p.value)

  # ----------------------------------------------------------
  # Preliminary interpretation
  #
  # ADF / PP:
  # H0 = unit root / non-stationary
  #
  # KPSS:
  # H0 = stationary
  # ----------------------------------------------------------

  adf_stationary <- adf_p < 0.05
  pp_stationary <- pp_p < 0.05
  kpss_stationary <- kpss_level_p > 0.05

  preliminary_decision <- case_when(

    adf_stationary &&
      pp_stationary &&
      kpss_stationary ~
      "Stationary in levels (I(0))",

    !adf_stationary &&
      !pp_stationary &&
      !kpss_stationary ~
      "Non-stationary in levels; test first difference",

    TRUE ~
      "Mixed evidence; investigate further"
  )

  tibble(
    variable = variable,
    observations = length(x),

    adf_statistic = adf_stat,
    adf_p_value = adf_p,

    pp_statistic = pp_stat,
    pp_p_value = pp_p,

    kpss_level_statistic = kpss_level_stat,
    kpss_level_p_value = kpss_level_p,

    kpss_trend_statistic = kpss_trend_stat,
    kpss_trend_p_value = kpss_trend_p,

    preliminary_decision = preliminary_decision
  )
}

# ------------------------------------------------------------
# 4. Run tests for all variables
# ------------------------------------------------------------

level_results <- bind_rows(
  lapply(model_vars, function(variable) {

    x <- ts(
      ts_data[[variable]],
      start = min(ts_data$year),
      frequency = 1
    )

    run_stationarity_tests(x, variable)
  })
)

# ------------------------------------------------------------
# 5. Round results
# ------------------------------------------------------------

level_results <- level_results %>%
  mutate(
    across(
      where(is.numeric),
      ~ round(.x, 4)
    )
  )

# ------------------------------------------------------------
# 6. Display results
# ------------------------------------------------------------

print(level_results, n = Inf)

# ------------------------------------------------------------
# 7. Save results
# ------------------------------------------------------------

write_csv(
  level_results,
  "outputs/tables/stationarity_levels_results.csv"
)

# Optional interactive view in RStudio
View(level_results)