
qa_monthly_births_output <- function(df) {

  combined_geogs <- readRDS("lookups/combined_la_codes_lookup.rds")
  single_codes <- unique(combined_geogs$gss_code)
  combined_geogs <- combined_geogs %>%
    select(gss_code = combined_gss, gss_name = combined_name) %>%
    unique()

  geogs <- readRDS("lookups/lookup_lsoa_lad.rds") %>%
    select(gss_code, gss_name) %>%
    unique() %>%
    filter(grepl("^E", gss_code) & !gss_code %in% single_codes) %>%
    bind_rows(combined_geogs)

  sex <- c("persons", "male", "female")
  start_date <- min(df$month_ending_date)
  end_date <- max(df$month_ending_date)

  expected_months <- seq(start_date, to = end_date, by="month")

  expected_rows_df <- expand_grid(sex, month_ending_date = expected_months, nesting(gss_code = geogs$gss_code, gss_name = geogs$gss_name)) %>%
    mutate(type = "expected") %>%
    arrange(gss_code, month_ending_date, sex)

  matched_df <- full_join(df, expected_rows_df, by = join_by(gss_code, gss_name, month_ending_date, sex))

  unmatched <- matched_df %>%
    filter(is.na(value) | is.na(type))

  if (nrow(unmatched) != 0) stop("The combinations of gss_code, gss_name, month_ending_date and sex aren't as expected in the cleaned data")
  if (nrow(df) != nrow(expected_rows_df)) stop("There aren't the right number of rows in the cleaned data")

  bare_df <- df %>%
    select(gss_code, gss_name, month_ending_date, sex) %>%
    arrange(gss_code, month_ending_date, sex)

  expected_rows_df <- expected_rows_df %>%
    select(gss_code, gss_name, month_ending_date, sex) %>%
    arrange(gss_code, month_ending_date, sex)

  if (!all.equal(bare_df, expected_rows_df)) stop("The combinations of gss_code, gss_name, month_ending_date and sex aren't as expected in the cleaned data")


}
