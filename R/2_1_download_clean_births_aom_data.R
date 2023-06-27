library(readxl)
library(dplyr)
library(readr)

source("R/functions/clean_births_aom_lad_single_sheet.R")

fpath <- list(dir_raw = "data/raw/",
              dir_processed = "data/processed",
              raw_births_cy_aom_lad = "data/raw/birthsbyageofmotherlaua19932021finaltable.xlsx",
              births_cy_aom_lad = "data/processed/births_calendar_year_age_mother_lad.rds",
              births_cy_aom_lad_csv = "data/processed/births_calendar_year_age_mother_lad.csv"
)

urls <- list(births_cy_aom_lad = "https://www.ons.gov.uk/file?uri=/peoplepopulationandcommunity/birthsdeathsandmarriages/livebirths/adhocs/1265livebirthsbyageofmotherandlocalauthorityenglandandwales1993to2021/birthsbyageofmotherlaua19932021finaltable.xlsx"
)

if(!dir.exists(fpath$dir_raw)) dir.create(fpath$dir_raw, recursive = TRUE)
if(!dir.exists(fpath$dir_processed)) dir.create(fpath$dir_processed, recursive = TRUE)

download.file(url = urls$births_cy_aom_lad,
              destfile = fpath$raw_births_cy_aom_lad,
              mode = "wb")

wsheets <- excel_sheets(fpath$raw_births_cy_aom_lad)

all_years <- wsheets[grepl("[0-9]{4}$", wsheets)]

births_lad <- lapply(all_years, clean_births_aom_lad_single_sheet, fp = fpath$raw_births_cy_aom_lad) %>%
  bind_rows() %>%
  mutate(geography = "LAD22")

saveRDS(births_lad, fpath$births_cy_aom_lad)

births_lad_wide <- births_lad %>%
  pivot_wider(names_from = "age_mother", values_from = "value")

write_csv(births_lad_wide, fpath$births_cy_aom_lad_csv)
