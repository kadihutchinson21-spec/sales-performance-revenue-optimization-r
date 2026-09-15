# ============================================================
# Sales Performance & Revenue Optimization
# 02 - Data Quality Assessment
# ============================================================

# Load required package
library(tidyverse)


# ------------------------------------------------------------
# 1. Load imported datasets
# ------------------------------------------------------------

source("R/01_data_import.R")


# ------------------------------------------------------------
# 2. Check missing values
# ------------------------------------------------------------

colSums(is.na(accounts))

colSums(is.na(products))

colSums(is.na(sales_pipeline))

colSums(is.na(sales_teams))


# ------------------------------------------------------------
# 3. Check duplicate records
# ------------------------------------------------------------

sum(duplicated(accounts))

sum(duplicated(products))

sum(duplicated(sales_pipeline))

sum(duplicated(sales_teams))


# ------------------------------------------------------------
# 4. Check data types
# ------------------------------------------------------------

str(accounts)

str(products)

str(sales_pipeline)

str(sales_teams)


# ------------------------------------------------------------
# 5. Investigate missing values by deal stage
# ------------------------------------------------------------

sales_pipeline %>%
  count(deal_stage)

sales_pipeline %>%
  group_by(deal_stage) %>%
  summarise(
    total_opportunities = n(),
    missing_account = sum(is.na(account)),
    missing_engage_date = sum(is.na(engage_date)),
    missing_close_date = sum(is.na(close_date)),
    missing_close_value = sum(is.na(close_value))
  )

# ------------------------------------------------------------
# 6. Check categorical values
# ------------------------------------------------------------

sort(unique(accounts$sector))

sort(unique(accounts$office_location))

sort(unique(sales_pipeline$product))

sort(unique(sales_pipeline$deal_stage))


# ------------------------------------------------------------
# 7. Check date consistency
# ------------------------------------------------------------

sales_pipeline %>%
  filter(
    !is.na(engage_date),
    !is.na(close_date),
    close_date < engage_date
  )


# ------------------------------------------------------------
# 8. Check sales value range
# ------------------------------------------------------------

summary(sales_pipeline$close_value)

sum(sales_pipeline$close_value < 0, na.rm = TRUE)


# ------------------------------------------------------------
# 9. Check opportunity ID uniqueness
# ------------------------------------------------------------

n_distinct(sales_pipeline$opportunity_id)

nrow(sales_pipeline)
