library(readxl)
library(tidyr)
library(dplyr)
library(lubridate)

clean_monthly_births_la <- function(dir_raw, dir_save,
                                    src_name = "ONS ad hoc",
                                    url_lookup) {

  #### TODO: delete these as they are fed in through funtion call.
  dir_raw <- "data/raw/monthly_births/"
  dir_save <- "data/intermediate/monthly_births/"
  src_name <- "ONS ad hoc"
  url_lookup <- "lookups/monthly_births_data_urls.csv"
  file_ind <- 2 #row number of monthly_births_urls dataframe that specifies the file to work with
  ####

  monthly_births_urls <- read.csv(url_lookup, stringsAsFactors = FALSE) %>%
    mutate(ext = gsub(".*\\.", "\\.", basename(url)),
           fp_raw = paste0(dir_raw,"/",gla_filename, ext),
           fp_save = paste0(dir_save,"/",gla_filename, ".rds"))

  for (file_ind in seq_len(nrow(monthly_births_urls))) { # TODO is there a more elegant way to do this than in a for loop?
    #print(file_ind)
    file_info <- monthly_births_urls[file_ind,]

    # create lookup for date of last day of month for each month in the data
    start_date <- as.Date(file_info$start_date, format = "%d/%m/%Y")
    end_date <- as.Date(file_info$end_date, format = "%d/%m/%Y")
    n_months <- interval(start_date, end_date + 1) / months(1)
    month_ends <- seq(start_date, by="month", length.out = n_months + 1) - 1
    months_lookup <- data.frame(month_ending_date = month_ends[-1]) %>%
      mutate(month = tolower(months(month_ending_date)))
    rm(start_date, month_ends, n_months)

    raw_data <-  suppressMessages(read_excel(file_info$fp_raw, sheet = file_info$data_sheet_name, col_names = FALSE))

    # start_cell is given as an excel cell reference e.g. D6. Convert to numeric row and col indicies.
    start_col_letter <- gsub("\\d*", "", file_info$births_values_start_cell)
    start_col <- which(letters == tolower(start_col_letter))
    start_row <- as.numeric(gsub("\\D*","",file_info$births_values_start_cell))


    # data comes with the month labels in merged header cells covering columns for totals, female, and male births. Rows are for each LA.
    # headers start 2 rows above the data values

    # sometimes there is an empty row before the data values start.  Remove this if it exists so that relative row referencing works for finding the header rows
    if (all(is.na(raw_data[start_row - 1, 10:20]))){  # chosen a bunch of columns which should definitely contain data. If they are not then assume the row is an empty one and delete it
      raw_data <- raw_data[-(start_row-1),]
      start_row <- start_row - 1
    }

    # sometimes there is an empty row between the month and sex headers.  Remove this if it exists so that relative row referencing works for finding the header rows
    if (all(is.na(raw_data[start_row - 2, 10:20]))){  # chosen a bunch of columns which should definitely contain data or be empty if the row is an empty one
      raw_data <- raw_data[-(start_row-2),]
      start_row <- start_row - 1
    }
    # create column headers that contain both the month and the sex.

    births_cols <- raw_data[(start_row - 2):nrow(raw_data),start_col:ncol(raw_data)] %>%
      as.data.frame()

    month_headers <- births_cols[1,]

    eg_month_header <- month_headers[,1] # month headers are either given as a date or as a character string of month name.
    month_header_type <- "name" # use this to determine how to do the final formatting of the output dataframe

    if(grepl("^\\d+$", eg_month_header)) { # if it has been given as a date in excel, convert this to a date object
      month_header_type <- "date"
      month_headers <- month_headers %>%
        mutate(across(all_of(names(month_headers)), \(x) as.Date(as.numeric(x),  origin = "1899-12-30")))
    }
    rm(eg_month_header)

    long_month_headers = data.frame(t(month_headers))
    long_month_headers <- fill(long_month_headers, X1)
    month_headers <- data.frame(t(long_month_headers)) # back to horizontal.
    rm(long_month_headers)

    sex_headers <- births_cols[2,]

    # headers <- tolower(paste(sex_headers, month_headers, sep = "_"))
    headers <- tolower(paste(month_headers, sex_headers, sep = "_"))
    rm(month_headers, sex_headers)

    births_cols <- births_cols[3:nrow(births_cols),]
    names(births_cols) <- headers
    rm(headers)

    geog_cols <- raw_data[(start_row-1):nrow(raw_data), 1:(start_col-1)]

    if (all(is.na(geog_cols[1,]))) { # 2014 to 2015 ONS file doesn't have geography column names
      geog_cols <- rename(geog_cols, c("gss_code" = "...1", "gss_name" = "...2"))
    } else {
      names(geog_cols) <- as.character(geog_cols[1,])
    }

    geog_cols <- geog_cols[-1,]

    #TODO: add a QA step that prints the first and last column headers to make sure there arent any random notes on the rhs of the data

    first_births_col <- names(births_cols)[1]
    last_births_col <- names(births_cols)[ncol(births_cols)]
    last_total_col <- names(births_cols)[ncol(births_cols) - 2] # ugly hack to get rid of any notes ONS might have written below data

    #TODO add check that sex is given as 'total', 'male' or 'female'

    data <- bind_cols(geog_cols, births_cols) %>%
      filter(!is.na(get(last_total_col))) %>% # ugly hack to get rid of any notes ONS might have written below data
      #pivot_longer(get(first_births_col):get(last_births_col), names_to = "month_sex", values_to = "value") %>%
      pivot_longer(matches("total|female|male"), names_to = "month_sex", values_to = "value") %>%
      mutate(month = gsub("_.*", "", month_sex),
             sex = gsub(".*_", "", month_sex),
             sex = ifelse(sex == "total", "persons", sex),
             value = as.numeric(value),
             source = src_name,
             source_url = file_info$url) %>%
      select(-month_sex)

    if (month_header_type == "name") {
      data <- left_join(data, months_lookup, by = "month") %>%
        mutate(year = year(month_ending_date))
    } else {
      data <- data %>%
        mutate(month_ending_date = as.Date(month),
               month = months(month_ending_date),
               year = year(month_ending_date))
    }


    names(data) <- tolower(names(data))

    rename_cols <- c(code = "gss_code",
                     `area codes` = "gss_code",
                     name = "gss_name",
                     `area of usual residence` = "gss_name",
                     geography = "geography")

    rename_list <- rename_cols[names(rename_cols) %in% names(data)]
    rename_list_inv <- names(rename_list)
    names(rename_list_inv) <- rename_list
    data <- rename(data, all_of(rename_list_inv))



    #print(head(data))
    saveRDS(data, file = file_info$fp_save)

  }
}
