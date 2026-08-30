# ============================================================
# 08_bai_perron_breaks.R
# Bai--Perron multiple-break trend diagnostics
# Kenya Employment Sustainability Research
# ============================================================

if (!requireNamespace("strucchange", quietly = TRUE)) {
  stop(
    "Package 'strucchange' is required. Install it with ",
    "install.packages('strucchange') before running this script."
  )
}

library(readr)
library(dplyr)

data <- read_csv("Data/final/kenya_employment_model.csv", show_col_types = FALSE)

model_vars <- c(
  "unemployment_ilo",
  "gdp_growth",
  "inflation",
  "investment_gfcf",
  "labour_participation"
)

# Keep the common 1991--2025 annual sample used in the stationarity and
# Lee--Strazicich stages. It is deliberately not expanded or shortened.
ts_data <- data %>%
  select(year, all_of(model_vars)) %>%
  filter(if_all(all_of(model_vars), ~ !is.na(.))) %>%
  arrange(year)

stopifnot(nrow(ts_data) == 35L)
stopifnot(all(ts_data$year == 1991:2025))

# With 35 annual observations, allow no more than two breaks and require at
# least seven observations per regime. BIC selects among zero, one and two
# breaks; this is a conservative trend-regime diagnostic, not a unit-root test.
maximum_breaks <- 2L
minimum_segment <- 7L
stopifnot(nrow(ts_data) >= (maximum_breaks + 1L) * minimum_segment)

dir.create("outputs/tables", recursive = TRUE, showWarnings = FALSE)

run_bai_perron <- function(x, variable, years) {
  time <- seq_along(x)

  full_fit <- strucchange::breakpoints(
    x ~ time,
    h = minimum_segment,
    breaks = maximum_breaks
  )
  bic_fit <- strucchange::breakpoints(full_fit)
  break_positions <- bic_fit$breakpoints
  break_positions <- break_positions[!is.na(break_positions)]
  break_years <- years[break_positions]
  new_regime_years <- years[pmin(break_positions + 1L, length(years))]

  # supF is an omnibus test for at least one structural change in the
  # intercept-and-trend relationship. It complements BIC's break-count choice.
  supf <- strucchange::sctest(
    x ~ time,
    type = "supF",
    from = minimum_segment / length(x)
  )

  summary_row <- tibble(
    variable = variable,
    observations = length(x),
    specification = "value ~ linear time trend",
    max_breaks_considered = maximum_breaks,
    min_segment_observations = minimum_segment,
    bic_selected_breaks = length(break_positions),
    break_transitions = if (length(break_years)) {
      paste(paste0(break_years, "/", new_regime_years), collapse = "; ")
    } else {
      "None"
    },
    supf_statistic = round(unname(supf$statistic), 4),
    supf_p_value = format.pval(supf$p.value, digits = 4, eps = 0.0001),
    structural_change_evidence = if_else(
      supf$p.value < 0.05,
      "Evidence of at least one trend-regime change",
      "No 5% evidence of a trend-regime change"
    )
  )

  break_rows <- tibble(
    variable = variable,
    break_number = seq_along(break_years),
    previous_regime_end_year = break_years,
    new_regime_start_year = new_regime_years
  )

  list(summary = summary_row, dates = break_rows)
}

results <- lapply(model_vars, function(variable) {
  run_bai_perron(ts_data[[variable]], variable, ts_data$year)
})

bai_perron_summary <- bind_rows(lapply(results, `[[`, "summary"))
bai_perron_dates <- bind_rows(lapply(results, `[[`, "dates"))

# Compact table for the diagnostic stage; detailed dates are saved separately
# for comparison with historically motivated candidate periods in R/06.
print(bai_perron_summary, n = Inf)

write_csv(
  bai_perron_summary,
  "outputs/tables/bai_perron_break_summary.csv"
)
write_csv(
  bai_perron_dates,
  "outputs/tables/bai_perron_break_dates.csv"
)
