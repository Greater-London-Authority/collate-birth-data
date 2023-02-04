
<!-- README.md is generated from README.Rmd. Please edit that file -->

# collate birth data

<!-- badges: start -->
<!-- badges: end -->

This repository is intended to host a scripts and functions to download
and process various birth datasets published by the Office for National
Statistics.

The repository initially contains code for pulling together data from
three separately published sources to create a time series of annual
births on current geographies. Outputs from this process are published
on the [London
Datastore](https://data.london.gov.uk/dataset/annual-birth-series). The
sources drawn from are:

1.  [ONS mid-year population estimates components of
    change](https://www.ons.gov.uk/peoplepopulationandcommunity/populationandmigration/populationestimates/datasets/populationestimatesforukenglandandwalesscotlandandnorthernireland) -
    local authority births for mid-year periods from 2001-2 onward

2.  [Births and deaths by Lower Super Output Area (LSOA), England and
    Wales, 1991 to 1992 to 2016 to
    2017](https://www.ons.gov.uk/peoplepopulationandcommunity/birthsdeathsandmarriages/deaths/adhocs/009628birthsanddeathsbylowersuperoutputarealsoaenglandandwales1991to1992to2016to2017) -
    ad hoc release of births by (2011) LSOA for mid-year periods from
    1991-2 to 2016-17

3.  [Live births in England and Wales for small geographic
    areas](https://www.nomisweb.co.uk/query/construct/summary.asp?mode=construct&version=0&dataset=206) -
    births by (2011) LSOA for calendar year period from 2013 onward.

While calendar year births data for local authorities is available for
local earlier periods from the [ONS
website](https://www.ons.gov.uk/peoplepopulationandcommunity/birthsdeathsandmarriages/livebirths/datasets/birthsummarytables),
this data has not yet been included here due to the complications caused
by:

1.  the lack of geography codes accompanying the data for the years of
    interest

2.  the decision to combine data for Hackney and City of London, and
    Cornwall and the Isles of Scilly

3.  inconsistent formatting of the published tables

## Usage

Individual scripts for: downloading, cleaning, combining, and producing
consolidated output files - can be run individually in order or together
from

    1__run_all__collate_births_lad_persons.R

Outputs are saved in

    data/processed/

## To do

#### Add process to consolidate published data on births by LSOA into consistent timeseries for common geographies.

Several overlapping data sets have been published at this geographic
level:

1.  [Births by Lower layer Super Output Area (LSOA), England and Wales:
    mid-year periods (1 July to 30 June) 2011 to
    2020](https://www.ons.gov.uk/peoplepopulationandcommunity/birthsdeathsandmarriages/livebirths/adhocs/14318birthsbylowerlayersuperoutputarealsoaenglandandwalesmidyearperiods1julyto30june2011to2020) -
    mid-year periods, includes breakdown by broad age of mother

2.  [Births by Lower Layer Super Output Area (LSOA), England and Wales,
    mid-year 2001 to
    2019](https://www.ons.gov.uk/peoplepopulationandcommunity/birthsdeathsandmarriages/livebirths/adhocs/12627birthsbylowerlayersuperoutputarealsoaenglandandwalesmidyear2001to2019) -
    mid-year periods, includes breakdown by broad age of mother

3.  [Births and deaths by Lower Super Output Area (LSOA), England and
    Wales, 1991 to 1992 to 2016 to
    2017](https://www.ons.gov.uk/peoplepopulationandcommunity/birthsdeathsandmarriages/deaths/adhocs/009628birthsanddeathsbylowersuperoutputarealsoaenglandandwales1991to1992to2016to2017) -
    mid-year periods

4.  [Live births in England and Wales for small geographic
    areas](https://www.nomisweb.co.uk/query/construct/summary.asp?mode=construct&version=0&dataset=206) -
    calendar year periods

#### Add process to create consolidated series of births by month for local authorities

Data for individual years has been published since 2014-15.

1.  [Live births by month, sex and area of usual residence of Mother,
    England and Wales, September 2014 to August 2015,
    final](https://www.ons.gov.uk/peoplepopulationandcommunity/birthsdeathsandmarriages/livebirths/adhocs/006871livebirthsbymonthsexandareaofusualresidenceofmotherenglandandwalesseptember2014toaugust2015)

2.  [Live births by month, sex and area of usual residence of mother,
    England and Wales, September 2015 to August 2016,
    final](https://www.ons.gov.uk/peoplepopulationandcommunity/birthsdeathsandmarriages/livebirths/adhocs/008449livebirthsbymonthsexandareaofusualresidenceofmotherenglandandwalesseptember2015toaugust2016)

3.  [Live births by month, sex and area of usual residence of mother,
    England and Wales, September 2016 to August 2017,
    final](https://www.ons.gov.uk/peoplepopulationandcommunity/birthsdeathsandmarriages/livebirths/adhocs/009923livebirthsbymonthsexandareaofusualresidenceofmotherenglandandwalesseptember2016toaugust2017final)

4.  [Live births by month, sex and area of usual residence of mother,
    England and Wales, September 2017 to August
    2018](https://www.ons.gov.uk/peoplepopulationandcommunity/birthsdeathsandmarriages/livebirths/adhocs/11467livebirthsbymonthsexandareaofusualresidenceofmotherenglandandwalesseptember2017toaugust2018)

5.  [Live births by month, sex and area of usual residence of mother,
    England and Wales: September 2018 to August
    2019](https://www.ons.gov.uk/peoplepopulationandcommunity/birthsdeathsandmarriages/livebirths/adhocs/13050livebirthsbymonthsexandareaofusualresidenceofmotherenglandandwalesseptember2018toaugust2019)

6.  [Live births by month, sex and area of usual residence of mother,
    England and Wales: September 2019 to August
    2020](https://www.ons.gov.uk/peoplepopulationandcommunity/birthsdeathsandmarriages/livebirths/adhocs/14756livebirthsbymonthsexandareaofusualresidenceofmotherenglandandwalesseptember2019toaugust2020)
