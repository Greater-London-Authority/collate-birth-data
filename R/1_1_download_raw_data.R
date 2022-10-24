source("R/functions/fetch_calendar_year_births_lsoa.R")
source("R/functions/fetch_mid_year_births_lsoa_1992_2017.R")
source("R/functions/fetch_mye_births.R")

fpath <- list(dir_raw = "data/raw/",
              raw_births_cy_lsoa = "data/raw/births_calendar_year_nomis_lsoa.rds",
              raw_births_my_lsoa = "data/raw/births_mid_year_lsoa_1991_2017.xlsx",
              raw_mye_coc = "data/raw/mye_coc.csv"
              )

if(!dir.exists(fpath$dir_raw)) dir.create(fpath$dir_raw, recursive = TRUE)

# get lsoa calendar year births via Nomis api
fetch_calendar_year_births_lsoa(fpath$raw_births_cy_lsoa)

# get lsoa mid-year births from ONS adhoc page
fetch_mid_year_births_lsoa_1992_2017(fpath$raw_births_my_lsoa,
                                     url_zip = "https://www.ons.gov.uk/file?uri=/peoplepopulationandcommunity/birthsdeathsandmarriages/deaths/adhocs/009628birthsanddeathsbylowersuperoutputarealsoaenglandandwales1991to1992to2016to2017/lsoabirthsdeaths19912017final.zip"
)

# get mid-year estimates summary components of change
fetch_mye_births(fpath$raw_mye_coc,
                 url_zip = "https://www.ons.gov.uk/file?uri=/peoplepopulationandcommunity/populationandmigration/populationestimates/datasets/populationestimatesforukenglandandwalesscotlandandnorthernireland/mid2001tomid2020detailedtimeseries/ukdetailedtimeseries2001to2020.zip"
)
