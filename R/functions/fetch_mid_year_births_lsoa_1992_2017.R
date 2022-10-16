fetch_mid_year_births_lsoa_1992_2017 <- function(
    fp_save,
    url_zip = "https://www.ons.gov.uk/file?uri=/peoplepopulationandcommunity/birthsdeathsandmarriages/deaths/adhocs/009628birthsanddeathsbylowersuperoutputarealsoaenglandandwales1991to1992to2016to2017/lsoabirthsdeaths19912017final.zip"
    ) {

  dir_save <- paste0(dirname(fp_save), "/")

  fp_zip <- paste0(dir_save, basename(url_zip))

  download.file(url = url_zip,
                destfile = fp_zip)

  unzip(fp_zip,
        files = "Table_1_Births.xlsx",
        exdir = paste0(dir_save, "."))

  file.rename(from = paste0(dir_save, "Table_1_Births.xlsx"),
              to = fp_save)

  file.remove(fp_zip)
}
