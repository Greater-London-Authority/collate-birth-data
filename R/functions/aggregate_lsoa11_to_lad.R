library(dplyr)

aggregate_lsoa11_to_lad <- function(fp_lsoa, fp_save, lookup_lsoa_lad) {

  lad_births <- readRDS(fp_lsoa) %>%
    left_join(lookup_lsoa_lad, by = "LSOA11CD") %>%
    group_by(across(-any_of(c("value", "LSOA11CD")))) %>%
    summarise(value = sum(value), .groups = "drop") %>%
    mutate(geography = "LAD21")

  saveRDS(lad_births, fp_save)
}
