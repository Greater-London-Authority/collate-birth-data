library(readxl)
library(dplyr)
library(tidyr)

clean_births_aom_lad_single_sheet <- function(yr, fp, skip_rows = 4) {

  suppressMessages(in_df <- read_xlsx(path = fp,
                      sheet = yr,
                      skip = skip_rows) %>%
    select(1:25)
  )

  out_df <- in_df %>%
    rename(gss_code = Code, gss_name = `Local Authority`, total = `Total Live Births`) %>%
    pivot_longer(cols = -any_of(c("gss_code", "gss_name")),
                 values_to = "value",
                 names_to = "age_mother") %>%
    mutate(year = as.numeric(yr)) %>%
    mutate(date = as.Date(paste0(year + 1, "-01-01"))) %>%
    select(year, date, everything())

  return(out_df)
}
