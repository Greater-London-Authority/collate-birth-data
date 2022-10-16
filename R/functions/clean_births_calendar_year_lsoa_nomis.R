library(dplyr)

clean_births_calendar_year_lsoa_nomis <- function(fp_raw, fp_save) {

  births_lsoa <- readRDS(fp_raw) %>%
    mutate(year_ending_date = as.Date(paste0(year + 1, "-01-01"), "%Y-%m-%d")) %>%
    mutate(source = "ONS calendar year") %>%
    mutate(sex = "persons")

  saveRDS(births_lsoa, fp_save)
}
