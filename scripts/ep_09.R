# episode 9
# more about CRS

# when vectors don't line up

# clean the environment and hidden objects
rm(list=ls())

current_episode <- 9

library(sf)
library(dplyr)
library(ggplot2)

# we have populated places and streams to work with
# I don't pipe through st_zm here. 

places <- st_read("source_data/tl_2023_06_place/tl_2023_06_place.shp")
streams <- st_read("source_data/california_streams/California_Streams.shp")
streams <- st_read("source_data/california_streams/streams_crop.shp")
coast <- st_read("source_data/pacific_ocean-shapefile/3853-s3_2002_s3_reg_pacific_ocean_lines.shp")


# these are all different
st_crs(places)
st_crs(streams)
st_crs(coast)

ggplot() +
  geom_sf(data = places) +
  ggtitle("Map 9.1: Cali Places") +
  coord_sf()

# start by putting the coast and streams in the same CRS
streams <- st_transform(streams, st_crs(coast))

# now they should overlay:
ggplot() +
  geom_sf(data = streams, color = "blue") +
  geom_sf(data = coast, color = "black",alpha = 0.25,size = 5) +
  ggtitle("Map 9.2: Streams and Coast") +
  coord_sf()
