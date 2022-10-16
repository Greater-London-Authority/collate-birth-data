fetch_mye_births <- function(
    fp_save,
    url_zip = "https://www.ons.gov.uk/file?uri=/peoplepopulationandcommunity/populationandmigration/populationestimates/datasets/populationestimatesforukenglandandwalesscotlandandnorthernireland/mid2001tomid2020detailedtimeseries/ukdetailedtimeseries2001to2020.zip"
) {

  dir_save <- paste0(dirname(fp_save), "/")

  fp_zip <- paste0(dir_save, basename(url_zip))

  download.file(url = url_zip,
                destfile = fp_zip)

  unzip(fp_zip,
        files = "MYEB2_detailed_components_of_change_series_EW_(2020_geog21).csv",
        exdir = paste0(dir_save, "."))

  file.rename(from = paste0(dir_save, "MYEB2_detailed_components_of_change_series_EW_(2020_geog21).csv"),
              to = fp_save)

  file.remove(fp_zip)
}
