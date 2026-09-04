# ============================================================
# 20_ardl_forecast.R
# Final ARDL unemployment forecasting
# Kenya Employment Sustainability Research
# ============================================================

library(ARDL)
library(readr)
library(dplyr)
library(tidyr)
library(ggplot2)

# ------------------------------------------------------------
# 1. Load historical model data
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
# 2. Estimate preferred BIC ARDL model
# ------------------------------------------------------------

ardl_bic <- ardl(
  unemployment_ilo ~
    gdp_growth +
    inflation +
    investment_gfcf +
    labour_participation,
  data = ardl_data,
  order = c(1, 1, 2, 0, 1)
)

print(summary(ardl_bic))

# ------------------------------------------------------------
# 3. Load explanatory-variable forecasts
# ------------------------------------------------------------

forecast_vars <- read_csv(
  "outputs/tables/explanatory_variable_forecasts.csv",
  show_col_types = FALSE
)

print(forecast_vars)

# ------------------------------------------------------------
# 4. Check forecast horizon
# ------------------------------------------------------------

stopifnot(all(forecast_vars$year == 2026:2030))

# ------------------------------------------------------------
# 5. Construct forecasting dataset
# ------------------------------------------------------------

historical <- ardl_data %>%
  select(
    year,
    unemployment_ilo,
    gdp_growth,
    inflation,
    investment_gfcf,
    labour_participation
  ) %>%
  mutate(period = "Historical")

future <- forecast_vars %>%
  select(
    year,
    gdp_growth,
    inflation,
    investment_gfcf,
    labour_participation
  ) %>%
  mutate(
    unemployment_ilo = NA_real_,
    period = "Forecast"
  ) %>%
  select(
    year,
    unemployment_ilo,
    gdp_growth,
    inflation,
    investment_gfcf,
    labour_participation,
    period
  )

forecast_data <- bind_rows(
  historical,
  future
) %>%
  arrange(year)

# ------------------------------------------------------------
# 6. Dynamic forecasting
# ------------------------------------------------------------
#
# IMPORTANT:
# The forecast uses the estimated ARDL coefficients together
# with the historical unemployment value and forecast values
# of the explanatory variables.
#
# We generate the forecasts recursively for 2026-2030.

coef_bic <- coef(ardl_bic)

b0 <- coef_bic["(Intercept)"]

rho1 <- coef_bic["L(unemployment_ilo, 1)"]

beta_gdp_0 <- coef_bic["gdp_growth"]
beta_gdp_1 <- coef_bic["L(gdp_growth, 1)"]

beta_inf_0 <- coef_bic["inflation"]
beta_inf_1 <- coef_bic["L(inflation, 1)"]
beta_inf_2 <- coef_bic["L(inflation, 2)"]

beta_inv_0 <- coef_bic["investment_gfcf"]

beta_lab_0 <- coef_bic["labour_participation"]
beta_lab_1 <- coef_bic["L(labour_participation, 1)"]

# ------------------------------------------------------------
# 7. Recursive point forecasts
# ------------------------------------------------------------

forecast_results <- forecast_vars %>%
  arrange(year) %>%
  mutate(
    unemployment_forecast = NA_real_
  )

# Historical values required for lagged variables
last_unemployment <- tail(ardl_data$unemployment_ilo, 1)

last_gdp <- tail(ardl_data$gdp_growth, 1)

last_inflation <- tail(ardl_data$inflation, 1)
second_last_inflation <- tail(ardl_data$inflation, 2)[1]

last_labour <- tail(ardl_data$labour_participation, 1)

for (i in seq_len(nrow(forecast_results))) {
  
  gdp_t <- forecast_results$gdp_growth[i]
  
  inflation_t <- forecast_results$inflation[i]
  
  investment_t <- forecast_results$investment_gfcf[i]
  
  labour_t <- forecast_results$labour_participation[i]
  
  unemployment_t <-
    b0 +
    rho1 * last_unemployment +
    beta_gdp_0 * gdp_t +
    beta_gdp_1 * last_gdp +
    beta_inf_0 * inflation_t +
    beta_inf_1 * last_inflation +
    beta_inf_2 * second_last_inflation +
    beta_inv_0 * investment_t +
    beta_lab_0 * labour_t +
    beta_lab_1 * last_labour
  
  forecast_results$unemployment_forecast[i] <- unemployment_t
  
  # Update recursive lags
  last_unemployment <- unemployment_t
  
  second_last_inflation <- last_inflation
  last_inflation <- inflation_t
  
  last_gdp <- gdp_t
  
  last_labour <- labour_t
}

# ------------------------------------------------------------
# 8. Calculate approximate forecast uncertainty
# ------------------------------------------------------------
#
# We use the ARDL residual standard error as the base
# conditional forecast-error scale.
#
# The intervals are labelled approximate because uncertainty
# also comes from forecasting the explanatory variables.

residual_sd <- summary(ardl_bic)$sigma

forecast_results <- forecast_results %>%
  mutate(
    horizon = row_number(),
    
    forecast_se =
      residual_sd * sqrt(horizon),
    
    lower_80 =
      unemployment_forecast -
      qnorm(0.90) * forecast_se,
    
    upper_80 =
      unemployment_forecast +
      qnorm(0.90) * forecast_se,
    
    lower_95 =
      unemployment_forecast -
      qnorm(0.975) * forecast_se,
    
    upper_95 =
      unemployment_forecast +
      qnorm(0.975) * forecast_se
  )

# ------------------------------------------------------------
# 9. Final forecast table
# ------------------------------------------------------------

final_forecast <- forecast_results %>%
  select(
    year,
    gdp_growth,
    inflation,
    investment_gfcf,
    labour_participation,
    unemployment_forecast,
    lower_80,
    upper_80,
    lower_95,
    upper_95
  )

print(final_forecast)

# ------------------------------------------------------------
# 10. Save forecast table
# ------------------------------------------------------------

dir.create(
  "outputs/tables",
  recursive = TRUE,
  showWarnings = FALSE
)

write_csv(
  final_forecast,
  "outputs/tables/final_unemployment_forecast_2026_2030.csv"
)

# ------------------------------------------------------------
# 11. Historical + forecast series
# ------------------------------------------------------------

historical_plot <- ardl_data %>%
  select(year, unemployment_ilo) %>%
  mutate(type = "Historical") %>%
  rename(unemployment = unemployment_ilo)

forecast_plot <- final_forecast %>%
  transmute(
    year,
    unemployment = unemployment_forecast,
    type = "Forecast"
  )

plot_data <- bind_rows(
  historical_plot,
  forecast_plot
) %>%
  arrange(year)

# ------------------------------------------------------------
# 12. Forecast figure
# ------------------------------------------------------------

p <- ggplot() +
  
  geom_line(
    data = historical_plot,
    aes(x = year, y = unemployment),
    linewidth = 0.8
  ) +
  
  geom_line(
    data = forecast_plot,
    aes(x = year, y = unemployment),
    linewidth = 0.8,
    linetype = "dashed"
  ) +
  
  geom_ribbon(
    data = final_forecast,
    aes(
      x = year,
      ymin = lower_95,
      ymax = upper_95
    ),
    alpha = 0.15
  ) +
  
  geom_ribbon(
    data = final_forecast,
    aes(
      x = year,
      ymin = lower_80,
      ymax = upper_80
    ),
    alpha = 0.25
  ) +
  
  geom_vline(
    xintercept = 2025,
    linetype = "dotted"
  ) +
  
  labs(
    title = "Kenya Unemployment Forecast, 2026–2030",
    subtitle = "BIC-selected ARDL(1,1,2,0,1)",
    x = "Year",
    y = "Unemployment rate (%)"
  ) +
  
  theme_minimal()

print(p)

# ------------------------------------------------------------
# 13. Save figure
# ------------------------------------------------------------

dir.create(
  "outputs/figures",
  recursive = TRUE,
  showWarnings = FALSE
)

ggsave(
  "outputs/figures/final_unemployment_forecast_2026_2030.png",
  plot = p,
  width = 10,
  height = 6,
  dpi = 300
)

# ------------------------------------------------------------
# 14. Completion message
# ------------------------------------------------------------

cat("\n============================================\n")
cat("Final ARDL unemployment forecasting completed.\n")
cat("Model: BIC ARDL(1,1,2,0,1)\n")
cat("Forecast horizon: 2026-2030\n")
cat("============================================\n")