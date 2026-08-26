# ============================================================
# Kenya Employment Sustainability Research
# 01 - Data Import and Validation
# ============================================================

# Load packages
library(tidyverse)

# ------------------------------------------------------------
# Import primary model dataset
# ------------------------------------------------------------

df <- read_csv(
  "data/final/kenya_employment_model.csv"
)

# ------------------------------------------------------------
# Inspect dataset
# ------------------------------------------------------------

df
dim(df)
names(df)
str(df)

# ------------------------------------------------------------
# Data quality checks
# ------------------------------------------------------------

# Missing values
colSums(is.na(df))

# Duplicate years
sum(duplicated(df$year))

# Year range
range(df$year)

# Check for gaps in annual sequence
diff(df$year)

# Open data viewer
View(df)
