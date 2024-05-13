source("R/functions/clean_mye_births.R")
source("R/functions/clean_births_mid_year_lsoa_1991_2017.R")
source("R/functions/clean_births_calendar_year_lsoa_nomis.R")
source("R/functions/aggregate_lsoa11_to_lad.R")
source("R/functions/clean_monthly_births_la.R")
source("R/functions/recode_gss.R")
source("R/functions/add_persons.R")

fpath <- list(raw_births_cy_lsoa = "data/raw/births_calendar_year_nomis_lsoa.rds",
              raw_births_my_lsoa = "data/raw/births_mid_year_lsoa_1991_2017.xlsx",
              raw_mye_2011_on = "data/raw/mye_2011_on(2021_geog).xlsx",
              raw_mye_2001_11 = "data/raw/mye_2001_11(2018_geog).xlsx",
              dir_raw_monthly_births = "data/raw/monthly_births/",
              dir_intermediate = "data/intermediate/",
              dir_intermediate_monthly_births = "data/intermediate/monthly_births/",
              births_mye = "data/intermediate/births_mye.rds",
              births_my_lsoa_1991_2017 = "data/intermediate/births_mid_year_lsoa_1991_2017.rds",
              births_my_lad_1991_2017 = "data/intermediate/births_mid_year_lad_1991_2017.rds",
              births_cy_lsoa = "data/intermediate/births_calendar_year_lsoa.rds",
              births_cy_lad = "data/intermediate/births_calendar_year_lad.rds",
              lookup_lsoa_lad = "lookups/lookup_lsoa_lad.rds",
              monthly_births_urls = "lookups/monthly_births_data_urls.csv"

)

urls <- list(mye_2011_on = "https://www.ons.gov.uk/file?uri=/peoplepopulationandcommunity/populationandmigration/populationestimates/datasets/estimatesofthepopulationforenglandandwales/mid2011tomid2022detailedtimeseries/myebtablesenglandwales20112022v2.xlsx",
             mye_2001_11 = "https://www.ons.gov.uk/file?uri=/peoplepopulationandcommunity/populationandmigration/populationestimates/datasets/estimatesofthepopulationforenglandandwales/mid2001tomid2011detailedtimeseries/myebtablesewsn20012011.xlsx",
             births_my_lsoa = "https://www.ons.gov.uk/file?uri=/peoplepopulationandcommunity/birthsdeathsandmarriages/deaths/adhocs/009628birthsanddeathsbylowersuperoutputarealsoaenglandandwales1991to1992to2016to2017/lsoabirthsdeaths19912017final.zip"
)

if(!dir.exists(fpath$dir_intermediate)) dir.create(fpath$dir_intermediate, recursive = TRUE)
if(!dir.exists(fpath$dir_intermediate_monthly_births)) dir.create(fpath$dir_intermediate_monthly_births, recursive = TRUE)

mye_births_2012_on <- clean_mye_births(fpath$raw_mye_2011_on,
                                       sheet_name = "MYEB2 (2021 Geography)",
                                       skip_rows = 1,
                                       source_name = "ONS mid-year estimates",
                                       source_url = urls$mye_2011_on)

mye_births_2002_11 <- clean_mye_births(fpath$raw_mye_2001_11,
                                       sheet_name = "MYEB2 (2018 Geography)",
                                       skip_rows = 1,
                                       source_name = "ONS mid-year estimates",
                                       source_url = urls$mye_2011_on) %>%
                          recode_gss_codes(recode_to_year = 2021,
                                           code_changes_path = "lookups/code_changes_lookup.rds")

mye_births <- bind_rows(mye_births_2002_11,
                        mye_births_2012_on) %>%
  add_persons()

saveRDS(mye_births, fpath$births_mye)

rm(mye_births_2002_11, mye_births_2012_on, mye_births)

clean_births_mid_year_lsoa_1991_2017(fp_raw = fpath$raw_births_my_lsoa,
                                     fp_save = fpath$births_my_lsoa_1991_2017)

clean_births_calendar_year_lsoa_nomis(fp_raw = fpath$raw_births_cy_lsoa,
                                      fp_save = fpath$births_cy_lsoa)

clean_monthly_births_la(dir_raw = fpath$dir_raw_monthly_births ,
                        dir_save = fpath$dir_intermediate_monthly_births,
                        src_name = "ONS ad hoc",
                        url_lookup = fpath$monthly_births_urls,
                        gss_code_year = 2021)

aggregate_lsoa11_to_lad(fp_lsoa = fpath$births_my_lsoa_1991_2017,
                        fp_save = fpath$births_my_lad_1991_2017,
                        lookup_lsoa_lad = readRDS(fpath$lookup_lsoa_lad))

aggregate_lsoa11_to_lad(fp_lsoa = fpath$births_cy_lsoa,
                        fp_save = fpath$births_cy_lad,
                        lookup_lsoa_lad = readRDS(fpath$lookup_lsoa_lad))
