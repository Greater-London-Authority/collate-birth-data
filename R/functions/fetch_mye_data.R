
fetch_mye_data <- function(url_raw,
                           fpath_raw) {

  if(!dir.exists("data/raw/")) dir.create("data/raw/", recursive = TRUE)

  download.file(url = url_raw,
                destfile = fpath_raw,
                mode = "wb")

}
