library(readxl)
library(tidyr)
library(dplyr)

#clean_monthly_births_la <- function(dir_raw, dir_save,
#                                    src_name = "ONS ad hoc",
#                                    url_lookup) {

for(sheet_ind in 4:7) {

  print(sheet_ind)

  dir_raw <- "data/raw/monthly_births/"
  dir_save <- "data/intermediate/monthly_births/"
  src_name <- "ONS ad hoc"
  url_lookup <- "lookups/monthly_births_data_urls.csv"

  monthly_births_urls <- read.csv(url_lookup, stringsAsFactors = FALSE) %>%
    mutate(ext = gsub(".*\\.", "\\.", basename(url)),
           fp_raw = paste0(dir_raw,"/",gla_filename, ext),
           fp_save = paste0(dir_save,"/",gla_filename, ".rds"))

  fp_raw <- monthly_births_urls[sheet_ind,]$fp_raw
  sheet_name <- monthly_births_urls[sheet_ind,]$data_sheet_name
  start_cell <- monthly_births_urls[sheet_ind,]$births_values_start_cell
  gla_name <- monthly_births_urls[sheet_ind,]$gla_filename
  #fp_save <- monthly_births_urls[7,]$fp_save
  #src_url <- monthly_births_urls[7,]$url

  raw_data <-  suppressMessages(read_excel(fp_raw, sheet = sheet_name, col_names = FALSE))
  rm(fp_raw, dir_raw, dir_save, src_name, url_lookup, monthly_births_urls)


  #clean_monthly_births_la_sept17_onwards <- function(raw_data, sheet_name, start_cell) {

    # start_cell is given as an excel cell reference e.g. D6. Convert to numeric row and col indicies.
    start_col_letter <- gsub("\\d*","",start_cell)
    start_col <- which(letters == tolower(start_col_letter))
    start_row <- as.numeric(gsub("\\D*","",start_cell))



    # data comes with the month labels in merged header cells covering columns for totals, female, and male births. Rows are for each LA.
    # headers start 2 rows above the data values

    # create column headers that contain both the month and the sex.

    births_cols <- raw_data[(start_row - 2):nrow(raw_data),start_col:ncol(raw_data)] %>%
      as.data.frame()

    month_headers <- births_cols[1,]
    long_month_headers = data.frame(t(month_headers))
    long_month_headers <- fill(long_month_headers, X1)
    month_headers <- data.frame(t(long_month_headers)) # back to vertical.
    rm(long_month_headers)

    sex_headers <- births_cols[2,]

    headers <- tolower(paste(month_headers, sex_headers, sep = "_"))
    rm(month_headers, sex_headers)

    births_cols <- births_cols[3:nrow(births_cols),]
    names(births_cols) <- headers
    rm(headers)

    geog_cols <- raw_data[(start_row-1):nrow(raw_data), 1:(start_col-1)]
    names(geog_cols) <- as.character(geog_cols[1,])
    geog_cols <- geog_cols[-1,]

    data <- bind_cols(geog_cols, births_cols) %>%
      filter(!is.na(august_total)) %>% # ugly hack to get rid of any notes ONS might have written below data
      pivot_longer(september_total:august_female, names_to = "month_sex", values_to = "value") %>%
      mutate(month = gsub("_.*", "", month_sex),
             sex = gsub(".*_", "", month_sex),
             sex = ifelse(sex == "total", "persons", sex),
             value = as.numeric(value)) %>%
      select(-month_sex)
    names(data) <- tolower(names(data))

    rename_cols <- c(code = "gss_code",
                     `area codes` = "gss_code",
                     name = "gss_name",
                     `area of usual residence` = "gss_name",
                     geography = "geography")

    rename_list <- rename_cols[names(rename_cols) %in% names(data)]
    rename_list2 <- names(rename_list)
    names(rename_list2) <- rename_list
    data <- rename(data, all_of(rename_list2))

    print(gla_name)
    print(head(data))

    rm(list=ls())
}


    # TODO add check: if there are geogrpahy column names not in the rename list then throw and error.


    #TODO add QA for the data?

   # saveRDS(data, fp_save)
  #}

#}
