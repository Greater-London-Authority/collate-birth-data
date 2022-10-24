source("R/functions/clean_mye_coc.R")
source("R/functions/clean_births_mid_year_lsoa_1991_2017.R")
source("R/functions/clean_births_calendar_year_lsoa_nomis.R")
source("R/functions/aggregate_lsoa11_to_lad.R")

fpath <- list(raw_births_cy_lsoa = "data/raw/births_calendar_year_nomis_lsoa.rds",
              raw_births_my_lsoa = "data/raw/births_mid_year_lsoa_1991_2017.xlsx",
              raw_mye_coc = "data/raw/mye_coc.csv",
              dir_intermediate = "data/intermediate/",
              births_mye = "data/intermediate/births_mye.rds",
              births_my_lsoa_1991_2017 = "data/intermediate/births_mid_year_lsoa_1991_2017.rds",
              births_my_lad_1991_2017 = "data/intermediate/births_mid_year_lad_1991_2017.rds",
              births_cy_lsoa = "data/intermediate/births_calendar_year_lsoa.rds",
              births_cy_lad = "data/intermediate/births_calendar_year_lad.rds",
              lookup_lsoa_lad = "lookups/lookup_lsoa_lad.rds"
)

if(!dir.exists(fpath$dir_intermediate)) dir.create(fpath$dir_intermediate, recursive = TRUE)

clean_mye_coc(fpath$raw_mye_coc, fpath$births_mye)

clean_births_mid_year_lsoa_1991_2017(fpath$raw_births_my_lsoa, fpath$births_my_lsoa_1991_2017)

clean_births_calendar_year_lsoa_nomis(fpath$raw_births_cy_lsoa, fpath$births_cy_lsoa)

aggregate_lsoa11_to_lad(fpath$births_my_lsoa_1991_2017, fpath$births_my_lad_1991_2017,
                        readRDS(fpath$lookup_lsoa_lad))

aggregate_lsoa11_to_lad(fpath$births_cy_lsoa, fpath$births_cy_lad,
                        readRDS(fpath$lookup_lsoa_lad))
