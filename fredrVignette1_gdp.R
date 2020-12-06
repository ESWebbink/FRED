# trying part of the fredr "Getting Started" Vignette 
library(fredr)
library(dplyr)
library(ggplot2)

federal_gdp_series <- fredr_series_search_text(
  search_text = "gross domestic product",
  order_by = "search_rank",
  sort_order = "desc"
)

popular_gdp_series <- federal_gdp_series$id[1]

# One way to retrieve fredr data & make a graph
actualData1 <- fredr(popular_gdp_series,
                     observation_start = as.Date("2000-01-01"),
                     observation_end = as.Date("2020-01-01"))

ggplot(data = actualData1, mapping = aes(x = date, y = value, color = series_id)) +
  geom_line() +
  labs(x = "Observation Date", y = "Rate", color = "Series")


# Another way to retrieve fredr data & make a graph
# This way uses pipes to reduce clutter in the environment
popular_gdp_series %>%
  fredr(
    observation_start = as.Date("2000-01-01"),
    observation_end = as.Date("2020-01-01")
  ) %>%
  ggplot(data = ., mapping = aes(x = date, y = value, color = series_id)) +
  geom_line() +
  labs(x = "Observation Date", y = "Rate", color = "Series")