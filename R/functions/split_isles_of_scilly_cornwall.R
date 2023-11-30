library(dplyr)

split_isles_of_scilly_cornwall <- function(in_df, ios_births = 20, joint_code = "E06000052, E06000053"){

  cornwall_births <- in_df %>%
    filter(gss_code == joint_code) %>%
    mutate(gss_code = "E06000052",
           gss_name = "Cornwall",
           value = value - ios_births)

  scilly_births <- in_df %>%
    filter(gss_code == joint_code) %>%
    mutate(gss_code = "E06000053",
           gss_name = "Isles of Scilly",
           value = ios_births)

  out_df <- in_df %>%
    filter(gss_code != joint_code) %>%
    bind_rows(cornwall_births, scilly_births)

  return(out_df)
}
