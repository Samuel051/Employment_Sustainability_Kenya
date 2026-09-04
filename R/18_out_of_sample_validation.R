# ============================================================
# 18_out_of_sample_validation.R
# ARDL out-of-sample validation
# Kenya Employment Sustainability Research
# ============================================================

library(ARDL)
library(readr)
library(dplyr)

# ------------------------------------------------------------
# 1. Load data
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

# ------------------------------------------------------------
# 2. Training and test samples
# ------------------------------------------------------------

train_data <- ardl_data %>%
  filter(year <= 2020)

test_data <- ardl_data %>%
  filter(year >= 2021)

# ------------------------------------------------------------
# 3. Estimate baseline ARDL
# ------------------------------------------------------------

baseline_model <- ardl(
  unemployment_ilo ~
    gdp_growth +
    inflation +
    investment_gfcf +
    labour_participation,
  data = train_data,
  order = c(1, 1, 1, 1, 1)
)

# ------------------------------------------------------------
# 4. Estimate BIC-selected ARDL
# ------------------------------------------------------------

bic_model <- ardl(
  unemployment_ilo ~
    gdp_growth +
    inflation +
    investment_gfcf +
    labour_participation,
  data = train_data,
  order = c(1, 1, 2, 0, 1)
)

# ------------------------------------------------------------
# 5. Extract coefficients
# ------------------------------------------------------------

b_base <- coef(baseline_model)
b_bic  <- coef(bic_model)

# ------------------------------------------------------------
# 6. Helper function for recursive ARDL forecasts
# ------------------------------------------------------------

forecast_ardl <- function(model_coef, train, test, specification) {
  
  history <- train
  
  predictions <- numeric(nrow(test))
  
  for (i in seq_len(nrow(test))) {
    
    current <- test[i, ]
    
    # --------------------------------------------------------
    # Baseline ARDL(1,1,1,1,1)
    # --------------------------------------------------------
    
    if (specification == "baseline") {
      
      y_lag <- tail(history$unemployment_ilo, 1)
      
      gdp_current <- current$gdp_growth
      gdp_lag <- tail(history$gdp_growth, 1)
      
      inflation_current <- current$inflation
      inflation_lag <- tail(history$inflation, 1)
      
      investment_current <- current$investment_gfcf
      investment_lag <- tail(history$investment_gfcf, 1)
      
      labour_current <- current$labour_participation
      labour_lag <- tail(history$labour_participation, 1)
      
      predictions[i] <-
        model_coef["(Intercept)"] +
        model_coef["L(unemployment_ilo, 1)"] * y_lag +
        model_coef["gdp_growth"] * gdp_current +
        model_coef["L(gdp_growth, 1)"] * gdp_lag +
        model_coef["inflation"] * inflation_current +
        model_coef["L(inflation, 1)"] * inflation_lag +
        model_coef["investment_gfcf"] * investment_current +
        model_coef["L(investment_gfcf, 1)"] * investment_lag +
        model_coef["labour_participation"] * labour_current +
        model_coef["L(labour_participation, 1)"] * labour_lag
    }
    
    # --------------------------------------------------------
    # BIC ARDL(1,1,2,0,1)
    # --------------------------------------------------------
    
    if (specification == "bic") {
      
      y_lag <- tail(history$unemployment_ilo, 1)
      
      gdp_current <- current$gdp_growth
      gdp_lag <- tail(history$gdp_growth, 1)
      
      inflation_current <- current$inflation
      inflation_lag1 <- tail(history$inflation, 1)
      inflation_lag2 <-
        if (nrow(history) >= 2) {
          history$inflation[nrow(history) - 1]
        } else {
          NA_real_
        }
      
      investment_current <- current$investment_gfcf
      
      labour_current <- current$labour_participation
      labour_lag <- tail(history$labour_participation, 1)
      
      predictions[i] <-
        model_coef["(Intercept)"] +
        model_coef["L(unemployment_ilo, 1)"] * y_lag +
        model_coef["gdp_growth"] * gdp_current +
        model_coef["L(gdp_growth, 1)"] * gdp_lag +
        model_coef["inflation"] * inflation_current +
        model_coef["L(inflation, 1)"] * inflation_lag1 +
        model_coef["L(inflation, 2)"] * inflation_lag2 +
        model_coef["investment_gfcf"] * investment_current +
        model_coef["labour_participation"] * labour_current +
        model_coef["L(labour_participation, 1)"] * labour_lag
    }
    
    # Add actual observation to history.
    #
    # This creates a recursive forecasting exercise:
    # at each subsequent year, the previous observed
    # unemployment value becomes available.
    
    history <- bind_rows(history, current)
  }
  
  predictions
}

# ------------------------------------------------------------
# 7. Generate forecasts
# ------------------------------------------------------------

baseline_forecast <- forecast_ardl(
  b_base,
  train_data,
  test_data,
  "baseline"
)

bic_forecast <- forecast_ardl(
  b_bic,
  train_data,
  test_data,
  "bic"
)

# ------------------------------------------------------------
# 8. Create validation table
# ------------------------------------------------------------

validation_results <- tibble(
  year = test_data$year,
  actual_unemployment = test_data$unemployment_ilo,
  baseline_forecast = baseline_forecast,
  bic_forecast = bic_forecast
) %>%
  mutate(
    baseline_error =
      actual_unemployment - baseline_forecast,
    
    bic_error =
      actual_unemployment - bic_forecast,
    
    baseline_abs_error =
      abs(baseline_error),
    
    bic_abs_error =
      abs(bic_error),
    
    baseline_squared_error =
      baseline_error^2,
    
    bic_squared_error =
      bic_error^2
  )

print(validation_results)

# ------------------------------------------------------------
# 9. Calculate forecasting metrics
# ------------------------------------------------------------

rmse_baseline <- sqrt(
  mean(validation_results$baseline_squared_error)
)

rmse_bic <- sqrt(
  mean(validation_results$bic_squared_error)
)

mae_baseline <- mean(
  validation_results$baseline_abs_error
)

mae_bic <- mean(
  validation_results$bic_abs_error
)

forecast_metrics <- tibble(
  model = c(
    "Baseline ARDL(1,1,1,1,1)",
    "BIC ARDL(1,1,2,0,1)"
  ),
  RMSE = c(
    rmse_baseline,
    rmse_bic
  ),
  MAE = c(
    mae_baseline,
    mae_bic
  )
)

print(forecast_metrics)

# ------------------------------------------------------------
# 10. Determine preferred forecasting model
# ------------------------------------------------------------

preferred_model <- forecast_metrics %>%
  arrange(RMSE) %>%
  slice(1) %>%
  pull(model)

cat("\nPreferred model based on RMSE:", preferred_model, "\n")

# ------------------------------------------------------------
# 11. Save results
# ------------------------------------------------------------

dir.create(
  "outputs/tables",
  recursive = TRUE,
  showWarnings = FALSE
)

write_csv(
  validation_results,
  "outputs/tables/ardl_out_of_sample_validation.csv"
)

write_csv(
  forecast_metrics,
  "outputs/tables/ardl_forecast_performance.csv"
)

cat("\nOut-of-sample validation completed successfully.\n")