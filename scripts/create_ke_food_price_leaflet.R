# I. Packages
# --------------------------------
library(tidyverse)
# for sf data
library(sf)
# for tmap
library(tmap)
library(RPostgres)
# for storing passwords!
library(keyring)

# II. Data Ingest
# --------------------------------

# could easily be made a function
con <-DBI::dbConnect(
  # better maintained than RPostgreSQL
  drv = RPostgres::Postgres(),
  # could also use system environment vars but this is a little more secure
  dbname = key_get("db_name", keyring = "stc"),
  host = key_get("db_host", keyring = "stc"),
  port = 5432,
  user = key_get("db_user", keyring = "stc"),
  password = key_get("db_pass", keyring = "stc")
)

# seems to have solid spatial data by regions
food_prices <- con %>%
  tbl(dbplyr::in_schema("public", "view_wfp_food_prices_ken_som_csv")) %>%
  collect() 

ke_sf <- sf::read_sf("data/ke_admin1.gpkg")

# III. Data Processing
# --------------------------------

food_prices_ke <- food_prices %>%
  filter(
    index > 0,
    country == "Kenya",
    commodity == "Beans (dry)"
  ) %>%
  transmute(
    country,
    date,
    # I think these are actually admin 1 values?
    # or at least they line up with names in admin1 maps but NOT admin2 maps
    # TODO: dig into this more
    admin1 = admin2,
    latitude,
    longitude,
    category,
    commodity,
    market,
    usdprice = as.numeric(usdprice),
    price = as.numeric(price),
    unit,
    year = str_extract(date, "[0-9]{4}") %>% as.numeric()
  ) %>%
  # seemed to be big price jump in 2020 from prior analysis
  # I think this help us balance availability of data with price changes
  # BUUUT I would recommend playing around with this. I am running out of time
  filter(
    year > 2020,
    # seems to represent missing data?
    price != 0
    )

# good
table(food_prices_ke$unit)
# not good. only 8 regions oof
table(food_prices_ke$admin1)

# now let's group this so we can map it as a layer by admin1
food_prices_grpd <- food_prices_ke %>%
  group_by(admin1) %>%
  summarize(
    `Average Price of Dry Beans Per KG in USD (2021-2022)` = mean(usdprice),
    Observations = n(),
    `Last Recorded` = max(date)
    )

food_prices_pt <- food_prices_ke %>%
  st_as_sf(coords = c("longitude", "latitude"))

ke_sf <- left_join(ke_sf, food_prices_grpd)

# IV. Leaflets
# --------------------------------

# Chloropleth Attempt
# This is not helpful given data availability
# But it could be repurposed for other Chlorpleth leaflets where we have more data grouped by sensible shapes

# test_map <- tmap::tm_shape(ke_sf) +
#   tm_polygons(
#     "Average Price of Dry Beans Per KG in USD (2021-2022)",
#     id = "admin1",
#     palette = rev(viridis::magma(4)),
#     breaks = c(0, 0.95, 1.05, 1.5),
#     popup.vars =
#       c(
#         "admin1",
#         "Average Price of Dry Beans Per KG in USD (2021-2022)",
#         "Observations",
#         "Last Observed"
#       )
#   ) +
#   tmap_options(basemaps = c("Esri.WorldGrayCanvas"))
# 
# tmap_save(test_map, filename = "leaflets/ke_bean_price_20212022.html")

# Dot plot

test_map <- tm_shape(ke_sf) +
  tm_polygons(
    id = "admin1",
    popup.vars =
      c(
        "Region" = "admin1",
        "Average Price of Dry Beans Per KG in USD (2021-2022)",
        "Observations",
        "Last Recorded"
      ),
    alpha = 0.5
  ) +
  tm_shape(food_prices_pt) +
  tm_dots(
    "usdprice",
    id = "admin1",
    palette = rev(viridis::magma(5)),
    popup.vars =
      c(
        "Region" = "admin1",
        "Market" = "market",
        "Date" = "date",
        "Price of Dry Beans Per KG in USD" = "usdprice"
      ),
    alpha = 0.75,
    breaks = c(0, 0.75, 1, 1.25, 2)
  ) +
  tmap_options(basemaps = c("OpenStreetMap.HOT", "Esri.WorldGrayCanvas"))
  

# hmm a start
tmap_save(test_map, filename = "leaflets/ke_bean_price.html")
