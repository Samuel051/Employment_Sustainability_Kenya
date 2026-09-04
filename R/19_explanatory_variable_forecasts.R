# ============================================================
# 19_explanatory_variable_forecasts.R
# Forecast explanatory variables: 2026-2030
# Kenya Employment Sustainability Research
# ============================================================

library(readr)
library(dplyr)
library(forecast)

# ------------------------------------------------------------
# 1. Load data
# ------------------------------------------------------------

data <- read_csv(
  "Data/final/kenya_employment_model.csv",
  show_col_types = FALSE
)

model_vars <- c(
  "gdp_growth",
  "inflation",
  "investment_gfcf",
  "labour_participation"
)

forecast_data <- data %>%
  select(year, all_of(model_vars)) %>%
  filter(if_all(all_of(model_vars), ~ !is.na(.))) %>%
  arrange(year)

# ------------------------------------------------------------
# 2. Confirm sample
# ------------------------------------------------------------

print(forecast_data)

# ------------------------------------------------------------
# 3. Forecast horizon
# ------------------------------------------------------------

h <- 5

# ------------------------------------------------------------
# 4. Function to compare forecasting methods
# ------------------------------------------------------------

evaluate_models <- function(x, test_size = 5) {
  
  n <- length(x)
  
  train <- x[1:(n - test_size)]
  test  <- x[(n - test_size + 1):n]
  
  ts_train <- ts(train, frequency = 1)
  
  # ----------------------------------------------------------
  # Naive
  # ----------------------------------------------------------
  
  naive_fit <- naive(ts_train, h = test_size)
  
  # ----------------------------------------------------------
  # Drift
  # ----------------------------------------------------------
  
  drift_fit <- rwf(
    ts_train,
    h = test_size,
    drift = TRUE
  )
  
  # ----------------------------------------------------------
  # ARIMA
  # ----------------------------------------------------------
  
  arima_fit <- auto.arima(
    ts_train,
    seasonal = FALSE,
    stepwise = TRUE,
    approximation = FALSE
  )
  
  arima_fc <- forecast(
    arima_fit,
    h = test_size
  )
  
  # ----------------------------------------------------------
  # ETS
  # ----------------------------------------------------------
  
  ets_fit <- ets(ts_train)
  
  ets_fc <- forecast(
    ets_fit,
    h = test_size
  )
  
  # ----------------------------------------------------------
  # Calculate metrics
  # ----------------------------------------------------------
  
  rmse <- function(actual, predicted) {
    sqrt(mean((actual - predicted)^2))
  }
  
  mae <- function(actual, predicted) {
    mean(abs(actual - predicted))
  }
  
  results <- tibble(
    model = c(
      "Naive",
      "Drift",
      "ARIMA",
      "ETS"
    ),
    
    RMSE = c(
      rmse(test, as.numeric(naive_fit$mean)),
      rmse(test, as.numeric(drift_fit$mean)),
      rmse(test, as.numeric(arima_fc$mean)),
      rmse(test, as.numeric(ets_fc$mean))
    ),
    
    MAE = c(
      mae(test, as.numeric(naive_fit$mean)),
      mae(test, as.numeric(drift_fit$mean)),
      mae(test, as.numeric(arima_fc$mean)),
      mae(test, as.numeric(ets_fc$mean))
    )
  )
  
  return(results)
}

# ------------------------------------------------------------
# 5. Evaluate each explanatory variable
# ------------------------------------------------------------

evaluation_results <- list()

for (variable in model_vars) {
  
  x <- forecast_data[[variable]]
  
  cat("\n============================================\n")
  cat("Variable:", variable, "\n")
  cat("============================================\n")
  
  results <- evaluate_models(x)
  
  print(results)
  
  evaluation_results[[variable]] <- results
}

# ------------------------------------------------------------
# 6. Combine evaluation results
# ------------------------------------------------------------

forecast_model_comparison <- bind_rows(
  lapply(
    names(evaluation_results),
    function(variable) {
      
      evaluation_results[[variable]] %>%
        mutate(variable = variable) %>%
        select(
          variable,
          model,
          RMSE,
          MAE
        )
    }
  )
)

print(forecast_model_comparison)

# ------------------------------------------------------------
# 7. Select best model based on RMSE
# ------------------------------------------------------------

selected_models <- forecast_model_comparison %>%
  group_by(variable) %>%
  arrange(RMSE, .by_group = TRUE) %>%
  slice(1) %>%
  ungroup()

print(selected_models)

# ------------------------------------------------------------
# 8. Generate final 2026-2030 forecasts
# ------------------------------------------------------------

future_years <- 2026:2030

forecast_list <- list()

for (variable in model_vars) {
  
  x <- forecast_data[[variable]]
  
  selected_model <- selected_models %>%
    filter(variable == !!variable) %>%
    pull(model)
  
  ts_x <- ts(x, frequency = 1)
  
  if (selected_model == "Naive") {
    
    fit <- naive(ts_x, h = h)
    fc <- forecast(fit, h = h)
    
  } else if (selected_model == "Drift") {
    
    fit <- rwf(
      ts_x,
      h = h,
      drift = TRUE
    )
    
    fc <- forecast(
      fit,
      h = h
    )
    
  } else if (selected_model == "ARIMA") {
    
    fit <- auto.arima(
      ts_x,
      seasonal = FALSE,
      stepwise = TRUE,
      approximation = FALSE
    )
    
    fc <- forecast(
      fit,
      h = h
    )
    
  } else if (selected_model == "ETS") {
    
    fit <- ets(ts_x)
    
    fc <- forecast(
      fit,
      h = h
    )
  }
  
  forecast_list[[variable]] <- tibble(
    year = future_years,
    variable = variable,
    model = selected_model,
    forecast = as.numeric(fc$mean),
    lower_80 = as.numeric(fc$lower[, "80%"]),
    upper_80 = as.numeric(fc$upper[, "80%"]),
    lower_95 = as.numeric(fc$lower[, "95%"]),
    upper_95 = as.numeric(fc$upper[, "95%"])
  )
}

# ------------------------------------------------------------
# 9. Combine forecasts
# ------------------------------------------------------------

explanatory_forecasts_long <- bind_rows(
  forecast_list
)

print(explanatory_forecasts_long)

# ------------------------------------------------------------
# 10. Convert to wide format
# ------------------------------------------------------------

explanatory_forecasts <- explanatory_forecasts_long %>%
  select(
    year,
    variable,
    forecast
  ) %>%
  tidyr::pivot_wider(
    names_from = variable,
    values_from = forecast
  )

print(explanatory_forecasts)

# ------------------------------------------------------------
# 11. Save outputs
# ------------------------------------------------------------

dir.create(
  "outputs/tables",
  recursive = TRUE,
  showWarnings = FALSE
)

write_csv(
  forecast_model_comparison,
  "outputs/tables/explanatory_forecast_model_comparison.csv"
)

write_csv(
  selected_models,
  "outputs/tables/explanatory_forecast_selected_models.csv"
)

write_csv(
  explanatory_forecasts_long,
  "outputs/tables/explanatory_variable_forecasts_long.csv"
)

write_csv(
  explanatory_forecasts,
  "outputs/tables/explanatory_variable_forecasts.csv"
)

cat("\n============================================\n")
cat("Explanatory variable forecasting completed.\n")
cat("Forecast horizon: 2026-2030\n")
cat("============================================\n")