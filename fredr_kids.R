# Make a tree of FRED categories

library(fredr)
library(readr)
library(collapsibleTree)

fredr_get_key()

level_0 <- fredr_category_children(0)
# first of 8 kids of "0" = 32991

level_1 <- fredr_category_children(32991)
level_1 <- level_1[1:3]

for (i in 2:NROW(level_0)) {
  
  level_1_temp <- fredr_category_children(level_0$id[i])
  level_1_temp <- level_1_temp[1:3]
  level_1 <- rbind(level_1, level_1_temp)
  
  print(paste(i,"-", Sys.time()))
  Sys.sleep(1)
  
}

level_2 <- fredr_category_children(level_1$id[1])
level_2 <- level_2[1:3]

for (i in 2:NROW(level_1)) {
  
  level_2_temp <- fredr_category_children(level_1$id[i])
  
  if (NROW(level_2_temp) > 0) {
    level_2_temp <- level_2_temp[1:3]
    level_2 <- rbind(level_2, level_2_temp)
  }
  
  print(paste(i,"-", Sys.time()))
  Sys.sleep(1)
  
}


level_3 <- fredr_category_children(level_2$id[1])

if (NROW(level_3) > 0) {
  
  level_3 <- level_3[1:3]
  
} else {
  
  level_3 <- data.frame("id" = integer(),
                        "name" = character(),
                        "parent_id" = integer(),
                        stringsAsFactors = FALSE)
  
}

for (i in 2:NROW(level_2)) {
  
  level_3_temp <- fredr_category_children(level_2$id[i])
  
  if (NROW(level_3_temp) > 0) {
    level_3_temp <- level_3_temp[1:3]
    level_3 <- rbind(level_3, level_3_temp)
  }
  
  print(paste(i,"-", Sys.time()))
  Sys.sleep(1.5)
  
}

# NEXT STEPS:
# - add [somehow] series within each category 
# -- use fredr_category_series(), e.g.:
gdp_series <- fredr_category_series(106)
# from here, then filter / split by currency, frequency, unit, etc
 
gdp_series_keep <- gdp_series[gdp_series$frequency=="Annual", c("id", "title")] 

gdp_series_keep$category_id <- 106

# Prep List for Series ####
# (fredr_category_series())
category_list <- rbind(level_0, level_1, level_2, level_3)

write_csv(category_list, "FREDcategories.csv")

# Prep Tree for Graph ####
# put lists together--rename cols then start with children (branch-tips)
colnames(level_0) <- c("Gen1_id", "Gen1", "id_0_parent")
colnames(level_1) <- c("Gen2_id", "Gen2", "Gen1_id")
colnames(level_2) <- c("Gen3_id", "Gen3", "Gen2_id") 
colnames(level_3) <- c("Gen4_id", "Gen4", "Gen3_id")

level_32 <- merge(level_3, level_2,
                  by = "Gen3_id",
                  all = T)

level_321 <- merge(level_32, level_1,
                  by = "Gen2_id",
                  all = T)

level_3210 <- merge(level_321, level_0,
                   by = "Gen1_id",
                   all = T)

write_csv(level_3210,
          "FredData_fromAPI_2.csv")

# make a new dataframe that only keeps the columns with category names
level_3210_names <- level_3210[,c("Gen1", "Gen2", "Gen3", "Gen4")]

# Make a tree of 4 levels
tree_fred <- collapsibleTree(level_3210_names,
                             c("Gen1", "Gen2", "Gen3", "Gen4"))  #,

tree_fred

# NEXT STEPS:
# Read in prepped tree data
fred_data <- read_csv("FredData_fromAPI_2.csv")

fred_data_2 <- fred_data[, c("Gen1", "Gen2", "Gen3", "Gen4")]

# Make a tree of those 3 levels for now...
p <- collapsibleTree(fred_data_2,
                     c("Gen1", "Gen2", "Gen3", "Gen4")  #,
                     # fillByLevel = FALSE,
                     # fill = c("red", "blue", "black")
                     )

# Display the plot
p
