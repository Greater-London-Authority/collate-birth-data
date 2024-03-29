library(readr)
library(dplyr)
library(tidyr)

source("R/functions/add_persons.R")

clean_mye_coc <- function(fp_raw, fp_save,
                          src_name = "ONS mid-year estimates",
                          src_url = "https://www.ons.gov.uk/peoplepopulationandcommunity/populationandmigration/populationestimates/datasets/populationestimatesforukenglandandwalesscotlandandnorthernireland") {

  mye_births <- read_csv(fp_raw) %>%
    rename(gss_code = ladcode21,
           gss_name = ladname21) %>%
    filter(age == 0) %>%
    mutate(sex = as.character(sex)) %>%
    mutate(sex = recode(sex, "1" = "female", "2" = "male")) %>% #NB: ONS only adopted this convention recently
    select(contains(c("gss_code", "gss_name", "sex", "births"))) %>%
    pivot_longer(cols = contains("births"),
                 names_to = "year",
                 values_to = "value",
                 names_prefix = "births_"
    ) %>%
    mutate(year = as.integer(year)) %>%
    mutate(year_ending_date = as.Date(paste0(year, "-07-01"))) %>%
    mutate(source = src_name,
           source_url = src_url,
           geography = "LAD21") %>%
    add_persons()

  saveRDS(mye_births, fp_save)
}
