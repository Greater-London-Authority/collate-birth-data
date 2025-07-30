library(readr)
library(dplyr)

fpath <- list(dir_processed = "data/processed/",
              births_mye = "data/intermediate/births_mye.rds",
              births_my_lad_1991_2017 = "data/intermediate/births_mid_year_lad_1991_2017.rds",
              births_cy_lad = "data/intermediate/births_calendar_year_lad.rds",
              monthly_births_dir = "data/intermediate/monthly_births/",
              lad_output_rds = "data/processed/births_lad.rds",
              monthly_lad_output_rds = "data/processed/births_lad_monthly.rds"
)

if(!dir.exists(fpath$dir_processed)) dir.create(fpath$dir_processed, recursive = TRUE)

#use births from mid-year estimate components of change for 2002 onward
births_my_pre_2002 <- readRDS(fpath$births_my_lad_1991_2017) %>%
  filter(year < 2002)

births_my_2002_on <- readRDS(fpath$births_mye)

births_cy_2013_on <- readRDS(fpath$births_cy_lad)

births_lad_persons <- bind_rows(
  births_my_pre_2002,
  births_my_2002_on,
  births_cy_2013_on
) %>%
  filter(sex == "persons") %>%
  arrange(gss_code, year_ending_date) %>%
  select(-year) %>%
  mutate(measure = "annual_births") %>%
  select(gss_code, gss_name, year_ending_date, measure, geography, source, everything())


saveRDS(births_lad_persons, fpath$lad_output_rds)

# combine monthly births files into one output
monthly_fnames <- list.files(fpath$monthly_births_dir, full.names = TRUE)

monthly_data <- lapply(monthly_fnames, read_rds) %>%
  bind_rows() %>%
  filter(sex == "persons")

saveRDS(monthly_data, fpath$monthly_lad_output_rds)

