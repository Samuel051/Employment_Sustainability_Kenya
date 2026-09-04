# ============================================================
# 14_short_run_ardl.R
# Short-run ARDL / UECM analysis
# Kenya Employment Sustainability Research
# ============================================================

library(ARDL)
library(readr)
library(dplyr)
library(tibble)

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
# 2. Estimate baseline ARDL(1,1,1,1,1)
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
# 3. Convert ARDL to UECM
# ------------------------------------------------------------

uecm_11111 <- uecm(ardl_11111)

summary(uecm_11111)


# ------------------------------------------------------------
# 4. Extract short-run coefficients
# ------------------------------------------------------------

uecm_summary <- summary(uecm_11111)

short_run_coefficients <- as.data.frame(
  uecm_summary$coefficients
)

short_run_coefficients$term <- rownames(
  short_run_coefficients
)

rownames(short_run_coefficients) <- NULL

short_run_coefficients <- short_run_coefficients %>%
  select(term, everything())


# ------------------------------------------------------------
# 5. Identify short-run variables
# ------------------------------------------------------------

short_run_results <- short_run_coefficients %>%
  filter(
    grepl("^d\\(", term)
  ) %>%
  mutate(
    interpretation = case_when(
      grepl("gdp_growth", term) ~
        "Short-run change in GDP growth",
      grepl("inflation", term) ~
        "Short-run change in inflation",
      grepl("investment_gfcf", term) ~
        "Short-run change in investment",
      grepl("labour_participation", term) ~
        "Short-run change in labour participation",
      TRUE ~ term
    )
  )


# ------------------------------------------------------------
# 6. Print results
# ------------------------------------------------------------

print(short_run_results)


# ------------------------------------------------------------
# 7. Save results
# ------------------------------------------------------------

dir.create(
  "outputs/tables",
  recursive = TRUE,
  showWarnings = FALSE
)

write_csv(
  short_run_coefficients,
  "outputs/tables/ardl_uecm_coefficients.csv"
)

write_csv(
  short_run_results,
  "outputs/tables/ardl_short_run_results.csv"
)


# ------------------------------------------------------------
# 8. Create hypothesis-oriented summary
# ------------------------------------------------------------

hypothesis_results <- short_run_results %>%
  mutate(
    significance = case_when(
      `Pr(>|t|)` < 0.01 ~ "Significant at 1%",
      `Pr(>|t|)` < 0.05 ~ "Significant at 5%",
      `Pr(>|t|)` < 0.10 ~ "Significant at 10%",
      TRUE ~ "Not statistically significant"
    ),
    direction = case_when(
      Estimate > 0 ~ "Positive",
      Estimate < 0 ~ "Negative",
      TRUE ~ "No effect"
    )
  ) %>%
  select(
    term,
    interpretation,
    Estimate,
    `Std. Error`,
    `t value`,
    `Pr(>|t|)`,
    direction,
    significance
  )

print(hypothesis_results)

write_csv(
  hypothesis_results,
  "outputs/tables/ardl_short_run_hypothesis_results.csv"
)