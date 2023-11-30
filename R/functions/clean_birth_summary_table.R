library(dplyr)
library(tidyr)
library(stringr)
library(readxl)

clean_birth_summary_table <- function(fp_raw, fp_save,
                               sheet_nm = "3",
                               yr = 2022,
                               src_name = "ONS calendar-year estimates",
                               src_url = "https://www.ons.gov.uk/peoplepopulationandcommunity/birthsdeathsandmarriages/livebirths/datasets/birthsummarytables") {

  births <- read_excel(fp_raw,
                       sheet = sheet_nm,
                       skip = 10,
                       col_names = c("gss_code", "gss_name", "area_type", "births", "tfr", "stillbirths", "stillbirth_rate", "stillbirth_rate_ur")) %>%

    mutate(sex = "persons") %>%
    filter(!grepl("J99000001", gss_code)) %>%
    mutate(year = yr) %>%
    select(gss_code, gss_name, year, sex, value = births) %>%
    mutate(year_ending_date = as.Date(paste0(year + 1, "-01-01"), "%Y-%m-%d")) %>%
    mutate(source = src_name,
           source_url = src_url,
           geography = "LAD21")

  saveRDS(births, fp_save)
}
