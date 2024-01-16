fetch_mid_year_births_lsoa_1992_2017 <- function(
    dir_save = "data/raw/monthly_births/",
) {


  urls <- list(
    sept14_aug15 = "https://www.ons.gov.uk/file?uri=/peoplepopulationandcommunity/birthsdeathsandmarriages/livebirths/adhocs/006871livebirthsbymonthsexandareaofusualresidenceofmotherenglandandwalesseptember2014toaugust2015/livebirthsbymonthsexandladsept2014toaug2015ew.xls",
    sept15_aug16 = "https://www.ons.gov.uk/file?uri=/peoplepopulationandcommunity/birthsdeathsandmarriages/livebirths/adhocs/008449livebirthsbymonthsexandareaofusualresidenceofmotherenglandandwalesseptember2015toaugust2016/livebirthsbymonthsexandladsept2015toaug2016ew.xls",
    sept16_aug17 = "https://www.ons.gov.uk/file?uri=/peoplepopulationandcommunity/birthsdeathsandmarriages/livebirths/adhocs/009923livebirthsbymonthsexandareaofusualresidenceofmotherenglandandwalesseptember2016toaugust2017final/livebirthsbymonthsexandladsept2016toaug2017ew.xls",
    sept17_aug18 = "https://www.ons.gov.uk/file?uri=/peoplepopulationandcommunity/birthsdeathsandmarriages/livebirths/adhocs/11467livebirthsbymonthsexandareaofusualresidenceofmotherenglandandwalesseptember2017toaugust2018/livebirthsbymonthsexandladsept2017toaug2018.xls",
    sept18_aug19 = "https://www.ons.gov.uk/file?uri=/peoplepopulationandcommunity/birthsdeathsandmarriages/livebirths/adhocs/13050livebirthsbymonthsexandareaofusualresidenceofmotherenglandandwalesseptember2018toaugust2019/livebirthsbymonthsexandladsept2018toaug2019.xlsx",
    sept19_aug20 = "https://www.ons.gov.uk/file?uri=/peoplepopulationandcommunity/birthsdeathsandmarriages/livebirths/adhocs/14756livebirthsbymonthsexandareaofusualresidenceofmotherenglandandwalesseptember2019toaugust2020/copyoflivebirthsbymonthsexandladsept2019toaug2020.xlsx",
    sept20_aug21 = "https://www.ons.gov.uk/file?uri=/peoplepopulationandcommunity/birthsdeathsandmarriages/livebirths/adhocs/1077livebirthsbymonthsexandareaofusualresidenceofmotherenglandandwalesseptember2020toaugust2021/livebirthsbymonthsexandladsept2020toaug2021final.xlsx"
    )

  if (!dir.exists(dir_save)) {dir.create(dir_save)}

  fps <- lapply(urls, function(x){paste0(dir_save, basename(x))})

  for (i in seq_along(urls)) {

    download.file(urls[[i]],
                  destfile = fps[[i]])
  }



# file.rename(from = paste0(dir_save, "Table_1_Births.xlsx"),
#              to = fp_save)

}
