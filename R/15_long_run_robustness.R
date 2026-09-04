# ============================================================
# 15_long_run_robustness.R
# Long-run ARDL robustness comparison
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
# 2. Baseline ARDL(1,1,1,1,1)
# ------------------------------------------------------------

baseline_ardl <- ardl(
  unemployment_ilo ~
    gdp_growth +
    inflation +
    investment_gfcf +
    labour_participation,
  data = ardl_data,
  order = c(1, 1, 1, 1, 1)
)


# ------------------------------------------------------------
# 3. BIC-selected ARDL(1,1,2,0,1)
# ------------------------------------------------------------

bic_ardl <- ardl(
  unemployment_ilo ~
    gdp_growth +
    inflation +
    investment_gfcf +
    labour_participation,
  data = ardl_data,
  order = c(1, 1, 2, 0, 1)
)


# ------------------------------------------------------------
# 4. Extract long-run coefficients
# ------------------------------------------------------------

baseline_lr <- multipliers(
  baseline_ardl,
  type = "lr"
)

bic_lr <- multipliers(
  bic_ardl,
  type = "lr"
)


# ------------------------------------------------------------
# 5. Convert to data frames
# ------------------------------------------------------------

baseline_lr_df <- as.data.frame(baseline_lr)

baseline_lr_df$term <- rownames(baseline_lr_df)
rownames(baseline_lr_df) <- NULL

baseline_lr_df <- baseline_lr_df %>%
  select(term, everything()) %>%
  mutate(
    model = "Baseline ARDL(1,1,1,1,1)"
  )


bic_lr_df <- as.data.frame(bic_lr)

bic_lr_df$term <- rownames(bic_lr_df)
rownames(bic_lr_df) <- NULL

bic_lr_df <- bic_lr_df %>%
  select(term, everything()) %>%
  mutate(
    model = "BIC ARDL(1,1,2,0,1)"
  )


# ------------------------------------------------------------
# 6. Create comparison table
# ------------------------------------------------------------

long_run_comparison <- full_join(
  baseline_lr_df %>%
    select(term, Estimate, `Std. Error`, `t value`, `Pr(>|t|)`) %>%
    rename(
      baseline_estimate = Estimate,
      baseline_se = `Std. Error`,
      baseline_t = `t value`,
      baseline_p = `Pr(>|t|)`
    ),
  
  bic_lr_df %>%
    select(term, Estimate, `Std. Error`, `t value`, `Pr(>|t|)`) %>%
    rename(
      bic_estimate = Estimate,
      bic_se = `Std. Error`,
      bic_t = `t value`,
      bic_p = `Pr(>|t|)`
    ),
  
  by = "term"
)


# ------------------------------------------------------------
# 7. Add sign comparison
# ------------------------------------------------------------

long_run_comparison <- long_run_comparison %>%
  mutate(
    baseline_direction = case_when(
      baseline_estimate > 0 ~ "Positive",
      baseline_estimate < 0 ~ "Negative",
      TRUE ~ "Zero"
    ),
    
    bic_direction = case_when(
      bic_estimate > 0 ~ "Positive",
      bic_estimate < 0 ~ "Negative",
      TRUE ~ "Zero"
    ),
    
    sign_consistent = baseline_direction == bic_direction
  )


# ------------------------------------------------------------
# 8. Display results
# ------------------------------------------------------------

print(long_run_comparison)


# ------------------------------------------------------------
# 9. Save results
# ------------------------------------------------------------

dir.create(
  "outputs/tables",
  recursive = TRUE,
  showWarnings = FALSE
)

write_csv(
  long_run_comparison,
  "outputs/tables/long_run_ardl_robustness_comparison.csv"
)

cat("\nLong-run robustness comparison saved successfully.\n")