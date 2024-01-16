source("R/functions/fetch_calendar_year_births_lsoa.R")
source("R/functions/fetch_mid_year_births_lsoa_1992_2017.R")
source("R/functions/fetch_mye_births.R")
source("R/functions/fetch_monthly_births_la.R")


fpath <- list(dir_raw = "data/raw/",
              raw_births_cy_lsoa = "data/raw/births_calendar_year_nomis_lsoa.rds",
              raw_births_my_lsoa = "data/raw/births_mid_year_lsoa_1991_2017.xlsx",
              raw_mye_coc = "data/raw/mye_coc.csv"
              )

urls <- list(mye_coc = "https://www.ons.gov.uk/file?uri=/peoplepopulationandcommunity/populationandmigration/populationestimates/datasets/populationestimatesforukenglandandwalesscotlandandnorthernireland/mid2021/dataforreconciliation.zip",
             births_my_lsoa = "https://www.ons.gov.uk/file?uri=/peoplepopulationandcommunity/birthsdeathsandmarriages/deaths/adhocs/009628birthsanddeathsbylowersuperoutputarealsoaenglandandwales1991to1992to2016to2017/lsoabirthsdeaths19912017final.zip"
             )

if(!dir.exists(fpath$dir_raw)) dir.create(fpath$dir_raw, recursive = TRUE)

# get lsoa calendar year births via Nomis api
fetch_calendar_year_births_lsoa(fp_save = fpath$raw_births_cy_lsoa)

# get lsoa mid-year births from ONS adhoc page
fetch_mid_year_births_lsoa_1992_2017(fp_save = fpath$raw_births_my_lsoa,
                                     url_zip = urls$births_my_lsoa
)

# get mid-year estimates summary components of change
fetch_mye_births(fp_save = fpath$raw_mye_coc,
                 url_zip = urls$mye_coc
)

# get monthly births from ONS adhoc pages (different page for each year, URLS are specified inside function)
fetch_monthly_births_la(dir_save = "data/raw/monthly_births/"
)

#2020 MYE file - now superseded
#"https://www.ons.gov.uk/file?uri=/peoplepopulationandcommunity/populationandmigration/populationestimates/datasets/populationestimatesforukenglandandwalesscotlandandnorthernireland/mid2001tomid2020detailedtimeseries/ukdetailedtimeseries2001to2020.zip"
