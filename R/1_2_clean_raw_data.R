source("R/functions/clean_mye_coc.R")
source("R/functions/clean_births_mid_year_lsoa_1991_2017.R")
source("R/functions/clean_births_calendar_year_lsoa_nomis.R")
source("R/functions/aggregate_lsoa11_to_lad.R")
source("R/functions/clean_monthly_births_la.R")


fpath <- list(raw_births_cy_lsoa = "data/raw/births_calendar_year_nomis_lsoa.rds",
              raw_births_my_lsoa = "data/raw/births_mid_year_lsoa_1991_2017.xlsx",
              raw_mye_coc = "data/raw/mye_coc.csv",
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

if(!dir.exists(fpath$dir_intermediate)) dir.create(fpath$dir_intermediate, recursive = TRUE)
if(!dir.exists(fpath$dir_intermediate_monthly_births)) dir.create(fpath$dir_intermediate_monthly_births, recursive = TRUE)


clean_mye_coc(fp_raw = fpath$raw_mye_coc,
              fp_save = fpath$births_mye)

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
