fpath <- list(dir_processed = "data/processed/",
              births_mye = "data/intermediate/births_mye.rds",
              births_my_lad_1991_2017 = "data/intermediate/births_mid_year_lad_1991_2017.rds",
              births_cy_lad = "data/intermediate/births_calendar_year_lad.rds",
              lad_output_rds = "data/processed/births_lad.rds"
)

if(!dir.exists(fpath$dir_processed)) dir.create(fpath$dir_processed, recursive = TRUE)

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
