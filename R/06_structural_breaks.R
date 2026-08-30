# ============================================================
# 06_structural_breaks.R
# Historically motivated candidate periods for structural change
# Kenya Employment Sustainability Project
# ============================================================

library(readr)
library(dplyr)

# ------------------------------------------------------------
# 1. Create output directory
# ------------------------------------------------------------

dir.create(
  "outputs/tables",
  recursive = TRUE,
  showWarnings = FALSE
)

# ------------------------------------------------------------
# 2. Define historically motivated candidate periods
# ------------------------------------------------------------
#
# IMPORTANT:
# These are NOT assumed structural breaks.
#
# They are historically/policy motivated periods that may warrant
# investigation for possible changes in the behaviour of the
# economic and labour-market variables.
#
# The actual statistical break may:
#   - occur in the same year,
#   - occur after the event/policy,
#   - occur before the event due to earlier transmission,
#   - persist across several years, or
#   - not exist at all.
#
# This list is also NOT exhaustive. Other policies, shocks,
# institutional changes, and external events may have affected
# the variables during the study period.
# ------------------------------------------------------------

candidate_breaks <- tibble(
  
  candidate_period = c(
    "1991-1993",
    "1992-1995",
    "2007-2009",
    "2010-2013",
    "2014-2018",
    "2016-2019",
    "2019-2021",
    "2020-2021",
    "2021-2023"
  ),
  
  event_or_policy_date = c(
    "1991-1993",
    "1992",
    "2007",
    "2010",
    "2014",
    "2016",
    "2019",
    "2020",
    "2021"
  ),
  
  event_or_policy = c(
    
    "Return to multiparty politics and early-1990s political and economic disruption",
    
    "Early-1990s economic and political disruption, including the Goldenberg-era crisis, donor funding concerns, and ethnic clashes",
    
    "2007 general election and subsequent post-election violence",
    
    "Promulgation of the 2010 Constitution and associated institutional transition",
    
    "Observed investment/GFCF turning point and subsequent decline",
    
    "Introduction of the interest-rate cap and possible implications for credit and investment",
    
    "Repeal of the interest-rate cap and possible adjustment in credit and investment conditions",
    
    "COVID-19 pandemic, economic restrictions, and major economic disruption",
    
    "Post-COVID economic recovery"
  ),
  
  potential_transmission_window = c(
    
    "1991-1995",
    
    "1992-1995",
    
    "2007-2009",
    
    "2010-2013",
    
    "2014-2018",
    
    "2016-2019",
    
    "2019-2021",
    
    "2020-2021",
    
    "2021-2023"
  ),
  
  variables_potentially_affected = c(
    
    "GDP growth; inflation; unemployment; investment; labour participation",
    
    "GDP growth; inflation; unemployment; investment",
    
    "GDP growth; unemployment; investment; labour participation",
    
    "GDP growth; investment; labour participation",
    
    "Investment",
    
    "Investment; GDP growth",
    
    "Investment; GDP growth",
    
    "GDP growth; unemployment; labour participation; investment",
    
    "GDP growth; unemployment; labour participation"
  ),
  
  interpretation_status = c(
    
    "Candidate period; not statistically confirmed",
    
    "Candidate period; not statistically confirmed",
    
    "Candidate period; not statistically confirmed",
    
    "Candidate period; not statistically confirmed",
    
    "Candidate period; not statistically confirmed",
    
    "Candidate period; not statistically confirmed",
    
    "Candidate period; not statistically confirmed",
    
    "Candidate period; not statistically confirmed",
    
    "Candidate period; not statistically confirmed"
  )
)

# ------------------------------------------------------------
# 3. Add methodological note
# ------------------------------------------------------------

methodological_note <- tibble(
  
  note_type = c(
    "Purpose",
    "Interpretation",
    "Timing",
    "Exhaustiveness",
    "Causality"
  ),
  
  note = c(
    
    "The candidate periods provide historically and economically motivated periods for subsequent structural-break investigation.",
    
    "A candidate period does not imply that a structural break actually occurred.",
    
    "The statistical break may occur before, during, or after the identified event or policy because economic effects can be transmitted with lags.",
    
    "The candidate periods are illustrative rather than exhaustive; other policies, institutional changes, domestic developments, and external shocks may also have affected the variables.",
    
    "Identification of a statistical break does not by itself establish that the associated event or policy caused the change."
  )
)

# ------------------------------------------------------------
# 4. Display results
# ------------------------------------------------------------

print(candidate_breaks, n = Inf)

cat("\n============================================================\n")
cat("METHODOLOGICAL NOTES\n")
cat("============================================================\n")

print(methodological_note, n = Inf)

# ------------------------------------------------------------
# 5. Save outputs
# ------------------------------------------------------------

write_csv(
  candidate_breaks,
  "outputs/tables/hypothesised_structural_breaks.csv"
)

write_csv(
  methodological_note,
  "outputs/tables/structural_break_methodological_notes.csv"
)

# ------------------------------------------------------------
# 6. Confirm output files
# ------------------------------------------------------------

cat("\n============================================================\n")
cat("OUTPUT FILES CREATED\n")
cat("============================================================\n")

cat(
  "1. outputs/tables/hypothesised_structural_breaks.csv\n"
)

cat(
  "2. outputs/tables/structural_break_methodological_notes.csv\n"
)

cat("\nStructural-break candidate table created successfully.\n")