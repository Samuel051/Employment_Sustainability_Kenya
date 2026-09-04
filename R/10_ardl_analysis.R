# ============================================================
# 10_ardl_analysis.R
# ARDL(1,1,1,1,1) analysis
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

# estimating the fixed ARDL(1,1,1,1,1)

ardl_11111 <- ardl(
  unemployment_ilo ~
    gdp_growth +
    inflation +
    investment_gfcf +
    labour_participation,
  data = ardl_data,
  order = c(1, 1, 1, 1, 1)
)

summary(ardl_11111)


# Saving the coefficients table

ardl_coefficients <- as.data.frame(
  summary(ardl_11111)$coefficients
)

ardl_coefficients$term <- rownames(ardl_coefficients)
rownames(ardl_coefficients) <- NULL

ardl_coefficients <- ardl_coefficients %>%
  select(term, everything())

dir.create(
  "outputs/tables",
  recursive = TRUE,
  showWarnings = FALSE
)

write.csv(
  ardl_coefficients,
  "outputs/tables/ardl_11111_coefficients.csv",
  row.names = FALSE
)

# creating the UECM

uecm_11111 <- uecm(ardl_11111)

summary(uecm_11111)

# Bounds test

bounds_result <- bounds_f_test(
  ardl_11111,
  case = 3,
  exact = TRUE,
  R = 40000
)

bounds_result










