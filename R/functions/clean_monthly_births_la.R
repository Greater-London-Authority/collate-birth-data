library(readxl)
library(tidyr)
library(dplyr)

clean_monthly_births_la <- function(fp_raw = "data/raw/monthly_births/", fp_save,
                                                 src_name = "ONS ad hoc",
                                                 src_url = "https://www.ons.gov.uk/peoplepopulationandcommunity/birthsdeathsandmarriages/deaths/adhocs/009628birthsanddeathsbylowersuperoutputarealsoaenglandandwales1991to1992to2016to2017") {


sheet_names <- c("Table 1", "Data")

raw_data <-  read_xlsx("data/raw/monthly_births/copyoflivebirthsbymonthsexandladsept2019toaug2020.xlsx", sheet = "Table 1", fillMergedCells = TRUE)

trial_table <- raw_data[6:nrow(raw_data),4:ncol(raw_data)] %>%
  as.data.frame()
headers <- trial_table[1,]
long_headers = data.frame(t(headers))
long_headers <- fill(long_headers, X1)
headers <- data.frame(t(long_headers)) # back to vertical.

