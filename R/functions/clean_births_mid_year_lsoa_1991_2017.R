library(readxl)
library(dplyr)

source("R/functions/add_persons.R")

clean_births_mid_year_lsoa_1991_2017 <- function(fp_raw, fp_save,
                                                 src_name = "ONS ad hoc",
                                                 src_url = "https://www.ons.gov.uk/peoplepopulationandcommunity/birthsdeathsandmarriages/deaths/adhocs/009628birthsanddeathsbylowersuperoutputarealsoaenglandandwales1991to1992to2016to2017") {

  births_lsoa <- read_xlsx(fp_raw) %>%
    rename(LSOA_CODE = lsoa11) %>%
    select(-laua) %>%
    mutate(sex = recode(sex, "1" = "male", "2" = "female")) %>%
    pivot_longer(cols = -any_of(c("LSOA_CODE", "sex")), names_to = "year", values_to = "value") %>%
    mutate(year = as.integer(substr(year, 1, 4)) + 1) %>%
    mutate(year_ending_date = as.Date(paste0(year, "-07-01"))) %>%
    mutate(source = src_name,
           source_url = src_url) %>%
    add_persons()

  saveRDS(births_lsoa, fp_save)
}

