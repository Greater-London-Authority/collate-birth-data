library(nomisr)
library(dplyr)

fetch_calendar_year_births_lsoa <- function(fp_save) {

  births_cy_lsoa <- nomis_get_data(id = "NM_206_1",
                                   geography = "TYPE298",
                                   measures = "20100") %>%
    select(year = DATE, LSOA11CD = GEOGRAPHY_CODE, value = OBS_VALUE)

  saveRDS(births_cy_lsoa, fp_save)
}
