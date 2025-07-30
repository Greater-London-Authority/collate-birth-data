library(dplyr)

aggregate_lsoa_to_lad <- function(fp_lsoa, lookup_lsoa_lad, geog_name = "LAD21") {

  lad_births <- readRDS(fp_lsoa) %>%
    left_join(lookup_lsoa_lad, by = "LSOA_CODE") %>%
    group_by(across(-any_of(c("value", "LSOA_CODE")))) %>%
    summarise(value = sum(value), .groups = "drop") %>%
    mutate(geography = geog_name)

  return(lad_births)
}
