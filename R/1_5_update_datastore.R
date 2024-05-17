
################################################################################
## WARNING: running this script will update the public facing datastore page. ##
## Have a human check the output data files before running this.              ##
################################################################################

# Project goal - to add the annual and monthly birth estimates data to the London
# Datastore using the London Datastore API

# N.B. A dataset called "Birth estimates" has already been set up on the London Datastore

# N.B. This requires you to have previously installed  ldndatar from Github using a Github auth token and saved your
# London Datastore API Key to your .Renviron file as an object called lds_api_key

# 1.0 Install and attach required packages ---------------------------------

# 1.1 Install and load required packages
# install.packages(c("tidyverse", "magrittr", "devtools", "rmarkdown"))
library(tidyverse)
library(magrittr)
library(devtools)
library(ldndatar)
library(rmarkdown)

# 1.2 Turn off scientific notation
options(scipen=999)

# 1.3 Set my_api_key for the London Datastore
my_api_key<-Sys.getenv("lds_api_key")

# 1.4 the slug is the name of the datastore page as given at the end of the page URL
page_slug<-"birth-estimates"

# Section 2 - Add resources to dataset -------------------------------------

# Create list of resources which need to be uploaded and their descriptions
datastore_resources_list<-
  list(births_lad = "data/processed/births_lad.csv",
       births_rgn = "data/processed/births_rgn.csv",
       births_ctry = "data/processed/births_ctry.csv",
       births_itl = "data/processed/births_itl.csv",
       births_monthly_lad = "data/processed/births_lad_monthly.csv",
       births_monthly_rgn = "data/processed/births_rgn_monthly.csv",
       births_monthly_ctry = "data/processed/births_ctry_monthly.csv",
       births_monthly_itl = "data/processed/births_itl_monthly.csv",
       births_yearly_by_month_lad = "data/processed/births_lad_rolling_12_month.csv",
       births_rgn_yearly_by_month = "data/processed/births_rgn_rolling_12_month.csv",
       births_ctry_yearly_by_month = "data/processed/births_itl_rolling_12_month.csv",
       births_itl_yearly_by_month = "data/processed/births_ctry_rolling_12_month.csv",
       births_lad_rds = "data/processed/births_lad.rds") %>%
  rev()


datastore_resources_descriptions<-
  list(births_lad = "Annual births for 2021 local authority districts in England and Wales by date of year ending",
       births_rgn = "Annual births for regions in England by date of year ending",
       births_ctry = "Annual births for the countries of England and Wales by date of year ending",
       births_itl = "Annual births for 2021 ITL 2 subregions in England and Wales by date of year ending",
       births_monthly_lad = "Monthly births for 2021 local authority districts in England by date of month ending. Hackney & City of London and Cornwall & Isles of Scilly are combined in this data",
       births_monthly_rgn = "Monthly births for regions in England by date of month ending",
       births_monthly_ctry = "Monthly births for the country of England by date of month ending",
       births_monthly_itl = "Monthly births for 2021 ITL 2 subregions in England by date of month ending",
       births_yearly_by_month_lad = "Rolling yearly aggregations of monthly births data for each month. Local authority districts in England by date of year ending. Hackney & City of London and Cornwall & Isles of Scilly are combined in this data",
       births_rgn_yearly_by_month = "Rolling yearly aggregations of monthly births data for each month. Regions in England by date of year ending",
       births_ctry_yearly_by_month = "Rolling yearly aggregations of monthly births data for each month. Country of England by date of year ending",
       births_itl_yearly_by_month = "Rolling yearly aggregations of monthly births data for each month. 2021 ITL 2 subregions in England by date of year ending",
       births_lad_rds = "Annual births for 2021 local authority districts in England and Wales by date of year ending. This file is saved in the RDS format native to the R programming language and is intended for use as an input to the process for modelling recent births: https://github.com/Greater-London-Authority/nowcast-birth-estimates") %>%
  rev()

# The following algorithm checks if there are any resources associated with this dataset, and uploads all the ones in
# datastore_resources_list if there aren't any.

# If there are already resources associated with the dataset which is being modified then where a new resource has
# the same name as an existing resource it will replace it. Otherwise the new resources will be added alongside those
# that are already there.

if (!"resource_id" %in% colnames(lds_meta_dataset(slug=page_slug, my_api_key))) {

  mapply(function(x, y) lds_add_resource(file_path = x,
                                         description = y,
                                         slug=page_slug,
                                         my_api_key),
         datastore_resources_list,
         datastore_resources_descriptions)

} else {

  datastore_resources_descriptions<-
    bind_rows(datastore_resources_descriptions) %>%
    gather(list_item, description)

  datastore_resources_list<-
    bind_rows(datastore_resources_list) %>%
    gather(list_item, filepath) %>%
    mutate(name = basename(filepath)) %>%
    left_join(datastore_resources_descriptions, by="list_item") %>%
    select(-list_item)

  current_resources_names<-
    select(as_tibble(lds_meta_dataset(slug=page_slug, my_api_key)),
           resource_title,
           resource_id)

  datastore_resources_list<-
    left_join(datastore_resources_list,
              current_resources_names, by=c("name"="resource_title"))

  for (i in 1:nrow(datastore_resources_list)) {

    if (is.na(datastore_resources_list$resource_id[i])) {

      lds_add_resource(
        file_path = datastore_resources_list$filepath[i],
        res_title = datastore_resources_list$name[i],
        description = datastore_resources_list$description[i],
        slug = page_slug,
        my_api_key
      )
    }

    else {

      lds_replace_resource(
        file_path=datastore_resources_list$filepath[i],
        slug=page_slug,
        res_id=datastore_resources_list$resource_id[i],
        res_title=datastore_resources_list$name[i],
        description = datastore_resources_list$description[i],
        api_key=my_api_key
      )
    }
  }
}

# Section 3 - Clear Environment -------------------------------------------

# 3.1
rm(list = ls())
