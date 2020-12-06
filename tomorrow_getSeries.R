# Retrieve series data from a specific release
# 2020-Nov-21

# 0 Always load required libraries first
# 1 use fredr_release...() functions to get list of releases
# 2 - get list of series within release using fredr_release_series()

# 20201122
# 2.5 - Subset for Q, SAAR, Index year latest 2010?. Billions$,

# 3 - feed list of series to 'fredr()' function to retrieve actual series data


# STEP 0
library(fredr)

# STEP 1
ReleasesList <- fredr_releases()

# STEP 2
# After running fredr_release_series(), can do this for unique lists of values in a column
# unique(DataList53GDP$units) => (dataframe$column)
DataList53GDP <- fredr_release_series(53, 
                                      filter_variable = "units", 
                                      filter_value = "Billions of Chained 2012 Dollars",
                                      order_by = "realtime_end",
                                      sort_order = "desc"
                                      )

DataList53GDPQSAAR <- fredr_release_series(53, 
                                      filter_variable = "seasonal_adjustment", 
                                      filter_value = "Seasonally Adjusted Annual Rate",
                                      order_by = "observation_end",
                                      sort_order = "desc"
)

# Sample Table List IDs: GDP 53; Empl Situation 50; REP 82; Unemployment 180 

TableList53 <- fredr_release_tables(53)

# STEP 3
Data_GDP <- fredr("GDPC1")

