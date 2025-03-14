# An episode ep_weather
# to be plugged in post-intermediate R

# Sigrid is going to walk us towards weather stations.

library(tidyverse)
library(tictoc)

download.file (
  url = "https://www.ncei.noaa.gov/data/ghcnm/v4/precipitation/doc/ghcn-m_v4_prcp_inventory.txt",
  destfile = "downloaded_data/rain.txt"
)

station_inventory <- read_fwf(
  file = "downloaded_data/rain.txt") 

colnames(station_inventory) <- c("stationId", "lat", "long", "elevation", "state", "stationName", "wmold", "firstYear", "lastYear")
str(station_inventory)

# add a column
station_inventory$country=""

# time our code
tic()
for (i in 1:nrow(station_inventory)) {
 station_inventory[i,"country"] = substring(station_inventory[i,"stationId"],1,2) 
}
toc()

# I would think there's a tidy solution
station_inventory$countryTidy=""
cbind(station_inventory, substring(station_inventory$countryTidy, 1,2))
station_inventory
