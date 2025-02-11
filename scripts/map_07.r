# map 7
# an alternate to map 1
# for the bottom of the page on map 3


library(terra)
library(tidyverse)
library(raster)
library(terra)
library(sf)
# library(rgdal)

# clean the environment and hidden objects
rm(list=ls())

current_sheet <- 7


#vector layers
buildings <- st_read("source_data/campus_buildings/Campus_Buildings.shp")
bikeways <- st_read("source_data/icm_bikes/bike_paths/bikelanescollapsedv8.shp")
habitat <- st_read("source_data/NCOS_Shorebird_Foraging_Habitat/NCOS_Shorebird_Foraging_Habitat.shp")
iv_buildings <- st_read("source_data/iv_buildings/iv_buildings/CA_Structures_ExportFeatures.shp")

# rasters
# the background setup is bathymetry and topography mashed together

campus_DEM <- rast("source_data/campus_DEM.tif") 
campus_bath <- rast("output_data/ep_3_campus_bathymetry_crop.tif")
campus_hillshade <- rast("source_data/campus_hillshade.tif")

# We'll need some bins
# best coast line bins from ep 2
# based on experimentation:
custom_bins <- c(-3, 4.9, 5, 7.5, 10, 25, 40, 70, 100, 150, 200)

# we will use the original projection of
#    campus_DEM
campus_projection <- crs(campus_DEM)
campus_bath <- project(campus_bath, campus_projection)
campus_hillshade <- project(campus_hillshade, campus_projection)
buildings <- st_transform(buildings, campus_projection)
bikeways <- st_transform(bikeways, campus_projection)
habitat <- st_transform(habitat, campus_projection)

crs(buildings)

# make dataframes
campus_DEM_df <- as.data.frame(campus_DEM, xy=TRUE) %>%
  rename(elevation = greatercampusDEM_1_1) # rename to match code later

campus_bath_df <- as.data.frame(campus_bath, xy=TRUE) %>%
  rename(bathymetry = SB_bath_2m)

campus_hillshade_df <- as.data.frame(campus_hillshade, xy=TRUE)

# to make our scales make sense, we do 
# raster math 
# how would I do this with overlay?
sea_level <- campus_DEM - 5

# Set values below or equal to 0 to NA
sea_level_0 <- app(sea_level, function(x) ifelse(x <=0, NA, x))
# Note: this remove some values in the marsh that are below 0
# we are going to want those back later as our 'vernal pools'


# test vector overlays
ggplot() +
  geom_sf(data=habitat) +
  geom_sf(data=buildings) +
  geom_sf(data=iv_buildings) +
  geom_sf(data=bikeways) +
  coord_sf()




############################
str(campus_hillshade_df)

# this is mostly map 1 so far

ggplot() +
  geom_raster(data = campus_DEM_df, aes(x=x, y=y, fill = elevation)) +
  geom_sf(data=buildings, color ="hotpink") +
  geom_sf(data=bikeways, color="yellow") +
  geom_raster(data = campus_hillshade_df, aes(x=x, y=y, alpha = hillshade), show.legend = FALSE) +
  geom_sf(data=habitat, color="darkorchid1") +
  geom_raster(data = campus_bath_df, aes(x=x, y=y, fill = bathymetry)) +
  scale_fill_viridis_c(na.value="NA") +
  labs(title="Map 7", subtitle="Version 1") +
  coord_sf()

ggsave("images/map7.0.png", plot=last_plot())
object_test_abb <- ls()
