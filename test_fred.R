# testing with FRED / fredr & BEA / bea.R

library(bea.R)
library(fredr)
library(readr)

fredr_get_key()

# THE fredr STEPS (1 & 2) MIGHT BE RED HERRINGS  :(
#
# # STEP 1 - get list of FRED / BEA releases
# #  Using this 'if' statement helps avoid making more API calls than needed:
if (file.exists("data/releaseList.csv")) {
  
  releaseList <- read_csv("data/releaseList.csv")
  
} else {
  
  releaseList <- fredr_releases()
  write_csv(releaseList,
            "data/releaseList.csv")
  
}

# # STEP 2 - retrieve series in 1 release
# #  We started with release_id 53 (GDP):
relSeriesList <- fredr_release_series(53)
relSeriesData <- fredr_series_observations("GDPC1")
gdpc1_cats <- fredr_series_categories("gdpc1")
gdpc1_cat_kids <- fredr_category_children(18)
gdpc1_cat_sibs <- fredr_category_series(106)

# #  Other release_id's of interest:
# #   50  (Employment Situation)
# #   82  (Economic Report of President)
# #   180 (Unemployment)

# STEP 3 - retrieve data in 1 series - SWITCH to bea.R functions
beaKey <- Sys.getenv("BEAKEY")

# #  Using this 'if' statement helps avoid making more API calls than needed:
if (file.exists("data/all_bea_series.csv")) {

  # should add "AND if file < 1month old" -- to refresh data if > 1 month old
  all_bea_series <- read_csv("data/all_bea_series.csv")
  
} else {
  
  all_bea_series <- beaSearch('', beaKey)
  write_csv(all_bea_series,
            "data/all_bea_series.csv")
  
}


# Get the table for GDP ("T10105")
# # Optional: setup "userSpecList" & pass it to beaGet():
# userSpecList <- list('UserID' = beaKey,
#                      'Method' = 'GetData',
#                      'DatasetName' = 'NIPA',
#                      'Frequency' = 'A',
#                      'TableName' = 'T10105',  # 68 # A191RO  
#                      'Year' = 'X') 

# ...or simply put list of user specs directly in beaGet():
GDP <- beaGet(list('UserID' = beaKey,
                   'Method' = 'GetData',
                   'DatasetName' = 'NIPA',
                   'Frequency' = 'A',
                   'TableName' = 'T10105',  # 68 # A191RO  
                   'Year' = 'X'))

gdp_series <- all_bea_series[all_bea_series$SeriesCode %in% GDP$SeriesCode
                             & all_bea_series$TableID == "T10105"
                             & all_bea_series$DatasetName == "NIPA",]


gdp_hier_1 <- gdp_series[,c("LineNumber",
                            "LineDescription",
                            "ParentLineNumber")]

gdp_hier_2 <- merge(gdp_hier_1, gdp_hier_1,
                    by.x = "ParentLineNumber",
                    by.y = "LineNumber",
                    all.x = T)


colnames(gdp_hier_2) <- c("Parent1LineNumber", "LineNumber",
                          "LineDescription", "Parent1LineDescription",
                          "Parent2LineNumber")


gdp_hier_3 <- merge(gdp_hier_2, gdp_hier_1,
                    by.x = "Parent2LineNumber",
                    by.y = "LineNumber",
                    all.x = T)

colnames(gdp_hier_3)[4:7] <- c("LineDescription", "Parent1LineDescription",
                               "Parent2LineDescription", "Parent3LineNumber")


gdp_hier_4 <- merge(gdp_hier_3, gdp_hier_1,
                    by.x = "Parent3LineNumber",
                    by.y = "LineNumber",
                    all.x = T)

colnames(gdp_hier_4)[5:9] <- c("LineDescription", "Parent1LineDescription",
                               "Parent2LineDescription", "Parent3LineDescription",
                               "Parent4LineNumber")


gdp_hier_5 <- merge(gdp_hier_4, gdp_hier_1,
                    by.x = "Parent4LineNumber",
                    by.y = "LineNumber",
                    all.x = T)

colnames(gdp_hier_5)[6:11] <- c("LineDescription", "Parent1LineDescription",
                               "Parent2LineDescription", "Parent3LineDescription",
                               "Parent4LineDescription", "Parent5LineNumber")

gdp_hier_all <- gdp_hier_5[,c("LineNumber", # "LineDescription",
                              "Parent4LineDescription",
                              "Parent3LineDescription", 
                              "Parent2LineDescription",
                              "Parent1LineDescription")]


# Add columnms to GDP for BEA's hierarchy (parents, grandparents, etc)

GDP_hier <- merge(gdp_hier_all, GDP,
                  by = "LineNumber",
                  all.y = T)

GDP_hier <- GDP_hier[order(as.numeric(GDP_hier$LineNumber)),]

# NEXT: put the parent/iteration in the right order...

# Further reading #### 
#     other things on 'converting a parent-child list to heirarchy' in R:
#       e.g.:
#        https://cran.r-project.org/web/packages/data.tree/vignettes/data.tree.html
#        https://stackoverflow.com/questions/36273730/turning-relationship-data-into-hierarchical-list-in-r
