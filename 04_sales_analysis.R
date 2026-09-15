# ============================================================
# Sales Performance & Revenue Optimization
# 04 - Sales Analysis
# ============================================================

# Load required packages
library(tidyverse)
library(lubridate)


# ============================================================
# Portfolio Chart Theme
# ============================================================

portfolio_theme <- theme_minimal(base_size = 12) +
  theme(
    panel.background = element_rect(
      fill = "white",
      color = NA
    ),
    plot.background = element_rect(
      fill = "white",
      color = NA
    ),
    legend.background = element_rect(
      fill = "white",
      color = NA
    ),
    legend.key = element_rect(
      fill = "white",
      color = NA
    ),
    text = element_text(color = "black"),
    axis.text = element_text(color = "black"),
    axis.title = element_text(color = "black"),
    plot.title = element_text(color = "black"),
    plot.subtitle = element_text(color = "black"),
    panel.grid.major = element_line(color = "grey80"),
    panel.grid.minor = element_line(color = "grey90")
  )

# ------------------------------------------------------------
# 1. Load cleaned datasets
# ------------------------------------------------------------

sales_pipeline <- read_csv(
  "outputs/sales_pipeline_clean.csv"
)

accounts <- read_csv(
  "outputs/accounts_clean.csv"
)

products <- read_csv(
  "outputs/products_clean.csv"
)

sales_teams <- read_csv(
  "outputs/sales_teams_clean.csv"
)

# Make sure date fields are properly formatted
sales_pipeline <- sales_pipeline %>%
  mutate(
    engage_date = as.Date(engage_date),
    close_date = as.Date(close_date)
  )


# ------------------------------------------------------------
# 2. Opportunity count by deal stage
# ------------------------------------------------------------

opportunity_summary <- sales_pipeline %>%
  count(
    deal_stage,
    name = "opportunities"
  ) %>%
  arrange(
    desc(opportunities)
  )

opportunity_summary


# ------------------------------------------------------------
# 3. Calculate overall win rate
# ------------------------------------------------------------

closed_opportunities <- sales_pipeline %>%
  filter(is_closed)

win_rate <- closed_opportunities %>%
  summarise(
    closed_opportunities = n(),
    won_opportunities = sum(
      deal_stage == "Won"
    ),
    lost_opportunities = sum(
      deal_stage == "Lost"
    ),
    win_rate = won_opportunities /
      closed_opportunities * 100
  )

win_rate


# ------------------------------------------------------------
# 4. Revenue and average deal value
# ------------------------------------------------------------

revenue_summary <- sales_pipeline %>%
  filter(
    deal_stage == "Won"
  ) %>%
  summarise(
    won_opportunities = n(),
    total_revenue = sum(
      close_value,
      na.rm = TRUE
    ),
    average_deal_value = mean(
      close_value,
      na.rm = TRUE
    ),
    median_deal_value = median(
      close_value,
      na.rm = TRUE
    )
  )

revenue_summary


# ------------------------------------------------------------
# 5. Win rate by product
# ------------------------------------------------------------

product_win_rate <- sales_pipeline %>%
  filter(is_closed) %>%
  group_by(product) %>%
  summarise(
    closed_opportunities = n(),
    won_opportunities = sum(
      deal_stage == "Won"
    ),
    lost_opportunities = sum(
      deal_stage == "Lost"
    ),
    win_rate = won_opportunities /
      closed_opportunities * 100,
    .groups = "drop"
  ) %>%
  arrange(
    desc(win_rate)
  )

product_win_rate


# ------------------------------------------------------------
# 6. Sales performance by sales agent
# ------------------------------------------------------------

sales_agent_performance <- sales_pipeline %>%
  group_by(sales_agent) %>%
  summarise(
    total_opportunities = n(),
    closed_opportunities = sum(is_closed),
    won_opportunities = sum(
      deal_stage == "Won"
    ),
    lost_opportunities = sum(
      deal_stage == "Lost"
    ),
    total_revenue = sum(
      close_value[deal_stage == "Won"],
      na.rm = TRUE
    ),
    win_rate = ifelse(
      closed_opportunities > 0,
      won_opportunities /
        closed_opportunities * 100,
      NA_real_
    ),
    .groups = "drop"
  ) %>%
  arrange(
    desc(total_revenue)
  )

sales_agent_performance


# ------------------------------------------------------------
# 7. Visualize top sales agents by revenue
# ------------------------------------------------------------

top_agents <- sales_agent_performance %>%
  slice_max(
    total_revenue,
    n = 10
  )

agent_revenue_plot <- ggplot(
  top_agents,
  aes(
    x = reorder(
      sales_agent,
      total_revenue
    ),
    y = total_revenue
  )
) +
  geom_col(
    fill = "#2C7FB8"
  ) +
  coord_flip() +
  labs(
    title = "Top 10 Sales Agents by Revenue",
    x = "Sales Agent",
    y = "Total Revenue"
  ) +
  theme_minimal() +
  theme(
    panel.background = element_rect(
      fill = "white",
      color = NA
    ),
    plot.background = element_rect(
      fill = "white",
      color = NA
    ),
    text = element_text(
      color = "black"
    ),
    axis.text = element_text(
      color = "black"
    ),
    axis.title = element_text(
      color = "black"
    ),
    plot.title = element_text(
      color = "black"
    ),
    panel.grid.major = element_line(
      color = "grey80"
    ),
    panel.grid.minor = element_line(
      color = "grey90"
    )
  )

agent_revenue_plot

ggsave(
  "Figures/top_10_sales_agents_revenue.png",
  plot = agent_revenue_plot,
  width = 8,
  height = 5,
  dpi = 300,
  bg = "white"
)


# ------------------------------------------------------------
# 8. Regional sales performance
# ------------------------------------------------------------

regional_performance <- sales_pipeline %>%
  left_join(
    sales_teams,
    by = "sales_agent"
  ) %>%
  group_by(regional_office) %>%
  summarise(
    total_opportunities = n(),
    closed_opportunities = sum(is_closed),
    won_opportunities = sum(
      deal_stage == "Won"
    ),
    lost_opportunities = sum(
      deal_stage == "Lost"
    ),
    total_revenue = sum(
      close_value[deal_stage == "Won"],
      na.rm = TRUE
    ),
    win_rate = won_opportunities /
      closed_opportunities * 100,
    .groups = "drop"
  ) %>%
  arrange(
    desc(total_revenue)
  )

regional_performance


# ------------------------------------------------------------
# 9. Visualize regional revenue performance
# ------------------------------------------------------------

regional_revenue_plot <- ggplot(
  regional_performance,
  aes(
    x = reorder(
      regional_office,
      total_revenue
    ),
    y = total_revenue
  )
) +
  geom_col(
    fill = "#41AE76"
  ) +
  coord_flip() +
  labs(
    title = "Revenue by Regional Office",
    x = "Regional Office",
    y = "Total Revenue"
  ) +
  portfolio_theme

regional_revenue_plot

ggsave(
  "Figures/revenue_by_regional_office.png",
  plot = regional_revenue_plot,
  width = 8,
  height = 5,
  dpi = 300,
  bg = "white"
)


# ------------------------------------------------------------
# 10. Sales cycle analysis
# ------------------------------------------------------------

sales_cycle <- sales_pipeline %>%
  filter(
    deal_stage == "Won",
    !is.na(engage_date),
    !is.na(close_date)
  ) %>%
  mutate(
    sales_cycle_days = as.numeric(
      close_date - engage_date
    )
  )

sales_cycle_summary <- sales_cycle %>%
  summarise(
    won_opportunities = n(),
    average_sales_cycle_days = mean(
      sales_cycle_days,
      na.rm = TRUE
    ),
    median_sales_cycle_days = median(
      sales_cycle_days,
      na.rm = TRUE
    ),
    minimum_sales_cycle_days = min(
      sales_cycle_days,
      na.rm = TRUE
    ),
    maximum_sales_cycle_days = max(
      sales_cycle_days,
      na.rm = TRUE
    )
  )

sales_cycle_summary


# ------------------------------------------------------------
# 11. Visualize sales cycle distribution
# ------------------------------------------------------------

sales_cycle_plot <- ggplot(
  sales_cycle,
  aes(
    x = sales_cycle_days
  )
) +
  geom_histogram(
    bins = 30,
    fill = "#756BB1",
    color = "white"
  ) +
  labs(
    title = "Distribution of Sales Cycle Length",
    x = "Sales Cycle (Days)",
    y = "Number of Won Opportunities"
  ) +
  portfolio_theme

sales_cycle_plot

ggsave(
  "Figures/sales_cycle_distribution.png",
  plot = sales_cycle_plot,
  width = 8,
  height = 5,
  dpi = 300,
  bg = "white"
)


# ------------------------------------------------------------
# 12. Account size vs. revenue
# ------------------------------------------------------------

account_performance <- sales_pipeline %>%
  filter(
    deal_stage == "Won",
    account != "Unknown Account"
  ) %>%
  group_by(account) %>%
  summarise(
    total_revenue = sum(
      close_value,
      na.rm = TRUE
    ),
    won_opportunities = n(),
    .groups = "drop"
  ) %>%
  left_join(
    accounts %>%
      select(
        account,
        revenue,
        employees
      ),
    by = "account"
  )

account_performance


# ------------------------------------------------------------
# 13. Visualize account size vs. revenue
# ------------------------------------------------------------

account_size_revenue_plot <- ggplot(
  account_performance,
  aes(
    x = revenue,
    y = total_revenue
  )
) +
  geom_point(
    alpha = 0.7,
    size = 3,
    color = "#DE2D26"
  ) +
  labs(
    title = "Account Size vs. Sales Revenue",
    x = "Account Revenue (USD millions)",
    y = "Sales Revenue"
  ) +
  portfolio_theme

account_size_revenue_plot


# ------------------------------------------------------------
# 14. Win rate by sales agent
# ------------------------------------------------------------

agent_win_rate <- sales_pipeline %>%
  filter(is_closed) %>%
  group_by(sales_agent) %>%
  summarise(
    closed_opportunities = n(),
    won_opportunities = sum(
      deal_stage == "Won"
    ),
    lost_opportunities = sum(
      deal_stage == "Lost"
    ),
    win_rate = won_opportunities /
      closed_opportunities * 100,
    .groups = "drop"
  ) %>%
  arrange(
    desc(win_rate)
  )

agent_win_rate


# ------------------------------------------------------------
# 15. Visualize win rate by sales agent
# ------------------------------------------------------------

top_win_rate_agents <- agent_win_rate %>%
  filter(
    closed_opportunities >= 50
  ) %>%
  slice_max(
    win_rate,
    n = 10
  )

agent_win_rate_plot <- ggplot(
  top_win_rate_agents,
  aes(
    x = reorder(
      sales_agent,
      win_rate
    ),
    y = win_rate
  )
) +
  geom_col(
    fill = "#3182BD"
  ) +
  coord_flip() +
  labs(
    title = "Top 10 Sales Agents by Win Rate",
    subtitle = "Agents with at least 50 closed opportunities",
    x = "Sales Agent",
    y = "Win Rate (%)"
  ) +
  portfolio_theme

agent_win_rate_plot


# ------------------------------------------------------------
# 16. Quarterly sales performance
# ------------------------------------------------------------

quarterly_performance <- sales_pipeline %>%
  filter(
    deal_stage == "Won"
  ) %>%
  mutate(
    quarter = floor_date(
      close_date,
      unit = "quarter"
    )
  ) %>%
  group_by(quarter) %>%
  summarise(
    won_opportunities = n(),
    total_revenue = sum(
      close_value,
      na.rm = TRUE
    ),
    average_deal_value = mean(
      close_value,
      na.rm = TRUE
    ),
    .groups = "drop"
  )

quarterly_performance


# ------------------------------------------------------------
# 17. Visualize quarterly revenue trend
# ------------------------------------------------------------

quarterly_revenue_plot <- ggplot(
  quarterly_performance,
  aes(
    x = quarter,
    y = total_revenue
  )
) +
  geom_line(
    color = "#2C7FB8",
    linewidth = 1.2
  ) +
  geom_point(
    color = "#2C7FB8",
    size = 3
  ) +
  scale_x_date(
    date_breaks = "3 months",
    date_labels = "Q%q"
  ) +
  labs(
    title = "Quarterly Revenue Trend",
    x = "Quarter",
    y = "Total Revenue"
  ) +
  portfolio_theme

quarterly_revenue_plot

ggsave(
  "Figures/quarterly_revenue_trend.png",
  plot = quarterly_revenue_plot,
  width = 8,
  height = 5,
  dpi = 300,
  bg = "white"
)


# ------------------------------------------------------------
# 18. Quarterly win rate
# ------------------------------------------------------------

quarterly_win_rate <- sales_pipeline %>%
  filter(
    is_closed
  ) %>%
  mutate(
    quarter = floor_date(
      close_date,
      unit = "quarter"
    )
  ) %>%
  group_by(quarter) %>%
  summarise(
    closed_opportunities = n(),
    won_opportunities = sum(
      deal_stage == "Won"
    ),
    lost_opportunities = sum(
      deal_stage == "Lost"
    ),
    win_rate = won_opportunities /
      closed_opportunities * 100,
    .groups = "drop"
  )

quarterly_win_rate


# ------------------------------------------------------------
# 19. Visualize quarterly win rate
# ------------------------------------------------------------

quarterly_win_rate_plot <- ggplot(
  quarterly_win_rate,
  aes(
    x = quarter,
    y = win_rate
  )
) +
  geom_line(
    color = "#31A354",
    linewidth = 1.2
  ) +
  geom_point(
    color = "#31A354",
    size = 3
  ) +
  scale_x_date(
    date_breaks = "3 months",
    date_labels = "Q%q"
  ) +
  labs(
    title = "Quarterly Win Rate Trend",
    x = "Quarter",
    y = "Win Rate (%)"
  ) +
  portfolio_theme

quarterly_win_rate_plot

ggsave(
  "Figures/quarterly_win_rate_trend.png",
  plot = quarterly_win_rate_plot,
  width = 8,
  height = 5,
  dpi = 300,
  bg = "white"
)


# ------------------------------------------------------------
# 20. Product revenue by quarter
# ------------------------------------------------------------

product_quarterly_revenue <- sales_pipeline %>%
  filter(
    deal_stage == "Won"
  ) %>%
  mutate(
    quarter = floor_date(
      close_date,
      unit = "quarter"
    )
  ) %>%
  group_by(
    quarter,
    product
  ) %>%
  summarise(
    total_revenue = sum(
      close_value,
      na.rm = TRUE
    ),
    won_opportunities = n(),
    .groups = "drop"
  )

product_quarterly_revenue


# ------------------------------------------------------------
# 21. Sales pipeline by deal stage
# ------------------------------------------------------------

pipeline_funnel <- sales_pipeline %>%
  count(
    deal_stage,
    name = "opportunities"
  ) %>%
  mutate(
    percentage = opportunities /
      sum(opportunities) * 100
  ) %>%
  arrange(
    desc(opportunities)
  )

pipeline_funnel


# ------------------------------------------------------------
# 22. Visualize sales pipeline
# ------------------------------------------------------------

pipeline_colors <- c(
  "Prospecting" = "#3182BD",
  "Engaging" = "#FD8D3C",
  "Won" = "#31A354",
  "Lost" = "#DE2D26"
)

pipeline_plot <- ggplot(
  pipeline_funnel,
  aes(
    x = reorder(
      deal_stage,
      -opportunities
    ),
    y = opportunities,
    fill = deal_stage
  )
) +
  geom_col() +
  scale_fill_manual(
    values = pipeline_colors
  ) +
  labs(
    title = "Sales Pipeline by Deal Stage",
    x = "Deal Stage",
    y = "Number of Opportunities",
    fill = "Deal Stage"
  ) +
  portfolio_theme

pipeline_plot

ggsave(
  "Figures/sales_pipeline_by_stage.png",
  plot = pipeline_plot,
  width = 8,
  height = 5,
  dpi = 300,
  bg = "white"
)


# ------------------------------------------------------------
# 23. Sales cycle vs. deal value
# ------------------------------------------------------------

sales_cycle_value <- sales_pipeline %>%
  filter(
    deal_stage == "Won",
    !is.na(engage_date),
    !is.na(close_date),
    !is.na(close_value)
  ) %>%
  mutate(
    sales_cycle_days = as.numeric(
      close_date - engage_date
    )
  )

sales_cycle_value


# ------------------------------------------------------------
# 24. Visualize sales cycle vs. deal value
# ------------------------------------------------------------

sales_cycle_value_plot <- ggplot(
  sales_cycle_value,
  aes(
    x = sales_cycle_days,
    y = close_value
  )
) +
  geom_point(
    alpha = 0.6,
    color = "#2C7FB8"
  ) +
  geom_smooth(
    method = "lm",
    se = FALSE,
    color = "#E6550D"
  ) +
  labs(
    title = "Sales Cycle Length vs. Deal Value",
    x = "Sales Cycle (Days)",
    y = "Deal Value"
  ) +
  portfolio_theme

sales_cycle_value_plot

ggsave(
  "Figures/sales_cycle_vs_deal_value.png",
  plot = sales_cycle_value_plot,
  width = 8,
  height = 5,
  dpi = 300,
  bg = "white"
)


# ------------------------------------------------------------
# 25. Product performance summary
# ------------------------------------------------------------

product_performance <- sales_pipeline %>%
  filter(
    deal_stage == "Won"
  ) %>%
  group_by(product) %>%
  summarise(
    won_opportunities = n(),
    total_revenue = sum(
      close_value,
      na.rm = TRUE
    ),
    average_deal_value = mean(
      close_value,
      na.rm = TRUE
    ),
    median_deal_value = median(
      close_value,
      na.rm = TRUE
    ),
    .groups = "drop"
  ) %>%
  arrange(
    desc(total_revenue)
  )

product_performance


# ------------------------------------------------------------
# 26. Visualize product revenue
# ------------------------------------------------------------

product_revenue_plot <- ggplot(
  product_performance,
  aes(
    x = reorder(
      product,
      total_revenue
    ),
    y = total_revenue,
    fill = product
  )
) +
  geom_col() +
  coord_flip() +
  labs(
    title = "Revenue Performance by Product",
    x = "Product",
    y = "Total Revenue",
    fill = "Product"
  ) +
  portfolio_theme

product_revenue_plot


# ------------------------------------------------------------
# 27. Top accounts by revenue
# ------------------------------------------------------------

top_account_performance <- sales_pipeline %>%
  filter(
    deal_stage == "Won",
    account != "Unknown Account"
  ) %>%
  group_by(account) %>%
  summarise(
    won_opportunities = n(),
    total_revenue = sum(
      close_value,
      na.rm = TRUE
    ),
    average_deal_value = mean(
      close_value,
      na.rm = TRUE
    ),
    .groups = "drop"
  ) %>%
  arrange(
    desc(total_revenue)
  ) %>%
  slice_head(
    n = 10
  )

top_account_performance


# ------------------------------------------------------------
# 28. Visualize top accounts by revenue
# ------------------------------------------------------------

top_accounts_plot <- ggplot(
  top_account_performance,
  aes(
    x = reorder(
      account,
      total_revenue
    ),
    y = total_revenue,
    fill = total_revenue
  )
) +
  geom_col() +
  coord_flip() +
  scale_fill_gradient(
    low = "#9ECAE1",
    high = "#08519C"
  ) +
  labs(
    title = "Top 10 Accounts by Revenue",
    x = "Account",
    y = "Total Revenue",
    fill = "Revenue"
  ) +
  portfolio_theme

top_accounts_plot


# ------------------------------------------------------------
# 29. Save key analysis outputs
# ------------------------------------------------------------

write_csv(
  opportunity_summary,
  "outputs/opportunity_summary.csv"
)

write_csv(
  win_rate,
  "outputs/win_rate.csv"
)

write_csv(
  revenue_summary,
  "outputs/revenue_summary.csv"
)

write_csv(
  product_win_rate,
  "outputs/product_win_rate.csv"
)

write_csv(
  sales_agent_performance,
  "outputs/sales_agent_performance.csv"
)

write_csv(
  regional_performance,
  "outputs/regional_performance.csv"
)

write_csv(
  sales_cycle_summary,
  "outputs/sales_cycle_summary.csv"
)

write_csv(
  account_performance,
  "outputs/account_performance.csv"
)

write_csv(
  agent_win_rate,
  "outputs/agent_win_rate.csv"
)

write_csv(
  quarterly_performance,
  "outputs/quarterly_performance.csv"
)

write_csv(
  quarterly_win_rate,
  "outputs/quarterly_win_rate.csv"
)

write_csv(
  product_quarterly_revenue,
  "outputs/product_quarterly_revenue.csv"
)

write_csv(
  pipeline_funnel,
  "outputs/pipeline_funnel.csv"
)

write_csv(
  sales_cycle_value,
  "outputs/sales_cycle_value.csv"
)

write_csv(
  product_performance,
  "outputs/product_performance.csv"
)

write_csv(
  top_account_performance,
  "outputs/top_account_performance.csv"
)


# ------------------------------------------------------------
# 30. Visualize product revenue over time
# ------------------------------------------------------------

product_revenue_time_plot <- ggplot(
  product_quarterly_revenue,
  aes(
    x = quarter,
    y = total_revenue,
    color = product,
    group = product
  )
) +
  geom_line(
    linewidth = 1
  ) +
  geom_point(
    size = 2
  ) +
  scale_x_date(
    date_breaks = "3 months",
    date_labels = "Q%q"
  ) +
  labs(
    title = "Quarterly Revenue by Product",
    x = "Quarter",
    y = "Total Revenue",
    color = "Product"
  ) +
  portfolio_theme

product_revenue_time_plot

ggsave(
  "Figures/quarterly_revenue_by_product.png",
  plot = product_revenue_time_plot,
  width = 9,
  height = 6,
  dpi = 300,
  bg = "white"
)

