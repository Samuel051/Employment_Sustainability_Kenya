# ============================================================
# 12_long_run_ardl.R
# Long-run ARDL multipliers
# Kenya Employment Sustainability Research
# ============================================================

library(ARDL)
library(readr)
library(dplyr)

# ------------------------------------------------------------
# 1. Load model data
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
# 2. Estimate ARDL(1,1,1,1,1)
# ------------------------------------------------------------

ardl_11111 <- ardl(
  unemployment_ilo ~
    gdp_growth +
    inflation +
    investment_gfcf +
    labour_participation,
  data = ardl_data,
  order = c(1, 1, 1, 1, 1)
)

# ------------------------------------------------------------
# 3. Estimate long-run multipliers
# ------------------------------------------------------------

long_run_results <- multipliers(
  ardl_11111,
  type = "lr"
)

print(long_run_results)

# ------------------------------------------------------------
# 4. Convert to clean table
# ------------------------------------------------------------

long_run_table <- as.data.frame(long_run_results)

long_run_table$term <- rownames(long_run_table)

rownames(long_run_table) <- NULL

long_run_table <- long_run_table %>%
  select(term, everything())

# ------------------------------------------------------------
# 5. Add interpretation metadata
# ------------------------------------------------------------

long_run_table <- long_run_table %>%
  mutate(
    model = "ARDL(1,1,1,1,1)",
    dependent_variable = "unemployment_ilo",
    sample_start = 1991,
    sample_end = 2025,
    observations = 35,
    bounds_F = 3.8799,
    bounds_p_value = 0.1085,
    cointegration_5pct = FALSE
  )

# ------------------------------------------------------------
# 6. Save results
# ------------------------------------------------------------

dir.create(
  "outputs/tables",
  recursive = TRUE,
  showWarnings = FALSE
)

write_csv(
  long_run_table,
  "outputs/tables/ardl_long_run_coefficients.csv"
)

# ------------------------------------------------------------
# 7. Print final table
# ------------------------------------------------------------

print(long_run_table)