# ============================================================
# 09_combined_structural_breaks.R
# Combined structural-break evidence
# Kenya Employment Sustainability Research
# ============================================================

library(readr)
library(dplyr)

# ------------------------------------------------------------
# 1. Load structural-break results
# ------------------------------------------------------------

lee_strazicich <- read_csv(
  "outputs/tables/lee_strazicich_one_break_results.csv",
  show_col_types = FALSE
)

bai_perron <- read_csv(
  "outputs/tables/bai_perron_break_summary.csv",
  show_col_types = FALSE
)

# ------------------------------------------------------------
# 2. Select the relevant Lee--Strazicich information
# ------------------------------------------------------------

ls_table <- lee_strazicich %>%
  select(
    variable,
    observations,
    ls_break_year = estimated_break_year,
    ls_break_fraction = break_fraction,
    ls_t_statistic = lm_t_statistic,
    ls_critical_5pct = critical_value_5pct,
    ls_decision = decision_5pct
  )

# ------------------------------------------------------------
# 3. Select the relevant Bai--Perron information
# ------------------------------------------------------------

bp_table <- bai_perron %>%
  select(
    variable,
    bp_breaks = bic_selected_breaks,
    bp_break_transitions = break_transitions,
    bp_supF_statistic = supf_statistic,
    bp_supF_p_value = supf_p_value,
    bp_evidence = structural_change_evidence
  )

# ------------------------------------------------------------
# 4. Combine both approaches
# ------------------------------------------------------------

combined_structural_breaks <- ls_table %>%
  left_join(bp_table, by = "variable") %>%
  arrange(match(
    variable,
    c(
      "unemployment_ilo",
      "gdp_growth",
      "inflation",
      "investment_gfcf",
      "labour_participation"
    )
  ))

# ------------------------------------------------------------
# 5. Add a simple interpretation field
# ------------------------------------------------------------

combined_structural_breaks <- combined_structural_breaks %>%
  mutate(
    overall_structural_break_evidence = case_when(
      
      grepl(
        "Reject unit root",
        ls_decision,
        fixed = TRUE
      ) &
        grepl(
          "Evidence",
          bp_evidence,
          fixed = TRUE
        ) ~
        "Strong evidence of structural change",
      
      grepl(
        "Evidence",
        bp_evidence,
        fixed = TRUE
      ) ~
        "Evidence of trend-regime change; LS does not confirm break-stationarity",
      
      grepl(
        "Reject unit root",
        ls_decision,
        fixed = TRUE
      ) ~
        "LS supports break-stationarity; Bai-Perron finds no strong trend-regime change",
      
      TRUE ~
        "Limited/uncertain structural-break evidence"
    )
  )

# ------------------------------------------------------------
# 6. Display
# ------------------------------------------------------------

print(
  combined_structural_breaks,
  n = Inf,
  width = Inf
)

# ------------------------------------------------------------
# 7. Save
# ------------------------------------------------------------

dir.create(
  "outputs/tables",
  recursive = TRUE,
  showWarnings = FALSE
)

write_csv(
  combined_structural_breaks,
  "outputs/tables/combined_structural_break_results.csv"
)

View(combined_structural_breaks)