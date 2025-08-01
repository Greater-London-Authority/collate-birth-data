library(dplyr)
library(tidyr)
library(stringr)
library(readxl)

clean_mye_births <- function(fpath_raw,
                             sheet_name,
                             skip_rows = 1,
                             source_name = "ONS mid-year estimates",
                             source_url = "https://www.ons.gov.uk/peoplepopulationandcommunity/populationandmigration/populationestimates/datasets/estimatesofthepopulationforenglandandwales") {

  mye_births <- read_xlsx(fpath_raw, sheet = sheet_name, skip = skip_rows) %>%
    rename(any_of(c(gss_code = "ladcode21",
                    gss_code = "ladcode23",
                    gss_code = "ladcode18",
                    gss_name = "laname21",
                    gss_name = "laname23",
                    gss_name = "laname18",
                    country = "Country"))
    ) %>%
    mutate(sex = recode(sex,
                        "M" = "male",
                        "F" = "female",
                        "m" = "male",
                        "f" = "female",
                        "1" = "male",
                        "2" = "female")) %>%
    select(-country) %>%
    pivot_longer(cols = -any_of(c("gss_code", "gss_name", "age", "sex", "country")),
                 names_to = "component_year",
                 values_to = "value"
    ) %>%
    mutate(year = str_sub(component_year, -4, -1)) %>%
    mutate(component = str_sub(component_year, 1, -6)) %>%
    select(-component_year) %>%
    mutate(year = as.numeric(year)) %>%
    mutate(year_ending_date = as.Date(paste0(year, "-07-01"), "%Y-%m-%d")) %>%
    filter(component == "births") %>%
    filter(age == 0) %>%
    select(-c(component, age, year)) %>%
    mutate(source = source_name,
           source_url = source_url)

  return(mye_births)
}
