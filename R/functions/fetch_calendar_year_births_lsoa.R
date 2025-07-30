library(nomisr)
library(dplyr)

fetch_calendar_year_births_lsoa <- function(fp_save) {

  births_cy_lsoa_to2022 <- nomis_get_data(id = "NM_206_1",
                                   geography = "TYPE298",
                                   measures = "20100") %>%
    select(year = DATE, LSOA_CODE = GEOGRAPHY_CODE, value = OBS_VALUE) %>%
    na.omit()

  births_cy_lsoa_2023on <- nomis_get_data(id = "NM_206_1",
                                          geography = "TYPE151",
                                          measures = "20100") %>%
    select(year = DATE, LSOA_CODE = GEOGRAPHY_CODE, value = OBS_VALUE) %>%
    na.omit()

  births_cy_lsoa <- bind_rows(births_cy_lsoa_to2022,
                              births_cy_lsoa_2023on)

  saveRDS(births_cy_lsoa, fp_save)
}
