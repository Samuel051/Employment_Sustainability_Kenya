# ============================================================
# 16_short_run_robustness.R
# Final short-run ARDL robustness comparison
# Kenya Employment Sustainability Research
# ============================================================

library(readr)
library(dplyr)

# ------------------------------------------------------------
# 1. Baseline short-run results
# ------------------------------------------------------------

baseline <- tibble(
  variable = c(
    "GDP growth",
    "Inflation",
    "Investment (GFCF)",
    "Labour participation"
  ),
  baseline_estimate = c(
    -0.024295325,
    0.001418717,
    0.033554265,
    -0.348436823
  ),
  baseline_p = c(
    0.009728418,
    0.5302722,
    0.01005580,
    2.763269e-13
  )
)

# ------------------------------------------------------------
# 2. BIC-selected short-run results
# ------------------------------------------------------------

bic <- tibble(
  variable = c(
    "GDP growth",
    "Inflation",
    "Investment (GFCF)",
    "Labour participation"
  ),
  bic_estimate = c(
    -0.023014550,
    0.001114335,
    0.039076387,
    -0.348069593
  ),
  bic_p = c(
    0.01023547,
    0.6075977,
    0.001158294,
    1.384603e-13
  )
)

# ------------------------------------------------------------
# 3. Combine results
# ------------------------------------------------------------

short_run_robustness <- baseline %>%
  left_join(bic, by = "variable") %>%
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
    
    sign_consistent = baseline_direction == bic_direction,
    
    baseline_significance = case_when(
      baseline_p < 0.01 ~ "Significant at 1%",
      baseline_p < 0.05 ~ "Significant at 5%",
      baseline_p < 0.10 ~ "Significant at 10%",
      TRUE ~ "Not significant"
    ),
    
    bic_significance = case_when(
      bic_p < 0.01 ~ "Significant at 1%",
      bic_p < 0.05 ~ "Significant at 5%",
      bic_p < 0.10 ~ "Significant at 10%",
      TRUE ~ "Not significant"
    ),
    
    magnitude_change_pct =
      ((bic_estimate - baseline_estimate) /
         abs(baseline_estimate)) * 100,
    
    significance_consistent =
      baseline_significance == bic_significance
  )

# ------------------------------------------------------------
# 4. Add interpretation
# ------------------------------------------------------------

short_run_robustness <- short_run_robustness %>%
  mutate(
    interpretation = case_when(
      
      variable == "GDP growth" &
        sign_consistent &
        baseline_p < 0.05 &
        bic_p < 0.05 ~
        "Negative and statistically significant in both specifications",
      
      variable == "Inflation" &
        sign_consistent &
        baseline_p >= 0.05 &
        bic_p >= 0.05 ~
        "Positive but statistically insignificant in both specifications",
      
      variable == "Investment (GFCF)" &
        sign_consistent &
        baseline_p < 0.05 &
        bic_p < 0.05 ~
        "Positive and statistically significant in both specifications",
      
      variable == "Labour participation" &
        sign_consistent &
        baseline_p < 0.01 &
        bic_p < 0.01 ~
        "Negative and highly statistically significant in both specifications",
      
      TRUE ~
        "Results differ across specifications"
    )
  )

# ------------------------------------------------------------
# 5. Display final table
# ------------------------------------------------------------

print(short_run_robustness)

# ------------------------------------------------------------
# 6. Save
# ------------------------------------------------------------

dir.create(
  "outputs/tables",
  recursive = TRUE,
  showWarnings = FALSE
)

write_csv(
  short_run_robustness,
  "outputs/tables/ardl_short_run_robustness.csv"
)

cat("\nFinal short-run robustness table saved successfully.\n")