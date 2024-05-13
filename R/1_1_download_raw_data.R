source("R/functions/fetch_calendar_year_births_lsoa.R")
source("R/functions/fetch_mid_year_births_lsoa_1992_2017.R")
source("R/functions/fetch_mye_data.R")
source("R/functions/fetch_monthly_births_la.R")


fpath <- list(dir_raw = "data/raw/",
              dir_raw_monthly_births = "data/raw/monthly_births/",
              raw_births_cy_lsoa = "data/raw/births_calendar_year_nomis_lsoa.rds",
              raw_births_my_lsoa = "data/raw/births_mid_year_lsoa_1991_2017.xlsx",
              raw_mye_2011_on = "data/raw/mye_2011_on(2021_geog).xlsx",
              raw_mye_2001_11 = "data/raw/mye_2001_11(2018_geog).xlsx",
              monthly_births_urls = "lookups/monthly_births_data_urls.csv"
)

urls <- list(mye_2011_on = "https://www.ons.gov.uk/file?uri=/peoplepopulationandcommunity/populationandmigration/populationestimates/datasets/estimatesofthepopulationforenglandandwales/mid2011tomid2022detailedtimeseries/myebtablesenglandwales20112022v2.xlsx",
             mye_2001_11 = "https://www.ons.gov.uk/file?uri=/peoplepopulationandcommunity/populationandmigration/populationestimates/datasets/estimatesofthepopulationforenglandandwales/mid2001tomid2011detailedtimeseries/myebtablesewsn20012011.xlsx",
             births_my_lsoa = "https://www.ons.gov.uk/file?uri=/peoplepopulationandcommunity/birthsdeathsandmarriages/deaths/adhocs/009628birthsanddeathsbylowersuperoutputarealsoaenglandandwales1991to1992to2016to2017/lsoabirthsdeaths19912017final.zip"
)


if(!dir.exists(fpath$dir_raw)) dir.create(fpath$dir_raw, recursive = TRUE)
if(!dir.exists(fpath$dir_raw_monthly_births)) dir.create(fpath$dir_raw_monthly_births, recursive = TRUE)

# get lsoa calendar year births via Nomis api
fetch_calendar_year_births_lsoa(fp_save = fpath$raw_births_cy_lsoa)

# get lsoa mid-year births from ONS adhoc page
fetch_mid_year_births_lsoa_1992_2017(fp_save = fpath$raw_births_my_lsoa,
                                     url_zip = urls$births_my_lsoa
)

# get mid-year estimates data
# 2011-on
fetch_mye_data(url_raw = urls$mye_2011_on,
               fpath_raw = fpath$raw_mye_2011_on)

# 2011-11
fetch_mye_data(url_raw = urls$mye_2001_11,
                         fpath_raw = fpath$raw_mye_2001_11)

# get monthly births from ONS adhoc pages
fetch_monthly_births_la(dir_save = fpath$dir_raw_monthly_births,
                        url_lookup = fpath$monthly_births_urls)

#2020 MYE file - now superseded
#"https://www.ons.gov.uk/file?uri=/peoplepopulationandcommunity/populationandmigration/populationestimates/datasets/populationestimatesforukenglandandwalesscotlandandnorthernireland/mid2001tomid2020detailedtimeseries/ukdetailedtimeseries2001to2020.zip"
