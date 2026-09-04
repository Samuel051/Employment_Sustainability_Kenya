# Employment Sustainability in Kenya

## An Empirical Assessment of Unemployment, Economic Growth, Investment and Labour Force Participation

**Study period:** 1991–2025  
**Forecast horizon:** 2026–2030  
**Methodology:** ARDL, bounds testing, diagnostic testing, robustness analysis and forecasting  
**Tools:** Python, R, Excel

---

## 1. Overview

Kenya has experienced periods of economic growth while continuing to face persistent challenges in generating sufficient productive and sustainable employment.

This project investigates whether Kenya's employment trajectory can be considered sustainable and whether the historical relationship between unemployment and selected macroeconomic variables provides evidence of a foreseeable improvement in unemployment.

The analysis focuses on four key explanatory variables:

- Economic growth
- Inflation
- Gross fixed capital formation (investment)
- Labour force participation

The study uses annual data covering **1991–2025** and combines data engineering, econometric analysis and forecasting into an end-to-end research workflow.

---

## 2. The Central Research Question

> **Has Kenya's economic growth and investment trajectory been sufficient to generate sustainable improvements in employment, and what does the historical evidence imply for unemployment over the coming years?**

The project is particularly interested in the distinction between **economic growth** and **employment-generating growth**.

---

## 3. Key Finding

The most important result from the forecasting exercise was a potential **employment stagnation scenario**.

The preferred BIC-selected ARDL model projected unemployment to remain broadly around:

> **5.47%**

through **2026–2030**, conditional on the continuation of the historical relationships observed in the data and the projected paths of the explanatory variables.

This should **not** be interpreted as an official forecast or as evidence that unemployment will inevitably remain at 5.47%.

Rather, the result suggests that:

> **If the underlying economic relationships remain broadly unchanged, substantial improvement in unemployment cannot be assumed.**

This raises an important policy question: **Is Kenya generating enough employment from the growth and investment it is already achieving?**

---

## 4. Main Findings

### Economic Growth

Economic growth had a **negative and statistically significant short-run association with unemployment**.

This indicates that periods of stronger economic growth were associated with lower unemployment in the short run.

The result was broadly consistent with the expected direction of Okun's Law, although the magnitude and strength of the relationship differed from some previous Kenyan studies.

---

### Investment

Gross fixed capital formation had a **positive and statistically significant short-run association with unemployment**.

This does not mean that investment inherently creates unemployment.

Instead, the finding raises questions about:

- The sectoral composition of investment
- Capital intensity
- Employment absorption
- Implementation lags
- The distinction between public and private investment
- Whether investment generates direct or indirect employment

Aggregate investment therefore cannot automatically be treated as equivalent to employment creation.

---

### Inflation

Inflation was **statistically insignificant** in the short-run model.

This provided limited evidence for a stable inflation-unemployment trade-off over the study period.

---

### Labour Force Participation

Labour force participation exhibited a strong **negative association with unemployment**.

This relationship was interpreted cautiously because unemployment and labour-force participation are closely connected through labour-market measurement and because participation can reflect broader employment and labour-market dynamics.

---

## 5. Long-Run Relationship

The ARDL bounds test did **not establish a robust long-run cointegrating relationship at the conventional 5% significance level**.

### Baseline model

**ARDL(1,1,1,1,1)**

- F-statistic: **3.8799**
- Exact p-value: **0.1085**

### BIC robustness model

**ARDL(1,1,2,0,1)**

- F-statistic: **4.6156**
- Exact p-value: **0.0538**

The BIC specification therefore provided **borderline evidence** of a possible long-run relationship, but the result remained above the conventional 5% threshold.

Consequently, the study did not claim a confirmed long-run equilibrium relationship.

---

## 6. Model Diagnostics

The model was subjected to several diagnostic tests.

| Diagnostic | Result | Interpretation |
|---|---:|---|
| VIF | Maximum ≈ 1.56 | No serious multicollinearity |
| Breusch-Godfrey | p = 0.5101 | No evidence of serial correlation |
| Breusch-Pagan | p = 0.0973 | No rejection at 5%; marginal at 10% |
| Jarque-Bera | p = 0.7140 | Residual normality not rejected |
| Ramsey RESET | p = 0.0079 | Possible functional-form/specification issue |
| Recursive CUSUM | p = 0.8444 | No evidence of parameter instability |
| OLS-CUSUM | p = 0.3221 | No evidence of parameter instability |

The significant RESET result was retained as an important limitation rather than being ignored.

---

## 7. Forecast Validation

Two ARDL specifications were compared using out-of-sample observations from **2021–2025**.

| Model | RMSE | MAE |
|---|---:|---:|
| Baseline ARDL | 0.280 | 0.241 |
| BIC ARDL | **0.248** | **0.211** |

The BIC-selected specification produced lower forecast errors and was therefore used for the final unemployment forecasting exercise.

---

## 8. Forecast: 2026–2030

The preferred model produced unemployment forecasts of approximately:

| Year | Forecast unemployment |
|---|---:|
| 2026 | 5.47% |
| 2027 | 5.47% |
| 2028 | 5.47% |
| 2029 | 5.47% |
| 2030 | 5.47% |

The forecasts should be interpreted as **conditional model-based projections**, not official forecasts.

The persistence of the forecast is the main finding rather than the precise value of 5.47%.

---

## 9. Why the Findings Matter

The results suggest that Kenya's employment challenge may not be solved through aggregate economic growth alone.

The key issue may be the **employment intensity of growth and investment**.

An economy can grow while unemployment remains persistent when:

- Growth is concentrated in capital-intensive sectors
- Investment has weak labour absorption
- Skills do not match employer requirements
- Workers transition into informal or low-productivity employment
- Investment takes time to translate into jobs
- Productivity increases faster than labour demand
- Economic activity expands without sufficient structural transformation

The forecasting results therefore point toward a potential **employment sustainability problem rather than simply a growth problem**.

---

## 10. Policy Implications

The study suggests several areas for policy attention:

### 1. Promote employment-intensive investment

Investment policy should consider not only the amount of investment but also its capacity to generate productive employment.

### 2. Strengthen the growth-employment transmission mechanism

Policies should encourage sectors and value chains capable of translating economic expansion into broad-based employment.

### 3. Improve private-sector access to finance

Predictable and affordable long-term financing can support businesses capable of expanding productive employment.

### 4. Align skills with labour-market demand

TVET, apprenticeships, employer partnerships and practical training should be more closely connected to actual labour-market requirements.

### 5. Measure employment quality

Unemployment alone does not fully describe Kenya's labour-market challenge.

Future analysis should increasingly consider:

- Underemployment
- Informal employment
- Earnings
- Hours worked
- Productivity
- Job stability
- Working conditions

### 6. Evaluate the employment impact of major investments

Major public and private investment programmes should incorporate employment-impact indicators alongside financial and physical project outputs.

---

## 11. Data

The final empirical dataset contains **35 annual observations covering 1991–2025**.

### Variables

| Variable | Role |
|---|---|
| Unemployment | Dependent variable |
| GDP growth | Economic growth |
| Inflation | Macroeconomic stability |
| GFCF | Investment |
| Labour force participation | Labour-market participation |

### Main data sources

- World Bank
- International Labour Organization / ILOSTAT
- United Nations Development Programme
- Kenya National Bureau of Statistics
- Central Bank of Kenya

The international databases provided the primary quantitative series, while Kenyan institutional publications were used primarily for contextual interpretation and validation.

---

## 12. Analytical Workflow

The project follows an end-to-end research workflow.

```text
Data Sources
     │
     ▼
Python
Data extraction
     │
     ▼
Data cleaning & validation
     │
     ▼
Final analytical dataset
     │
     ├──────────────► Excel
     │                Descriptive statistics
     │                Trend analysis
     │                Publication graphs
     │
     ▼
R
Econometric analysis
     │
     ├── Stationarity analysis
     ├── ARDL estimation
     ├── Bounds testing
     ├── Diagnostic testing
     ├── Robustness analysis
     └── Forecasting
     │
     ▼
Results & Interpretation
     │
     ▼
Policy implications