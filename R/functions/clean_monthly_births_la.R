library(readxl)
library(tidyr)
library(dplyr)

clean_monthly_births_la <- function(fp_raw = "data/raw/monthly_births/", fp_save,
                                    src_name = "ONS ad hoc") {


  sheet_names <- c("Table 1", "Data")
  raw_data <-  read_xlsx("data/raw/monthly_births/copyoflivebirthsbymonthsexandladsept2019toaug2020.xlsx", sheet = "Table 1", col_names = FALSE)
  rm(sheet_names)
  # data comes with the month labels in merged header cells covering columns for totals, female, and male births. Rows are for each LA.

  # create column headers that contain both the month and the sex.

  births_cols <- raw_data[7:nrow(raw_data),4:ncol(raw_data)] %>%
    as.data.frame()

  month_headers <- births_cols[1,]
  long_month_headers = data.frame(t(month_headers))
  long_month_headers <- fill(long_month_headers, X1)
  month_headers <- data.frame(t(long_month_headers)) # back to vertical.
  rm(long_month_headers)

  sex_headers <- births_cols[2,]

  headers <- paste(month_headers, sex_headers, sep = "_")
  rm(month_headers, sex_headers)

  births_cols <- births_cols[3:nrow(births_cols),]
  names(births_cols) <- headers
  rm(headers)

  geog_cols <- raw_data[8:nrow(raw_data), 1:3]
  names(geog_cols) <- as.character(geog_cols[1,])
  geog_cols <- geog_cols[-1,]

  data <- bind_cols(geog_cols, births_cols) %>%
    pivot_longer(September_Total:August_Female, names_to = "month_sex", values_to = "births") %>%
    mutate(month = tolower(gsub("_.*", "", month_sex)),
           sex = tolower(gsub(".*_", "", month_sex)),
           sex = ifelse(sex == "total", "persons", sex),
           births = as.numeric(births),
           source = src_name,
           #source_url = src_url) %>%
    ) %>%
    select(code = Code, name = Name, geography = Geography, month, sex, births)

  #TODO add QA for the data?

}
