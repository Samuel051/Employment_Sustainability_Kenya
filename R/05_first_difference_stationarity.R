# ============================================================
# 05_first_difference_stationarity.R
# First-difference stationarity tests
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

variables_to_check <- c(
  "unemployment_ilo",
  "investment_gfcf",
  "labour_participation"
)

ts_data <- data %>%
  select(year, all_of(variables_to_check)) %>%
  filter(if_all(all_of(variables_to_check), ~ !is.na(.))) %>%
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
# 3. First-difference testing function
# ------------------------------------------------------------

run_difference_tests <- function(x, variable) {

  # First difference
  dx <- diff(x)

  # ADF
  adf <- suppressWarnings(adf.test(dx))

  # Phillips-Perron
  pp <- suppressWarnings(pp.test(dx))

  # KPSS level
  kpss_level <- suppressWarnings(
    kpss.test(dx, null = "Level")
  )

  # Extract statistics and p-values
  adf_stat <- unname(adf$statistic)
  adf_p <- unname(adf$p.value)

  pp_stat <- unname(pp$statistic)
  pp_p <- unname(pp$p.value)

  kpss_stat <- unname(kpss_level$statistic)
  kpss_p <- unname(kpss_level$p.value)

  # ----------------------------------------------------------
  # Preliminary interpretation
  # ----------------------------------------------------------

  adf_stationary <- adf_p < 0.05
  pp_stationary <- pp_p < 0.05
  kpss_stationary <- kpss_p > 0.05

  preliminary_decision <- case_when(

    adf_stationary &&
      pp_stationary &&
      kpss_stationary ~
      "First difference stationary; I(1) supported",

    TRUE ~
      "Mixed evidence; investigate structural breaks and lag sensitivity"
  )

  tibble(
    variable = variable,
    observations_after_difference = length(dx),

    adf_statistic = adf_stat,
    adf_p_value = adf_p,

    pp_statistic = pp_stat,
    pp_p_value = pp_p,

    kpss_level_statistic = kpss_stat,
    kpss_level_p_value = kpss_p,

    preliminary_decision = preliminary_decision
  )
}

# ------------------------------------------------------------
# 4. Run first-difference tests
# ------------------------------------------------------------

difference_results <- bind_rows(
  lapply(variables_to_check, function(variable) {

    x <- ts(
      ts_data[[variable]],
      start = min(ts_data$year),
      frequency = 1
    )

    run_difference_tests(x, variable)
  })
)

# ------------------------------------------------------------
# 5. Round results
# ------------------------------------------------------------

difference_results <- difference_results %>%
  mutate(
    across(
      where(is.numeric),
      ~ round(.x, 4)
    )
  )

# ------------------------------------------------------------
# 6. Display
# ------------------------------------------------------------

print(difference_results, n = Inf)

# ------------------------------------------------------------
# 7. Save
# ------------------------------------------------------------

write_csv(
  difference_results,
  "outputs/tables/stationarity_first_difference_results.csv"
)

View(difference_results)