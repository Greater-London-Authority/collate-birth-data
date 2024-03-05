library(dplyr)
library(RcppRoll)

source("R/functions/aggregate_to_region.R")

fpath <- list(lad_output_rds = "data/processed/births_lad.rds",
              rgn_output_rds = "data/processed/births_rgn.rds",
              itl_output_rds = "data/processed/births_itl.rds",
              ctry_output_rds = "data/processed/births_ctry.rds",

              lad_output_csv = "data/processed/births_lad.csv",
              rgn_output_csv = "data/processed/births_rgn.csv",
              itl_output_csv = "data/processed/births_itl.csv",
              ctry_output_csv = "data/processed/births_ctry.csv",

              lad_monthly_output_rds = "data/processed/births_lad_monthly.rds",
              rgn_monthly_output_rds = "data/processed/births_rgn_monthly.rds",
              itl_monthly_output_rds = "data/processed/births_itl_monthly.rds",
              ctry_monthly_output_rds = "data/processed/births_ctry_monthly.rds",

              lad_monthly_output_csv = "data/processed/births_lad_monthly.csv",
              rgn_monthly_output_csv = "data/processed/births_rgn_monthly.csv",
              itl_monthly_output_csv = "data/processed/births_itl_monthly.csv",
              ctry_monthly_output_csv = "data/processed/births_ctry_monthly.csv",

              lad_yearly_by_month_output_rds = "data/processed/births_lad_yearly_by_month.rds",
              rgn_yearly_by_month_output_rds = "data/processed/births_rgn_yearly_by_month.rds",
              itl_yearly_by_month_output_rds = "data/processed/births_itl_yearly_by_month.rds",
              ctry_yearly_by_month_output_rds = "data/processed/births_ctry_yearly_by_month.rds",

              lad_yearly_by_month_output_csv = "data/processed/births_lad_yearly_by_month.csv",
              rgn_yearly_by_month_output_csv = "data/processed/births_rgn_yearly_by_month.csv",
              itl_yearly_by_month_output_csv = "data/processed/births_itl_yearly_by_month.csv",
              ctry_yearly_by_month_output_csv = "data/processed/births_ctry_yearly_by_month.csv",

              lookup_lad_rgn = "lookups/lookup_lad_rgn.rds",
              lookup_lad_itl = "lookups/lookup_lad_itl.rds",
              lookup_lad_ctry = "lookups/lookup_lad_ctry.rds")

births_lad <- readRDS(fpath$lad_output_rds)

births_rgn <- aggregate_to_region(births_lad,
                                  readRDS(fpath$lookup_lad_rgn)) %>%
  na.omit() %>%
  arrange(gss_code, year_ending_date) %>%
  mutate(geography = "RGN21") %>%
  select(gss_code, gss_name, everything())

births_itl <- aggregate_to_region(births_lad,
                                  readRDS(fpath$lookup_lad_itl)) %>%
  arrange(gss_code, year_ending_date) %>%
  mutate(geography = "ITL221") %>%
  select(gss_code, gss_name, everything())

births_ctry <- aggregate_to_region(births_lad,
                                   readRDS(fpath$lookup_lad_ctry)) %>%
  arrange(gss_code, year_ending_date) %>%
  mutate(geography = "CTRY21") %>%
  select(gss_code, gss_name, everything())

saveRDS(births_rgn, fpath$rgn_output_rds)
saveRDS(births_itl, fpath$itl_output_rds)
saveRDS(births_ctry, fpath$ctry_output_rds)

write_csv(births_lad, fpath$lad_output_csv)
write_csv(births_rgn, fpath$rgn_output_csv)
write_csv(births_itl, fpath$itl_output_csv)
write_csv(births_ctry, fpath$ctry_output_csv)

### MONTHLY BIRTHS ###

births_lad_monthly <- readRDS(fpath$lad_monthly_output_rds)

# ugly adjustments to deal with combined gss codes in monthly births data
births_lad_monthly_no_combined <- births_lad_monthly %>%
  mutate(gss_code = substr(gss_code ,1, 9), # use only the first gss code in the combined areas for the aggregations
         gss_name = ifelse(gss_code == "E06000052","Cornwall", gss_name),
         gss_name = ifelse(gss_code == "E09000012", "Hackney", gss_name))

births_rgn_monthly <- aggregate_to_region(births_lad_monthly_no_combined,
                                  readRDS(fpath$lookup_lad_rgn)) %>%
  na.omit() %>%
  arrange(gss_code, month_ending_date) %>%
  mutate(geography = "RGN21") %>%
  select(gss_code, gss_name, everything())

births_itl_monthly <- aggregate_to_region(births_lad_monthly_no_combined,
                                  readRDS(fpath$lookup_lad_itl)) %>%
  arrange(gss_code, month_ending_date) %>%
  mutate(geography = "ITL221") %>%
  select(gss_code, gss_name, everything())

births_ctry_monthly <- aggregate_to_region(births_lad_monthly_no_combined,
                                   readRDS(fpath$lookup_lad_ctry)) %>%
  arrange(gss_code, month_ending_date) %>%
  mutate(geography = "CTRY21") %>%
  select(gss_code, gss_name, everything())

saveRDS(births_rgn_monthly, fpath$rgn_monthly_output_rds)
saveRDS(births_itl_monthly, fpath$itl_monthly_output_rds)
saveRDS(births_ctry_monthly, fpath$ctry_monthly_output_rds)

write_csv(births_lad_monthly, fpath$lad_monthly_output_csv)
write_csv(births_rgn_monthly, fpath$rgn_monthly_output_csv)
write_csv(births_itl_monthly, fpath$itl_monthly_output_csv)
write_csv(births_ctry_monthly, fpath$ctry_monthly_output_csv)

### YEARLY BIRTHS BY MONTH ###
births_lad_yearly_by_month <- births_lad_monthly %>%
  arrange(month_ending_date, gss_code, sex) %>%
  group_by(gss_code, sex) %>%
  mutate(roll_sum = roll_sum(value, 12, align = "right", fill = NA)) %>%
  select(-value, -month) %>%
  rename(year_ending_date = month_ending_date, value = roll_sum) %>%
  mutate(measure = "annual_births") %>%
  filter(!is.na(value))

# ugly adjustments to deal with combined gss codes in monthly births data
births_lad_yearly_by_month_no_combined <- births_lad_yearly_by_month %>%
  mutate(gss_code = substr(gss_code ,1, 9), # use only the first gss code in the combined areas for the aggregations
         gss_name = ifelse(gss_code == "E06000052","Cornwall", gss_name),
         gss_name = ifelse(gss_code == "E09000012", "Hackney", gss_name))

births_rgn_yearly_by_month <- aggregate_to_region(births_lad_yearly_by_month_no_combined,
                                          readRDS(fpath$lookup_lad_rgn)) %>%
  na.omit() %>%
  arrange(gss_code, year_ending_date) %>%
  mutate(geography = "RGN21") %>%
  select(gss_code, gss_name, everything())

births_itl_yearly_by_month <- aggregate_to_region(births_lad_yearly_by_month_no_combined,
                                          readRDS(fpath$lookup_lad_itl)) %>%
  arrange(gss_code, year_ending_date) %>%
  mutate(geography = "ITL221") %>%
  select(gss_code, gss_name, everything())

births_ctry_yearly_by_month <- aggregate_to_region(births_lad_yearly_by_month_no_combined,
                                           readRDS(fpath$lookup_lad_ctry)) %>%
  arrange(gss_code, year_ending_date) %>%
  mutate(geography = "CTRY21") %>%
  select(gss_code, gss_name, everything())

saveRDS(births_lad_yearly_by_month, fpath$lad_yearly_by_month_output_rds)
saveRDS(births_rgn_yearly_by_month, fpath$rgn_yearly_by_month_output_rds)
saveRDS(births_itl_yearly_by_month, fpath$itl_yearly_by_month_output_rds)
saveRDS(births_ctry_yearly_by_month, fpath$ctry_yearly_by_month_output_rds)

write_csv(births_lad_yearly_by_month, fpath$lad_yearly_by_month_output_csv)
write_csv(births_rgn_yearly_by_month, fpath$rgn_yearly_by_month_output_csv)
write_csv(births_itl_yearly_by_month, fpath$itl_yearly_by_month_output_csv)
write_csv(births_ctry_yearly_by_month, fpath$ctry_yearly_by_month_output_csv)
