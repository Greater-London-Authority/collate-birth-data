### MODIFIED FROM POPMODULES PACKAGE IN GLA POPULATION PROJECTIONS MODEL ###

#' Re-code LA GSS Codes to a later geography
#'
#' Switches any gss codes to a later vintage
#'
#' Aggregates data where rows with the same gss code are present
#'
#' User must define the column containing the gss_code and the columns
#' which contain data. Data columns must be numeric or integer.
#'
#' @param df_in A data frame containing gss_codes and data.
#' @param col_geog A string. The column which contains gss codes (defaults to
#'   \code{gss_code}).
#' @param data_cols A string or character vector. The column(s) that contain the
#'   data to be aggregated. Defaults to last column of input dataframe.
#' @param fun Character Function to be applied in aggregating data. Either 'sum'
#'   or 'mean'. Default \code{'sum'}.
#' @param recode_to_year Numeric. Conform to geography in which year. Must be one of
#'   \code{2009,2012,2013,2018,2019,2020,2021} (2013 is census geography).
#' @param aggregate_data Logical. If set to true multiple instances of the same
#'   gss code will be aggregated using the function specified in \code{fun} parameter.
#'   Default to \code{TRUE}.
#' @param code_changes_path string. file path to the code changes database or NULL
#'  to use the hard-coded code changes database. Degault NULL.
#'
#' @return The input dataframe with gss codes changed and data aggregated
#'
#' @import dplyr
#' @import data.table
#' @importFrom dtplyr lazy_dt
#' @importFrom assertthat assert_that
#'
#' @export
#'

library(dplyr)
library(data.table)
library(dtplyr)
library(assertthat)

recode_gss_codes <- function(df_in,
                             col_geog="gss_code",
                             data_cols = "value",
                             fun = "sum",
                             recode_to_year,
                             aggregate_data = TRUE,
                             code_changes_path){

  #validate
  .validate_recode_gss_codes(df_in, col_geog, data_cols, fun)

  #prepare input dataframe
  df <- df_in %>%
    as.data.frame() %>%
    rename("gss_code" = !!col_geog)

  col_aggregation <- setdiff(names(df),data_cols)

  #prepare recoding
  recode_merges <- list()
  recode_name_changes <- list()


  code_changes <- readRDS(code_changes_path) %>%
    select(changed_to_code, changed_from_code, year, split, merge)

  #Possible recode years
  recode_years <- unique(code_changes$year)
  .validate_recode_year(recode_to_year, recode_years)

  code_changes <- .ignore_splits(code_changes)

  #for each year make the changes a named vector inside a list
  #the x=X is necessary because the vector must not be empty
  for(yr in recode_years){

    recode_merges[[yr]] <- filter(code_changes, year == yr,
                                  merge == TRUE)

    recode_merges[[yr]] <- c(setNames(as.character(recode_merges[[yr]]$changed_to_code),
                                      recode_merges[[yr]]$changed_from_code), "x"="X")


    recode_name_changes[[yr]] <- filter(code_changes, year == yr,
                                        merge == FALSE)

    recode_name_changes[[yr]] <- c(setNames(as.character(recode_name_changes[[yr]]$changed_to_code),
                                            recode_name_changes[[yr]]$changed_from_code), "x"="X")
  }

  recode_years <- recode_years[recode_years <= recode_to_year]

  #in a loop so that codes that are changed and then changed again are picked-up
  for(yr in recode_years){

    #name changes
    df <- df %>%
      mutate(gss_code = recode(gss_code, !!!recode_name_changes[[yr]]))

    #merges
    df <- df %>%
      mutate(gss_code = recode(gss_code, !!!recode_merges[[yr]]))

    if(aggregate_data){

      if(fun == "sum"){
        df <- df %>%
          lazy_dt() %>%
          group_by(across(!!col_aggregation)) %>%
          summarise_all(.funs = sum) %>%
          as.data.frame()
      }

      if(fun == "mean"){
        df <- df %>%
          lazy_dt() %>%
          group_by(across(!!col_aggregation)) %>%
          summarise_all(.funs = mean) %>%
          as.data.frame()
      }

    }
  }

  df <- as.data.frame(df) %>%
    rename(!!col_geog := "gss_code")

  return(df)

}



.ignore_splits <- function(x){

  #### Splits
  #there have thus far been 2 splits, both in 2013
  #both were minor alterations to boundaries
  #northumberland = 1 bungalow
  #east hertfordshire = part of a row of houses
  #both can effectively be treated as code changes with no tranfser of
  #population.
  #Therefore ignore E08000020 to E06000057
  #and ignore E07000097 to E06000243

  x %>%
    filter(!(changed_from_code == "E08000020" & changed_to_code == "E06000057")) %>%
    filter(!(changed_from_code == "E07000097" & changed_to_code == "E07000243"))

}

.validate_recode_gss_codes <- function(df_in, col_geog, data_cols, fun){

  assertthat::assert_that(fun %in% c("sum","mean"),
                          msg = "in recode_gss_codes, fun must be sum or mean")

  for(i in length(data_cols)){
    assertthat::assert_that(data_cols[i] %in% names(df_in),
                            msg = paste("in recode_gss_codes, specified data_col", data_cols[i],
                                        "not in input dataframe"))
  }

  assertthat::assert_that(col_geog %in% names(df_in),
                          msg = paste("in recode_gss_codes, specified col_geog", col_geog,
                                      "not in input dataframe"))

  invisible()
}

.validate_recode_year <- function(recode_to_year, recode_years) {
  assertthat::assert_that(recode_to_year >= min(recode_years & recode_to_year <= max(recode_years)),
                          msg=paste("in recode_gss_codes, recode_to_year must be within the range of",
                                    recode_years))
  invisible()
}

