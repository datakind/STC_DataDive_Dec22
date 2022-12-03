# I. Packages
# --------------------------------
library(tidyverse)
# for spatial data
library(sf)
# for quickly viewing map
library(mapview)
mapview::mapviewOptions(fgb = FALSE)


# II. Data Processing
# --------------------------------
# Not going to store this all on github
# This script will clean it and save a smaller/more useful version
# Source can be found at:
# https://data.humdata.org/dataset/cod-ab-ken
ke_admin1 <- sf::read_sf("~/Downloads/ken_adm_iebc_20191031_shp/ken_admbnda_adm1_iebc_20191031.shp") %>%
  transmute(
    country = ADM0_EN,
    admin1 = ADM1_EN,
    admin1_code = ADM1_PCODE,
    valid_on = validOn
  )
# looks good
mapview::mapview(ke_admin1)

sf::write_sf(ke_admin1, "data/ke_admin1.gpkg")
