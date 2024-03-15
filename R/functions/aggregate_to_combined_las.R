aggregate_to_combined_las <- function(df) {
  # geog cols must be named 'gss_code' and/or 'gss_name'
  # value column must be named 'value'

  lookup <- readRDS("lookups/combined_la_codes_lookup.rds")

  aggregated <- df %>%
    left_join(lookup) %>%
    mutate(combined_gss = ifelse("gss_code" %in% names(df) & is.na(combined_gss), gss_code, combined_gss),
           combined_name = ifelse("gss_name" %in% names(df) & is.na(combined_name), gss_name, combined_name)) %>%
    select(-any_of(c("gss_code", "gss_name"))) %>%
    rename(gss_code = combined_gss, gss_name = combined_name) %>%
    select(all_of(names(df))) %>%
    group_by(across(c(-value))) %>%
    summarise(value = sum(value)) %>%
    ungroup()

  return(aggregated)

}
