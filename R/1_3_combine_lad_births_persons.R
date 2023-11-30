fpath <- list(dir_processed = "data/processed/",
              births_mye = "data/intermediate/births_mye.rds",
              births_my_lad_1991_2017 = "data/intermediate/births_mid_year_lad_1991_2017.rds",
              births_cy_lad = "data/intermediate/births_calendar_year_lad.rds",
              birth_cy_latest_year = "data/intermediate/birth_cy_latest_year.rds",
              lad_output_rds = "data/processed/births_lad.rds"
)

source("R/functions/split_isles_of_scilly_cornwall.R")

if(!dir.exists(fpath$dir_processed)) dir.create(fpath$dir_processed, recursive = TRUE)

#use births from mid-year estimate components of change for 2002 onward
births_my_pre_2012 <- readRDS(fpath$births_my_lad_1991_2017) %>%
  filter(year < 2012)

births_my_2012_on <- readRDS(fpath$births_mye)

births_cy_2013_on <- readRDS(fpath$births_cy_lad)

nomis_latest_cy <- max(births_cy_2013_on$year)

birth_cy_latest_year = split_isles_of_scilly_cornwall(readRDS(fpath$birth_cy_latest_year),
                                                      ios_births = 20) %>%
  filter(grepl("E0|W0", gss_code))

birth_summary_table_year <- max(birth_cy_latest_year$year)

if(birth_summary_table_year > nomis_latest_cy) births_cy_2013_on <- bind_rows(births_cy_2013_on,
                                                                              birth_cy_latest_year)

births_lad_persons <- bind_rows(
  births_my_pre_2012,
  births_my_2012_on,
  births_cy_2013_on
) %>%
  filter(sex == "persons") %>%
  arrange(gss_code, year_ending_date) %>%
  select(-year) %>%
  mutate(measure = "annual_births") %>%
  select(gss_code, gss_name, year_ending_date, measure, geography, source, everything())


saveRDS(births_lad_persons, fpath$lad_output_rds)
