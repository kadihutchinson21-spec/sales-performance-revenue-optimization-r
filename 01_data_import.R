# ============================================================
# Sales Performance & Revenue Optimization
# 01 - Data Import
# ============================================================

# Load required package
library(tidyverse)


# ------------------------------------------------------------
# 1. Import datasets
# ------------------------------------------------------------

accounts <- read_csv("Data/accounts.csv")

products <- read_csv("Data/products.csv")

sales_pipeline <- read_csv("Data/sales_pipeline.csv")

sales_teams <- read_csv("Data/sales_teams.csv")

data_dictionary <- read_csv("Data/data_dictionary.csv")


# ------------------------------------------------------------
# 2. Check dataset dimensions
# ------------------------------------------------------------

dim(accounts)
dim(products)
dim(sales_pipeline)
dim(sales_teams)
dim(data_dictionary)

# ------------------------------------------------------------
# 3. Inspect dataset structure
# ------------------------------------------------------------

glimpse(accounts)

glimpse(products)

glimpse(sales_pipeline)

glimpse(sales_teams)

glimpse(data_dictionary)
