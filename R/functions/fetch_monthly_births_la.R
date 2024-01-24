fetch_monthly_births_la <- function(dir_save, url_lookup) {

  monthly_births_urls <- read.csv(url_lookup, stringsAsFactors = FALSE)

  urls <- monthly_births_urls$url
  exts <- gsub(".*\\.", "\\.", basename(urls))
  fps_save <- paste0(dir_save,"/",monthly_births_urls$gla_filename, exts)

  mapply(function(url, fp_save) download.file(url = url,
                destfile = fp_save,
                mode="wb"), urls, fps_save)

}
