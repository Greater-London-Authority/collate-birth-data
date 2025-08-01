source("R/functions/fetch_calendar_year_births_lsoa.R")
source("R/functions/fetch_mid_year_births_lsoa_1992_2017.R")
source("R/functions/fetch_mye_data.R")


fpath <- list(dir_raw = "data/raw/",
              dir_raw_monthly_births = "data/raw/monthly_births/",
              raw_births_cy_lsoa = "data/raw/births_calendar_year_nomis_lsoa.rds",
              raw_births_my_lsoa = "data/raw/births_mid_year_lsoa_1991_2017.xlsx",
              raw_mye_2011_on = "data/raw/mye_2011_on(2023_geog).xlsx",
              raw_mye_2001_11 = "data/raw/mye_2001_11(2018_geog).xlsx"
)

urls <- list(mye_2011_on = "https://www.ons.gov.uk/file?uri=/peoplepopulationandcommunity/populationandmigration/populationestimates/datasets/estimatesofthepopulationforenglandandwales/mid2011tomid2024detailedtimeseries/myebtablesenglandwales20112024.xlsx",
             mye_2001_11 = "https://www.ons.gov.uk/file?uri=/peoplepopulationandcommunity/populationandmigration/populationestimates/datasets/estimatesofthepopulationforenglandandwales/mid2001tomid2011detailedtimeseries/myebtablesewsn20012011.xlsx",
             births_my_lsoa = "https://www.ons.gov.uk/file?uri=/peoplepopulationandcommunity/birthsdeathsandmarriages/deaths/adhocs/009628birthsanddeathsbylowersuperoutputarealsoaenglandandwales1991to1992to2016to2017/lsoabirthsdeaths19912017final.zip"
)

if(!dir.exists(fpath$dir_raw)) dir.create(fpath$dir_raw, recursive = TRUE)
if(!dir.exists(fpath$dir_raw_monthly_births)) dir.create(fpath$dir_raw_monthly_births, recursive = TRUE)

# get lsoa calendar year births via Nomis api (2011 geog up to CY2022, 2021 geog from 2023 onwards)
fetch_calendar_year_births_lsoa(fp_save = fpath$raw_births_cy_lsoa)


# get lsoa mid-year births from ONS adhoc page
fetch_mid_year_births_lsoa_1992_2017(fp_save = fpath$raw_births_my_lsoa,
                                     url_zip = urls$births_my_lsoa
)

# get mid-year estimates data
# 2011-on
fetch_mye_data(url_raw = urls$mye_2011_on,
               fpath_raw = fpath$raw_mye_2011_on)

# 2001-11
fetch_mye_data(url_raw = urls$mye_2001_11,
                         fpath_raw = fpath$raw_mye_2001_11)



