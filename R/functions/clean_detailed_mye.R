library(dplyr)
library(tidyr)
library(stringr)
library(readxl)

source("R/functions/add_persons.R")

clean_detailed_mye <- function(fp_raw, fp_save,
                               sheet_nm = "MYEB2 (2021 Geography)",
                               src_name = "ONS mid-year estimates",
                               src_url = "https://ons.gov.uk/peoplepopulationandcommunity/populationandmigration/populationestimates/datasets/estimatesofthepopulationforenglandandwales") {


  mye_births <- read_excel(fp_raw,
                               sheet = sheet_nm,
                               skip = 1) %>%
    rename(gss_code = ladcode21,
           gss_name = laname21) %>%
    filter(age == 0) %>%
    mutate(sex = recode(sex, "M" = "male", "F" = "female")) %>%
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
