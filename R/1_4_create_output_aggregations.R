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

              lookup_lad_rgn = "lookups/lookup_lad_rgn.rds",
              lookup_lad_itl = "lookups/lookup_lad_itl.rds",
              lookup_lad_ctry = "lookups/lookup_lad_ctry.rds")

births_lad <- readRDS(fpath$lad_output_rds)

births_rgn <- aggregate_to_region(births_lad,
                                  readRDS(fpath$lookup_lad_rgn)) %>%
  na.omit() %>%
  arrange(gss_code, year_ending_date) %>%
  mutate(geography = "RGN23") %>%
  select(gss_code, gss_name, everything())

births_itl <- aggregate_to_region(births_lad,
                                  readRDS(fpath$lookup_lad_itl)) %>%
  arrange(gss_code, year_ending_date) %>%
  mutate(geography = "ITL221") %>%
  select(gss_code, gss_name, everything())

births_ctry <- aggregate_to_region(births_lad,
                                   readRDS(fpath$lookup_lad_ctry)) %>%
  arrange(gss_code, year_ending_date) %>%
  mutate(geography = "CTRY23") %>%
  select(gss_code, gss_name, everything())

saveRDS(births_rgn, fpath$rgn_output_rds)
saveRDS(births_itl, fpath$itl_output_rds)
saveRDS(births_ctry, fpath$ctry_output_rds)

write_csv(births_lad, fpath$lad_output_csv)
write_csv(births_rgn, fpath$rgn_output_csv)
write_csv(births_itl, fpath$itl_output_csv)
write_csv(births_ctry, fpath$ctry_output_csv)

