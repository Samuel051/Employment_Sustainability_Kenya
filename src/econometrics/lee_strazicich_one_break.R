# Lee--Strazicich minimum LM unit-root test (one structural break)
#
# Copyright (C) 2015 Johannes Lips
# Adapted for this project by the Kenya Employment Sustainability project,
# 2026-08-30.  This focused interface retains the one-break Model C
# (intercept and trend shift) used by the analysis script.
#
# Upstream: https://github.com/hannes101/LeeStrazicichUnitRoot
# The upstream implementation is based on the work of Junsoo Lee and Mark C.
# Strazicich and on the RATS procedure by Tom Doan; see NOTICE.md.
#
# This file is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free
# Software Foundation, either version 3 of the License, or (at your option)
# any later version.  It is distributed without any warranty; see GPL-3.0.txt.

#' Minimum LM unit-root test with one endogenous level-and-trend break
#'
#' Implements the one-break Model C statistic of Lee and Strazicich (2004).
#' The break is searched over a trimmed interior of the sample and is included
#' under both the unit-root null and the stationary alternative.
#'
#' @param y Numeric, complete time series.
#' @param trim Proportion omitted at each end when searching break locations.
#' @param lags Fixed number of augmented differences.  For short annual
#'   samples, zero is a defensible parsimonious default.
#' @return A list containing the minimum LM t-statistic, break position,
#'   break fraction, lags and interpolated asymptotic critical values.
lee_strazicich_one_break <- function(y, trim = 0.15, lags = 0L) {
  if (!is.numeric(y) || anyNA(y) || length(y) < 20L) {
    stop("y must be a complete numeric series with at least 20 observations.")
  }
  if (!is.numeric(trim) || length(trim) != 1L || trim <= 0 || trim >= 0.5) {
    stop("trim must be a single number strictly between 0 and 0.5.")
  }
  lags <- as.integer(lags)
  if (is.na(lags) || lags < 0L) stop("lags must be a non-negative integer.")

  n <- length(y)
  first_break <- ceiling(trim * n)
  last_break <- floor((1 - trim) * n)
  candidates <- seq.int(first_break, last_break)
  if (length(candidates) < 1L || n - 1L - lags <= 5L) {
    stop("The sample is too short for the requested trim and lag length.")
  }

  lm_statistic <- function(break_position) {
    time <- seq_len(n)
    d_level <- as.numeric(time > break_position)
    d_trend <- pmax(0, time - break_position)
    z <- cbind(time = time, level_shift = d_level, trend_shift = d_trend)
    delta_y <- diff(y)
    delta_z <- apply(z, 2L, diff)

    # Detrending under the null produces the LM transformed series S_t.
    detrended <- lm.fit(x = delta_z, y = delta_y)$residuals
    s_tilde <- c(0, cumsum(detrended))
    delta_s <- diff(s_tilde)

    # ΔS_t = phi S_(t-1) + augmented ΔS terms + ΔZ_t + error_t.
    rows <- seq.int(lags + 1L, length(delta_s))
    response <- delta_s[rows]
    regressors <- cbind(s_lag = s_tilde[rows])
    if (lags > 0L) {
      augmented <- sapply(seq_len(lags), function(j) {
        delta_s[rows - j]
      })
      regressors <- cbind(regressors, augmented)
    }
    regressors <- cbind(regressors, delta_z[rows, , drop = FALSE])
    fit <- lm.fit(x = regressors, y = response)
    degrees_freedom <- length(response) - fit$rank
    if (degrees_freedom <= 0L) return(NA_real_)
    variance <- sum(fit$residuals^2) / degrees_freedom
    standard_error <- sqrt(diag(variance * chol2inv(qr.R(fit$qr))))
    unname(fit$coefficients[1L] / standard_error[1L])
  }

  statistics <- vapply(candidates, lm_statistic, numeric(1))
  if (all(is.na(statistics))) stop("LM regressions could not be estimated.")
  minimum_index <- which.min(statistics)
  break_position <- candidates[minimum_index]
  break_fraction <- break_position / n

  # Lee and Strazicich (2004), Model C, Table 1; interpolate in lambda.
  critical_value_grid <- cbind(
    lambda = c(0.1, 0.2, 0.3, 0.4, 0.5),
    `1%` = c(-5.11, -5.07, -5.15, -5.05, -5.11),
    `5%` = c(-4.50, -4.47, -4.45, -4.50, -4.51),
    `10%` = c(-4.21, -4.20, -4.18, -4.18, -4.17)
  )
  lambda <- min(break_fraction, 1 - break_fraction)
  critical_values <- vapply(2:4, function(column) {
    approx(critical_value_grid[, 1], critical_value_grid[, column],
      xout = lambda, rule = 2)$y
  }, numeric(1))
  names(critical_values) <- colnames(critical_value_grid)[2:4]

  list(
    statistic = unname(statistics[minimum_index]),
    break_position = break_position,
    break_fraction = break_fraction,
    lags = lags,
    trim = trim,
    critical_values = critical_values,
    statistics_by_break = stats::setNames(statistics, candidates)
  )
}
