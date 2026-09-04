# ============================================================
# 11_ardl_diagnostics.R
# Final ARDL diagnostic tests
# Kenya Employment Sustainability Research
# ============================================================

library(readr)
library(dplyr)
library(tibble)
library(car)
library(lmtest)
library(tseries)
library(strucchange)
library(ARDL)

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
# 3. VIF
# ------------------------------------------------------------

vif_model <- lm(
  unemployment_ilo ~
    gdp_growth +
    inflation +
    investment_gfcf +
    labour_participation,
  data = ardl_data
)

vif_values <- car::vif(vif_model)

vif_results <- tibble(
  test = "Variance Inflation Factor",
  variable = names(vif_values),
  statistic = as.numeric(vif_values),
  p_value = NA_real_,
  decision = case_when(
    as.numeric(vif_values) < 5 ~ "No multicollinearity concern",
    as.numeric(vif_values) < 10 ~ "Moderate multicollinearity",
    TRUE ~ "High multicollinearity"
  )
)

print(vif_results)

# ------------------------------------------------------------
# 4. Breusch-Godfrey serial-correlation test
# ------------------------------------------------------------

bg_test <- lmtest::bgtest(
  ardl_11111,
  order = 1
)

print(bg_test)

bg_results <- tibble(
  test = "Breusch-Godfrey serial correlation",
  variable = "ARDL residuals",
  statistic = as.numeric(bg_test$statistic),
  p_value = as.numeric(bg_test$p.value),
  decision = ifelse(
    bg_test$p.value > 0.05,
    "Fail to reject H0: no serial correlation",
    "Reject H0: serial correlation present"
  )
)

# ------------------------------------------------------------
# 5. Breusch-Pagan heteroskedasticity test
# ------------------------------------------------------------

bp_test <- lmtest::bptest(ardl_11111)

print(bp_test)

bp_results <- tibble(
  test = "Breusch-Pagan heteroskedasticity",
  variable = "ARDL residuals",
  statistic = as.numeric(bp_test$statistic),
  p_value = as.numeric(bp_test$p.value),
  decision = ifelse(
    bp_test$p.value > 0.05,
    "Fail to reject H0: homoskedasticity",
    "Reject H0: heteroskedasticity present"
  )
)

# ------------------------------------------------------------
# 6. Jarque-Bera residual normality test
# ------------------------------------------------------------

residuals_ardl <- residuals(ardl_11111)

jb_test <- tseries::jarque.bera.test(residuals_ardl)

print(jb_test)

jb_results <- tibble(
  test = "Jarque-Bera residual normality",
  variable = "ARDL residuals",
  statistic = as.numeric(jb_test$statistic),
  p_value = as.numeric(jb_test$p.value),
  decision = ifelse(
    jb_test$p.value > 0.05,
    "Fail to reject H0: residuals are normally distributed",
    "Reject H0: residuals are not normally distributed"
  )
)

# ------------------------------------------------------------
# 7. Ramsey RESET specification test
# ------------------------------------------------------------

reset_test <- lmtest::resettest(
  ardl_11111,
  power = 2:3,
  type = "fitted"
)

print(reset_test)

reset_results <- tibble(
  test = "Ramsey RESET specification",
  variable = "ARDL model",
  statistic = as.numeric(reset_test$statistic),
  p_value = as.numeric(reset_test$p.value),
  decision = ifelse(
    reset_test$p.value > 0.05,
    "Fail to reject H0: no specification error detected",
    "Reject H0: possible functional-form/specification issue"
  )
)

# ------------------------------------------------------------
# 8. Prepare stability model
# ------------------------------------------------------------
# Explicit lag construction is used instead of formula(ardl_11111)
# because strucchange cannot directly evaluate ARDL's L() terms.

stability_data <- ardl_data %>%
  mutate(
    unemployment_l1 = dplyr::lag(unemployment_ilo, 1),
    gdp_growth_l1 = dplyr::lag(gdp_growth, 1),
    inflation_l1 = dplyr::lag(inflation, 1),
    investment_gfcf_l1 = dplyr::lag(investment_gfcf, 1),
    labour_participation_l1 = dplyr::lag(labour_participation, 1)
  ) %>%
  filter(
    !is.na(unemployment_l1),
    !is.na(gdp_growth_l1),
    !is.na(inflation_l1),
    !is.na(investment_gfcf_l1),
    !is.na(labour_participation_l1)
  )

stability_model <- lm(
  unemployment_ilo ~
    unemployment_l1 +
    gdp_growth +
    gdp_growth_l1 +
    inflation +
    inflation_l1 +
    investment_gfcf +
    investment_gfcf_l1 +
    labour_participation +
    labour_participation_l1,
  data = stability_data
)

# ------------------------------------------------------------
# 9. Recursive CUSUM
# ------------------------------------------------------------

cusum_test <- strucchange::efp(
  formula(stability_model),
  data = model.frame(stability_model),
  type = "Rec-CUSUM"
)

cusum_result <- strucchange::sctest(cusum_test)

print(cusum_result)

cusum_results <- tibble(
  test = "Recursive CUSUM",
  variable = "ARDL coefficient stability",
  statistic = as.numeric(cusum_result$statistic),
  p_value = as.numeric(cusum_result$p.value),
  decision = ifelse(
    cusum_result$p.value > 0.05,
    "Fail to reject H0: parameters are stable",
    "Reject H0: parameter instability detected"
  )
)

# ------------------------------------------------------------
# 10. OLS-based CUSUM
# ------------------------------------------------------------

ols_cusum_test <- strucchange::efp(
  formula(stability_model),
  data = model.frame(stability_model),
  type = "OLS-CUSUM"
)

ols_cusum_result <- strucchange::sctest(ols_cusum_test)

print(ols_cusum_result)

ols_cusum_results <- tibble(
  test = "OLS-based CUSUM",
  variable = "ARDL coefficient stability",
  statistic = as.numeric(ols_cusum_result$statistic),
  p_value = as.numeric(ols_cusum_result$p.value),
  decision = ifelse(
    ols_cusum_result$p.value > 0.05,
    "Fail to reject H0: parameters are stable",
    "Reject H0: parameter instability detected"
  )
)

# ------------------------------------------------------------
# 11. Combine diagnostic results
# ------------------------------------------------------------

diagnostic_results <- bind_rows(
  vif_results,
  bg_results,
  bp_results,
  jb_results,
  reset_results,
  cusum_results,
  ols_cusum_results
)

# ------------------------------------------------------------
# 12. Add significance level and project metadata
# ------------------------------------------------------------

diagnostic_results <- diagnostic_results %>%
  mutate(
    significance_level = 0.05,
    sample_start = min(ardl_data$year),
    sample_end = max(ardl_data$year),
    observations = nrow(ardl_data)
  )

# ------------------------------------------------------------
# 13. Save final diagnostic table
# ------------------------------------------------------------

dir.create(
  "outputs/tables",
  recursive = TRUE,
  showWarnings = FALSE
)

write_csv(
  diagnostic_results,
  "outputs/tables/ardl_diagnostic_tests.csv"
)

# ------------------------------------------------------------
# 14. Display final table
# ------------------------------------------------------------

print(diagnostic_results)

cat("\n============================================================\n")
cat("ARDL diagnostic testing completed successfully.\n")
cat("Output saved to:\n")
cat("outputs/tables/ardl_diagnostic_tests.csv\n")
cat("============================================================\n")
