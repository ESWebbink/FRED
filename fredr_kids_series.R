# Try to get FRED DATA not just series names

library(fredr)
library(readr)
library(collapsibleTree)

# 1 - bring in the hierarchy of categories
fred_category_list <- read_csv("FREDcategories.csv")


fredr_get_key()

series_level_1 <- fredr_category_series(fred_category_list$id[2])
series_level_1$cat_id <- paste0(fred_category_list$id[2],
                                "-", fred_category_list$name[2])

for (i in 3:10) {  # NROW(level_0)) {
  
  series_level_1_temp <- fredr_category_series(fred_category_list$id[i])
  series_level_1_temp$cat_id <-  paste0(fred_category_list$id[i],
                                        "-", fred_category_list$name[i])
  # level_1_temp <- level_1_temp[1:3]
  series_level_1 <- rbind(series_level_1, series_level_1_temp)
  
  print(paste(i,"-", Sys.time()))
  Sys.sleep(2)
  
}

# EXAMPLE OUTPUT:
write_csv(series_level_1, "FredCatSeries.csv")

# Retrieve Series for 'National Accounts' Category (id 32992)
cat_series_32992 <- fredr_category_series(32992) # fred_category_list$id[2])
cat_series_32992$cat_id <- 32992

# Retrieve series for child-cats of Cat_id 32992
cat_series_18 <- fredr_category_series(18)
cat_series_5 <- fredr_category_series(5)
cat_series_32251 <- fredr_category_series(32251)
cat_series_13 <- fredr_category_series(13)

# Add cat_id column to allow us to merge series into cat_tree later
cat_series_5$cat_id <- 5
cat_series_32251$cat_id <- 32251

# put the mess into 1 bucket to simplify merging series into cat_tree:
cat_series_32992_kids <- rbind(cat_series_32251,
                               cat_series_5)

# Add series into category hierarchy/tree
# 1 - read in category-tree
cat_tree <- read_csv("FredData_fromAPI_2.csv")

cat_tree_series <- merge(cat_tree, 
                         cat_series_32992[,c("cat_id", "title")],
                         by.x = "Gen1_id",
                         by.y = "cat_id",
                         all = TRUE)

# Rename column for series title --> Gen1_series
colnames(cat_tree_series)[10] <- "Gen1_series"

# Plot the new categories + series tree

cat_tree_series_2 <- cat_tree_series[, c("Gen1", "Gen1_series", "Gen2", "Gen3", "Gen4")]

# Make a tree of those 3 levels for now...
p <- collapsibleTree(cat_tree_series_2,
                     c("Gen1", "Gen1_series", "Gen2", "Gen3", "Gen4")  #,
                     # fillByLevel = FALSE,
                     # fill = c("red", "blue", "black")
)

# Display the plot
p

# FIX the look above so it gets series for the categories that you want series for.

# PUT the series in the tree

# CLIMB the tree. Save the cat. Stomp the grapes.

# # THIS IS HOW TO GET ACTUAL !#$(%*#) DATA:
# data <- fredr_series_observations("NROU")

