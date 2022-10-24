
<!-- README.md is generated from README.Rmd. Please edit that file -->

# collate birth data

<!-- badges: start -->
<!-- badges: end -->

This repository is intended to host a range of scripts and functions to
download and process various birth datasets published by the Office for
National Statistics.

The repository initially contains code for pulling together data from
three separately published sources, to create a time series of annual
births on 2021 geographies. These sources are:

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

# Usage

Individual scripts for: downloading, cleaning, combining, and producing
consolidated output files - can be run individually in order or together
from

    1__collate_births_lad_persons.R

Outputs are saved in

    data/processed/
