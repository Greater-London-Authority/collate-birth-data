library(readxl)
library(tidyr)
library(dplyr)
library(lubridate)
library(stringr)
source("R/functions/recode_gss.R")

clean_monthly_births_la <- function(dir_raw, dir_save,
                                    src_name = "ONS ad hoc",
                                    url_lookup) {

  ####  uncomment to run manually
  # dir_raw <- "data/raw/monthly_births/"
  # dir_save <- "data/intermediate/monthly_births/"
  # src_name <- "ONS ad hoc"
  # url_lookup <- "lookups/monthly_births_data_urls.csv"
  # file_ind <- 1 #row number of monthly_births_urls dataframe that specifies the file to work with
  ####

  monthly_births_urls <- read.csv(url_lookup, stringsAsFactors = FALSE) %>%
    mutate(ext = gsub(".*\\.", "\\.", basename(url)),
           fp_raw = paste0(dir_raw,"/",gla_filename, ext),
           fp_save = paste0(dir_save,"/",gla_filename, ".rds"))

  for (file_ind in seq_len(nrow(monthly_births_urls))) { # TODO is there a more elegant way to do this than in a for loop?

    file_info <- monthly_births_urls[file_ind,]
    print(paste("CLEANING MONTHLY BIRTHS FILE NUMBER", file_ind))

    raw_data <-  suppressMessages(read_excel(file_info$fp_raw, sheet = file_info$data_sheet_name, col_names = FALSE))

    start_date <- as.Date(file_info$start_date, format = "%d/%m/%Y")
    end_date <- as.Date(file_info$end_date, format = "%d/%m/%Y")
    print(paste("Start date (YYYY-MM-DD):", start_date))
    print(paste("End date (YYYY-MM-DD):", end_date))

    # create lookup for date of last day of month for each month in the data
    n_months <- interval(start_date, end_date + 1) / months(1)
    month_ends <- seq(start_date, by="month", length.out = n_months + 1) - 1
    months_lookup <- data.frame(month_ending_date = month_ends[-1]) %>%
      mutate(month = tolower(months(month_ending_date)))
    rm(month_ends, n_months)

    # start_cell is given as an excel cell reference e.g. D6. Convert to numeric row and col indicies.
    start_col_letter <- gsub("\\d*", "", file_info$births_values_start_cell)
    start_col <- which(letters == tolower(start_col_letter))
    start_row <- as.numeric(gsub("\\D*","",file_info$births_values_start_cell))

    # check that the start cell contains a number, and that the cell to the left and above are not numbers
    start_cell <- raw_data[start_row, start_col] %>% pull()
    left <- raw_data[start_row, start_col - 1] %>% pull()
    above <- raw_data[start_row - 1, start_col] %>% pull()

    if (!grepl("^\\d+$", start_cell)) stop("The start cell does not contain a number") #TODO this test fails if there are commas or decimals in the number. So far as no files contain them but this might not always be the case...
    if (grepl("^\\d+$", left)) stop("The start cell is not the first cell with a number, the one to the left is a number too.") #TODO this test doesn't work if there are commas or decimals in the number. Might have to change that but the regex will be complicated.
    if (grepl("^\\d+$", above)) stop("The start cell is not the first cell with a number, the one above is a number too.") #TODO this test doesn't work if there are commas or decimals in the number. Might have to change that but the regex will be complicated.
    rm (start_cell, left, above)

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
    sex_headers <- births_cols[2,]

    # check that sex_headers does actually contain the sex headers and only the sex headers
    if (!(all(c("total", "male", "female") %in% tolower(sex_headers[1:3])) &
          all(tolower(sex_headers) %in% c("total", "male", "female")))) {
      print(head(births_cols, 4))
      stop("The second row of births_cols must contain: 'total', 'male' & 'female' (case insensitive) and nothing else")
    }

    eg_month_header <- month_headers[,1] # month headers are either given as a date or as a character string of month name.

    if(grepl("^\\d+$", eg_month_header)) { # if it has been given as a date in excel, convert this to a date object
      month_header_type <- "date" # use this to determine how to do the final formatting of the output dataframe
      month_headers <- month_headers %>%
        mutate(across(all_of(names(month_headers)), \(x) as.Date(as.numeric(x),  origin = "1899-12-30")),
               across(all_of(names(month_headers)), \(x) x %m+% months(1) - 1)) # change from first day of month to last day of month

      # check that month_headers starts with the expected date and is in the expected format
      if (!identical(floor_date(month_headers[,1], "month"), start_date)) {
        stop(paste0("The first date cell has been translated from an excel date number to ", floor_date(month_headers[,1], "month"), ", but the start date for the file has been given as ", start_date, " in the monthly_births_data_urls lookup file." ))
      }
      if (!(is.na(month_headers[,2]) &
            is.na(month_headers[,3]))) {
        print(head(births_cols,4))
        stop("The first row of births_cols must contain a month name or excel date number followed by 2 NAs repeated along the row")
      }


    } else {
      month_header_type <- "name"

      # check that month_headers contains months and is in the expected format
      if (!(tolower(month_headers[,1]) %in% tolower(month.name) &
            is.na(month_headers[,2]) &
            is.na(month_headers[,3]))) {
        print(head(births_cols,4))
        stop("The first row of births_cols must contain a month name or date followed by 2 NAs repeated along the row")
      }

    }
    rm(eg_month_header)

    long_month_headers = data.frame(t(month_headers))
    long_month_headers <- fill(long_month_headers, X1)
    month_headers <- data.frame(t(long_month_headers)) # back to horizontal.
    rm(long_month_headers)

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

    first_births_col <- names(births_cols)[1]
    last_births_col <- names(births_cols)[ncol(births_cols)]
    last_total_col <- names(births_cols)[ncol(births_cols) - 2] # ugly hack to get rid of any notes ONS might have written below data

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

    data <- data %>%
      filter(grepl("^(E06|E07|E08|E09)", gss_code)) %>% # only keep LAs in England
      select(-gss_name) %>% # these are replaced below with our own lookup
      mutate(gss_code = str_replace(gss_code, pattern = intToUtf8(8218), replacement = ",")) # some ONS files use a 'Single Low-9 Quotation Mark' instead of a comma in the combined GSS code areas

    # Each file has gss codes from different years. Update all codes to 2021
    # This won't work on combined areas (currently "E09000012, E09000001" and "E06000052, E06000053")
    data <- data %>%
      recode_gss_codes(col_geog="gss_code",
                       data_cols = "value",
                       fun = "sum",
                       recode_to_year = 2021,
                       aggregate_data = TRUE,
                       recode_gla_codes = FALSE,
                       code_changes_path = NULL) %>%
      tibble() %>%
      mutate(geography = "LAD21")

    # most years of data have combined codes "E09000012, E09000001" and "E06000052, E06000053".
    # combine any which aren't so that they match the rest

    Hackney_CoL <- c("E09000012", "E09000001")
    Hackney_CoL_name <- "Hackney and City of London"
    Cornwall_Scilly <- c("E06000052", "E06000053")
    Cornwall_Scilly_name <- "Cornwall and Isles of Scilly"

    if (all(Hackney_CoL %in% data$gss_code)) {
      combined <- filter(data, gss_code %in% Hackney_CoL) %>%
        group_by(across(c(-gss_code, -value))) %>%
        summarise(value = sum(value)) %>%
        mutate(gss_code = paste(Hackney_CoL, collapse = ", ")) %>%
        ungroup()

      data <- data %>%
        filter(!gss_code %in% Hackney_CoL) %>%
        bind_rows(combined)
    }

    if (all(Cornwall_Scilly %in% data$gss_code)) {
      combined <- filter(data, gss_code %in% Cornwall_Scilly) %>%
        group_by(across(c(-gss_code, -value))) %>%
        summarise(value = sum(value)) %>%
        mutate(gss_code = paste(Cornwall_Scilly, collapse = ", ")) %>%
        ungroup()

      data <- data %>%
        filter(!gss_code %in% Cornwall_Scilly) %>%
        bind_rows(combined)
    }

    data <- data %>%
      arrange(gss_code, month_ending_date, sex)

    # Take LA names from the lad_rgn lookup file (uses 2021 geography) as the ONS data doesn't have consistent naming across files
    la_lookup <- readRDS("lookups/lookup_lad_rgn.rds") %>%
      select(gss_code, gss_name)

    combined_gss <- data.frame(gss_code = c(paste(Hackney_CoL, collapse = ", "), paste(Cornwall_Scilly, collapse = ", ")),
                               gss_name = c(Hackney_CoL_name, Cornwall_Scilly_name))

    la_lookup <- bind_rows(la_lookup, combined_gss)

    if (nrow(filter(data, !gss_code %in% la_lookup$gss_code)) != 0) {
      stop("there are gss codes in the raw data which aren't in the project's lad to region lookup file")
    }

    data <- data %>%
      left_join(la_lookup, by = "gss_code") %>%
      mutate(measure = "monthly_births") %>%
      select(gss_code, gss_name, month_ending_date, year, month, measure, geography, source, source_url, sex, value)

    print("cleaned data:")
    print(data, n = 4)
    saveRDS(data, file = file_info$fp_save)

  }
}
