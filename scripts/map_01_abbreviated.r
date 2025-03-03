# map 1
# Wide overview of campus

# this version does just what it needs to
# ie: it is an extra short version spawned from
# map1.r

# clean the environment and hidden objects
rm(list=ls())

sheet <- "map_01_abbreviated.r"
map_title <- "Map 1: Wide Overview of Campus"
map_counter <- 1 


library(tidyverse)
library(raster)
# library(rgdal)
library(terra)
library(sf)

# set up objects

#vector layers
buildings <- st_read("source_data/campus_buildings/Campus_Buildings.shp")
bikeways <- st_read("source_data/icm_bikes/bike_paths/bikelanescollapsedv8.shp")
habitat <- st_read("source_data/NCOS_Shorebird_Foraging_Habitat/NCOS_Shorebird_Foraging_Habitat.shp")
# walkways <-         # do we still want walkways later on?


# overlays as in episode 8

ggplot() +
  geom_sf(data=habitat, color="yellow") +
  geom_sf(data=buildings) +
  geom_sf(data=bikeways, color="blue") +
  ggtitle(map_title, subtitle = map_counter) +
  coord_sf()

ggsave("images/map1a.1.png", plot=last_plot())


# rasters
# the background setup is bathymetry and topography
# mashed together

campus_DEM <- rast("source_data/campus_DEM.tif") 
bath <- rast("source_data/SB_bath.tif") 

# We'll need some bins
# best coast line bins from ep 2
# based on experimentation:
custom_bins <- c(-3, 4.9, 5, 7.5, 10, 25, 40, 70, 100, 150, 200)

# we will use the original projection of
# campus_DEM
campus_projection <- crs(campus_DEM)
bath <- project(bath, campus_projection)

# load campus_bathymetry raster from output folder
# remember: this is the one we cropped, so the 2 extents are the same.
# not sure exactlty where this gets made
campus_bath <- rast("source_data/SB_bath.tif")

# make dataframes
campus_DEM_df <- as.data.frame(campus_DEM, xy=TRUE) %>%
  rename(elevation = greatercampusDEM_1_1) # rename to match code later

summary(campus_bath)

campus_bath_df <- as.data.frame(campus_bath, xy=TRUE) %>%
  rename(bathymetry = Bathymetry_2m_OffshoreCoalOilPoint)

# to make our scales make sense, we do 
# raster math 
# how would I do this with overlay?
sea_level <- campus_DEM - 5

# Set values below or equal to 0 to NA
sea_level_0 <- app(sea_level, function(x) ifelse(x <=0, NA, x))
# Note: this remove some values in the marsh that are below 0
# we are going to want those back later as our 'vernal pools'


# Make it a data frame and bin it
sea_level_df <- as.data.frame(sea_level_0, xy=TRUE) %>% 
  rename(elevation = lyr.1) %>%
  mutate(binned = cut(elevation, breaks=custom_bins))

ggplot() + 
  geom_raster(data = sea_level_df, aes(x=x, y=y, fill = binned)) + 
  labs(title="Map 0.2", subtitle="Sea Level ~= 0") +
  ggtitle(map_title, subtitle = (map_counter+1)) +
  coord_sf() 

# to keep map's proportions

custom_sea_bins <- c(-8, -.1, .1, 3, 5, 7.5, 10, 25, 40, 70, 100, 150, 200)

sea_level_df <- sea_level_df %>% 
  mutate(binned = cut(elevation, breaks=custom_sea_bins))

length(custom_sea_bins)

# binned zero sea level 
subtitle <- c((map_counter+1), "Map 0.3: Binned Zero Sea Level")
ggplot() + 
  geom_raster(data = sea_level_df, aes(x=x, y=y, fill = binned)) +
  ggtitle(map_title, subtitle = subtitle) +
  coord_sf()

# add custom bins to each.
# these were based on experimentation
custom_DEM_bins <- c(-3, -.01, .01, 2, 3, 4, 5, 10, 40, 200)
campus_DEM_df <- campus_DEM_df %>% 
  mutate(binned_DEM = cut(elevation, breaks = custom_DEM_bins))

custom_bath_bins <- c(1, -5, -15, -35, -45, -55, -60, -65, -75, -100, -125)
campus_bath_df <- campus_bath_df %>% 
  mutate(binned_bath = cut(bathymetry, breaks =custom_bath_bins))

str(campus_bath_df)
str(campus_DEM_df)

# overlay the Zero-sea-level rasters
# not sure why 16. Shouldn't it be 19? 
# it demands at least 16
# putting in more makes the scale 
# more green
# Not sure how it gets on both layers

# binned
ggplot() +
    geom_raster(data = campus_DEM_df, aes(x=x, y=y, fill = binned_DEM)) +
    geom_raster(data = campus_bath_df, aes(x=x, y=y, fill = binned_bath)) +
    scale_fill_manual(values = terrain.colors(19)) +
  labs(title="Map 1", subtitle="Version 2: Binned") +
        coord_quickmap()
  
# continuous
ggplot() +
  geom_raster(data = campus_DEM_df, aes(x=x, y=y, fill = elevation)) +
  geom_raster(data = campus_bath_df, aes(x=x, y=y, fill = bathymetry)) +
        scale_fill_viridis_c(na.value="NA") +
  labs(title="Map 1", subtitle="Version 2: Continuous") 
  

# bring back the hillshade from ep1-2
campus_hillshade_df <- 
  rast("source_data/campus_hillshade.tif") %>% 
  as.data.frame(xy = TRUE) %>% 
  rename(campus_hillshade = hillshade) # rename to match code later

# overlay the vectors
# reproject the vectors
buildings <- st_transform(buildings, campus_projection)
habitat <- st_transform(habitat, campus_projection)
bikeways <- st_transform(bikeways, campus_projection)

#update color scheme for contrast 
# +hillshade
ggplot() +
  geom_raster(data = campus_DEM_df, aes(x=x, y=y, fill = elevation)) +
  geom_raster(data = campus_hillshade_df, aes(x=x, y=y, alpha = campus_hillshade), show.legend = FALSE) +
  geom_raster(data = campus_bath_df, aes(x=x, y=y, fill = bathymetry)) +
  scale_fill_viridis_c(na.value="NA") +
  geom_sf(data=buildings, color ="hotpink") +
  geom_sf(data=habitat, color="darkorchid1") +
  geom_sf(data=bikeways, color="yellow") +
  labs(title="Map 1", subtitle="Version 3") +
  coord_sf()

# ggsave("images/map1.3.png", plot=last_plot())
object_test_abb <- ls()
