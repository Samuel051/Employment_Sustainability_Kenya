# Kenya Employment Sustainability Research

## Research Question

Is Kenya able to sustain its rising levels of unemployment, and is there a foreseeable solution?

## Project Overview

This research investigates the sustainability of employment in Kenya using annual macroeconomic and labour-market data.

## Data Sources

The primary quantitative data sources are:

- World Bank
- International Labour Organization (ILO/ILOSTAT)
- United Nations Development Programme (UNDP)

Kenya National Bureau of Statistics (KNBS) reports will be used primarily for contextual interpretation and validation of observed trends.

## Data Period

1991–2025

## Main Variables

- Unemployment
- GDP growth
- Inflation
- Gross Fixed Capital Formation
- Labour force participation

Additional indicators are retained in the master dataset for contextual analysis.

## Project Structure

- `Data/` — raw, processed and final datasets
- `R/` — statistical and econometric analysis
- `src/` — data extraction scripts and econometric implementations
- `outputs/` — research outputs and figures
- `docs/` — research documentation

## Methodology

The analysis will include descriptive statistics, time-series diagnostics, stationarity testing, model identification, forecasting and diagnostic evaluation.

## Status

Data extraction and initial descriptive analysis completed. Econometric analysis in progress.

## Structural-break unit-root test

`R/07_break_unit_root.R` runs a one-break Lee--Strazicich minimum LM test
(Model C: level and trend break) for the project's five 1991--2025 annual
series. The script asserts the intended 35-observation window, uses a
parsimonious fixed zero-lag augmentation, and writes a compact table to
`outputs/tables/lee_strazicich_one_break_results.csv`.

The focused implementation in `src/econometrics/` is adapted from Johannes
Lips' GPL-3.0 implementation. Its attribution notice and full GPL-3.0 license
are retained beside the source.

`R/08_bai_perron_breaks.R` provides the complementary Bai--Perron trend-regime
diagnostic. With this 35-observation annual sample it limits selection to zero,
one or two breaks and requires seven observations per regime. The selected
break dates are not unit-root conclusions; they are compared with the
historical candidate periods before ARDL modelling.
