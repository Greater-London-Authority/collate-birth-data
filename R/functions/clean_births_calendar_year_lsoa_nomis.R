library(dplyr)

clean_births_calendar_year_lsoa_nomis <- function(
    fp_raw,
    fp_save,
    src_name = "",
    src_url = "https://www.nomisweb.co.uk/query/construct/summary.asp?mode=construct&version=0&dataset=206"
    ) {

  births_lsoa <- readRDS(fp_raw) %>%
    mutate(year_ending_date = as.Date(paste0(year + 1, "-01-01"), "%Y-%m-%d")) %>%
    mutate(source = src_name,
           source_url = src_url) %>%
    mutate(sex = "persons")

  saveRDS(births_lsoa, fp_save)
}
