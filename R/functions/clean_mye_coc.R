library(readr)
library(dplyr)
library(tidyr)

source("R/functions/add_persons.R")

clean_mye_coc <- function(fp_raw, fp_save) {

  mye_births <- read_csv(fp_raw) %>%
    rename(gss_code = ladcode21,
           gss_name = laname21) %>%
    filter(age == 0) %>%
    mutate(sex = as.character(sex)) %>%
    mutate(sex = recode(sex, "1" = "male", "2" = "female")) %>%
    select(contains(c("gss_code", "gss_name", "sex", "births"))) %>%
    pivot_longer(cols = contains("births"),
                 names_to = "year",
                 values_to = "value",
                 names_prefix = "births_"
    ) %>%
    mutate(year = as.integer(year)) %>%
    mutate(year_ending_date = as.Date(paste0(year, "-07-01"))) %>%
    mutate(source = "Mid Year Estimates",
           geography = "LAD21") %>%
    add_persons()

  saveRDS(mye_births, fp_save)
}
