source("R/functions/clean_mye_coc.R")
source("R/functions/clean_detailed_mye.R")
source("R/functions/clean_birth_summary_table.R")
source("R/functions/clean_births_mid_year_lsoa_1991_2017.R")
source("R/functions/clean_births_calendar_year_lsoa_nomis.R")
source("R/functions/aggregate_lsoa11_to_lad.R")

fpath <- list(raw_births_cy_lsoa = "data/raw/births_calendar_year_nomis_lsoa.rds",
              raw_births_my_lsoa = "data/raw/births_mid_year_lsoa_1991_2017.xlsx",
              raw_mye_coc = "data/raw/mye_coc.csv",
              raw_detailed_mye = "data/raw/myebtablesenglandwales20112022v2.xlsx",
              raw_birth_summary_table = "data/raw/birthsummary2022workbook.xlsx",
              dir_intermediate = "data/intermediate/",
              births_mye = "data/intermediate/births_mye.rds",
              births_my_lsoa_1991_2017 = "data/intermediate/births_mid_year_lsoa_1991_2017.rds",
              births_my_lad_1991_2017 = "data/intermediate/births_mid_year_lad_1991_2017.rds",
              births_cy_lsoa = "data/intermediate/births_calendar_year_lsoa.rds",
              births_cy_lad = "data/intermediate/births_calendar_year_lad.rds",
              birth_cy_latest_year = "data/intermediate/birth_cy_latest_year.rds",
              lookup_lsoa_lad = "lookups/lookup_lsoa_lad.rds"
)

if(!dir.exists(fpath$dir_intermediate)) dir.create(fpath$dir_intermediate, recursive = TRUE)

# clean_mye_coc(fp_raw = fpath$raw_mye_coc,
#               fp_save = fpath$births_mye)

clean_detailed_mye(fp_raw = fpath$raw_detailed_mye,
                   fp_save = fpath$births_mye)

clean_birth_summary_table(fp_raw = fpath$raw_birth_summary_table,
                          fp_save = fpath$birth_cy_latest_year)

clean_births_mid_year_lsoa_1991_2017(fp_raw = fpath$raw_births_my_lsoa,
                                     fp_save = fpath$births_my_lsoa_1991_2017)

clean_births_calendar_year_lsoa_nomis(fp_raw = fpath$raw_births_cy_lsoa,
                                      fp_save = fpath$births_cy_lsoa)

aggregate_lsoa11_to_lad(fp_lsoa = fpath$births_my_lsoa_1991_2017,
                        fp_save = fpath$births_my_lad_1991_2017,
                        lookup_lsoa_lad = readRDS(fpath$lookup_lsoa_lad))

aggregate_lsoa11_to_lad(fp_lsoa = fpath$births_cy_lsoa,
                        fp_save = fpath$births_cy_lad,
                        lookup_lsoa_lad = readRDS(fpath$lookup_lsoa_lad))
