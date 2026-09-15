# ============================================================
# Sales Performance & Revenue Optimization
# 03 - Data Cleaning
# ============================================================

# Load required package
library(tidyverse)


# ------------------------------------------------------------
# 1. Load imported datasets
# ------------------------------------------------------------

source("R/01_data_import.R")


# ------------------------------------------------------------
# 2. Standardize categorical values
# ------------------------------------------------------------

# Correct spelling inconsistencies in account data
accounts <- accounts %>%
  mutate(
    sector = recode(sector,
                    "technolgy" = "technology"),
    office_location = recode(office_location,
                             "Philipines" = "Philippines")
  )


# Correct product name inconsistency in sales pipeline
sales_pipeline <- sales_pipeline %>%
  mutate(
    product = recode(product,
                     "GTXPro" = "GTX Pro")
  )


# ------------------------------------------------------------
# 3. Handle missing account information
# ------------------------------------------------------------

sales_pipeline <- sales_pipeline %>%
  mutate(
    account_missing = is.na(account),
    account = replace_na(account, "Unknown Account")
  )

# ------------------------------------------------------------
# 4. Handle open opportunities
# ------------------------------------------------------------

sales_pipeline <- sales_pipeline %>%
  mutate(
    is_closed = deal_stage %in% c("Won", "Lost")
  )

# ------------------------------------------------------------
# 5. Validate product names
# ------------------------------------------------------------

setdiff(
  unique(sales_pipeline$product),
  unique(products$product)
)

setdiff(
  unique(products$product),
  unique(sales_pipeline$product)
)


# ------------------------------------------------------------
# 6. Validate account names
# ------------------------------------------------------------

setdiff(
  unique(
    sales_pipeline$account[sales_pipeline$account != "Unknown Account"]
  ),
  unique(accounts$account)
)

# ------------------------------------------------------------
# 7. Validate sales agents
# ------------------------------------------------------------

setdiff(
  unique(sales_pipeline$sales_agent),
  unique(sales_teams$sales_agent)
)


# ------------------------------------------------------------
# 8. Final cleaning checks
# ------------------------------------------------------------

# Confirm row count is unchanged
nrow(sales_pipeline)

# Confirm opportunity IDs are still unique
n_distinct(sales_pipeline$opportunity_id)

# Confirm no duplicate rows were introduced
sum(duplicated(sales_pipeline))

# Confirm product names are standardized
sort(unique(sales_pipeline$product))

# Confirm account missing flag
table(sales_pipeline$account_missing)

# Confirm closed opportunity flag
table(sales_pipeline$is_closed)

# ------------------------------------------------------------
# 9. Save cleaned datasets
# ------------------------------------------------------------

write_csv(accounts, "outputs/accounts_clean.csv")

write_csv(products, "outputs/products_clean.csv")

write_csv(sales_pipeline, "outputs/sales_pipeline_clean.csv")

write_csv(sales_teams, "outputs/sales_teams_clean.csv")



