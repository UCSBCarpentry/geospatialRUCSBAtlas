# map 1
# Wide overview of campus

# clean the environment and hidden objects
rm(list=ls())

library(tidyverse)
library(raster)
# library(rgdal)
library(terra)
library(sf)

# set up objects

#vector layers
buildings <- st_read("source_data/campus_buildings/Campus_Buildings.shp")
# walkways <- 
bikeways <- st_read("source_data/bike_paths/bikelanescollapsedv8.shp")
habitat <- st_read("source_data/NCOS_bird_observations/NCOS_Shorebird_Foraging_Habitat.shp")



# basic terra plots
plot(buildings)
plot(bikeways)
plot(habitat)

# overlays as in episode 8
ggplot() +
  geom_sf(data=habitat) +
  geom_sf(data=buildings) +
  geom_sf(data=bikeways) +
  coord_sf()

ggplot() +
  geom_sf(data=habitat, color="yellow") +
  geom_sf(data=buildings) +
  geom_sf(data=bikeways, color="blue") +
  coord_sf()

ggsave("images/map1.1.png", plot=last_plot())


# the background setup is bathymetry and topography
# mashed together

# We'll need some bins
# best coast line bins from ep 2
# from ep 2, these are best sea level bins:
custom_bins <- c(-3, 4.9, 5, 7.5, 10, 25, 40, 70, 100, 150, 200)



campus_DEM <- rast("output_data/campus_DEM.tif") 
crs(campus_DEM)

# does bathymetry still needs to be re-projected in order to overlay?
bath <- rast("source_data/SB_bath.tif") 
crs(campus_DEM) == crs(bath)

# can't overlay them because they are different CRS's
# that's part of the narrative of the lesson.
plot(campus_DEM)
plot(bath)


campus_projection <- crs(campus_DEM)

bath <- project(bath, campus_projection)
plot(campus_DEM)
plot(bath)

crs(campus_DEM) == crs(bath)

#################################
# this still won't work because the extents are different.
# plot(bath + campus_DEM)

# Julien solved this in ep_4
# for these files, CRS, extent, and resolution all match:


# I need to get projection and resolution objects somewhere.
# so I 'copy' the one that I already have:
(my_projection <- raster("output_data/campus_DEM.tif") %>%
  crs()) 

# reload rasters
# from output folder
campus_DEM <- rast("output_data/campus_DEM.tif")
plot(campus_DEM)
# remember: this is the one we cropped, so the 2 extents are the same.
campus_bath <- rast("output_data/campus_bathymetry.tif")
plot(campus_bath)


# do they have the same projections?
crs(campus_DEM) == crs(campus_bath)

# make dataframes
campus_DEM_df <- as.data.frame(campus_DEM, xy=TRUE) %>%
  rename(elevation = greatercampusDEM_1_1) # rename to match code later
str(campus_DEM_df)

campus_bath_df <- as.data.frame(campus_bath, xy=TRUE) %>%
  rename(bathymetry = SB_bath_2m)
str(campus_bath_df)

sea_level <- campus_DEM - 5

# Set values below or equal to 0 to NA
sea_level_0 <- app(sea_level, function(x) ifelse(x <=0, NA, x))

# Note: this remove some values in the marsh that are below 0
# we are going to want those back later as our 'vernal pools'

# Make it a data frame and rebinned
sea_level_df <- as.data.frame(sea_level_0, xy=TRUE) %>% 
  rename(elevation = lyr.1) %>%
  mutate(binned = cut(elevation, breaks=custom_bins))

# to make our scale make sense, we can do 
# raster math 
# how would I do this with overlay?
ggplot() + 
  geom_raster(data = sea_level_df, aes(x=x, y=y, fill = binned)) + 
  coord_sf() # to keep map's proportions

summary(sea_level_df)
custom_sea_bins <- c(-8, -.1, .1, 3, 5, 7.5, 10, 25, 40, 70, 100, 150, 200)

sea_level_df <- sea_level_df %>% 
  mutate(binned = cut(elevation, breaks=custom_sea_bins))


length(custom_sea_bins)

# now sea level is zero.
ggplot() + 
  geom_raster(data = sea_level_df, aes(x=x, y=y, fill = binned)) +
  coord_sf()

# if we overlay, we should get the same result as at the 
# end of the previous episode:
ggplot() +
  geom_raster(data = campus_DEM_df, aes(x=x, y=y, fill = elevation)) +
  geom_raster(data = campus_bath_df, aes(x=x, y=y, fill = bathymetry)) +
  scale_fill_viridis_c(na.value="NA") +
  coord_sf()



# add custom bins to each.
# these were based on experimentation
custom_DEM_bins <- c(-3, -.01, .01, 2, 3, 4, 5, 10, 40, 200)
campus_DEM_df <- campus_DEM_df %>% 
  mutate(binned_DEM = cut(elevation, breaks = custom_DEM_bins))

str(campus_DEM_df)

custom_bath_bins <- c(1, -5, -15, -35, -45, -55, -60, -65, -75, -100, -125)
str(custom_bath_bins)

str(campus_bath_df)

campus_bath_df <- campus_bath_df %>% 
  mutate(binned_bath = cut(bathymetry, breaks =custom_bath_bins))

str(campus_bath_df)
str(campus_DEM_df)

# overlays works!!!!!
ggplot() + 
  geom_raster(data = campus_bath_df, aes(x=x, y=y, fill = binned_bath)) +
  scale_fill_manual(values = terrain.colors(10)) +
  geom_raster(data=campus_DEM_df, aes(x=x, y=y, fill = binned_DEM)) +
  scale_fill_manual(values = terrain.colors(19)) +
  coord_quickmap()

# switch the order
# not sure why 16. Not sure how it gets on both layers
# not sure why it's so so ugly
ggplot() +
    geom_raster(data = campus_DEM_df, aes(x=x, y=y, fill = binned_DEM)) +
    geom_raster(data = campus_bath_df, aes(x=x, y=y, fill = binned_bath)) +
    scale_fill_manual(values = terrain.colors(16)) +
    coord_quickmap()
  
ggplot() +
  geom_raster(data = campus_DEM_df, aes(x=x, y=y, fill = elevation)) +
  geom_raster(data = campus_bath_df, aes(x=x, y=y, fill = bathymetry)) +
        scale_fill_viridis_c(na.value="NA") +
    coord_quickmap()
  
  
# overlay the vectors

names(campus_DEM)
names(campus_bath)

# geom_spatraster is tidyterra. that's why this one doesn't work.
#ggplot() +
#  geom_spatraster(data = campus_DEM, aes(fill = greatercampusDEM_1_1)) +
#  geom_spatraster(data = campus_bath, aes(fill = SB_bath_2m)) +
#  scale_fill_viridis_c(na.value="NA") +
#  geom_sf(data=habitat, color="yellow") +
#  geom_sf(data=buildings) +
#  geom_sf(data=bikeways, color="blue") +
#    coord_sf()


# this is whack
# you need to re-project
ggplot() +
  geom_sf(data=habitat, color="yellow") +
  geom_sf(data=buildings) +
  geom_sf(data=bikeways, color="blue") +
  geom_raster(data = campus_DEM_df, aes(x=x, y=y, fill = elevation)) +
  geom_raster(data = campus_bath_df, aes(x=x, y=y, fill = bathymetry)) +
  scale_fill_viridis_c(na.value="NA") +
    coord_sf()

#bring back the hillshade
#open file from ep1-2

campus_hillshade_df <- 
  rast("source_data/campus_hillshade.tif") %>% 
  as.data.frame(xy = TRUE) %>% 
  rename(campus_hillshade = hillshade) # rename to match code later

  str(campus_hillshade_df)

#idk if I have to match the dem bins here too but just in case
custom_DEM_bins <- c(-3, -.01, .01, 2, 3, 4, 5, 10, 40, 200)
campus_hillshade_df <- campus_hillshade_df %>% 
  mutate(binned_DEM = cut(hillshade, breaks = custom_DEM_bins))


# reproject the vectors
buildings <- st_transform(buildings, campus_projection)
habitat <- st_transform(habitat, campus_projection)
bikeways <- st_transform(bikeways, campus_projection)

#update color scheme for contrast 
# +hillshade
ggplot() +
  geom_raster(data = campus_DEM_df, aes(x=x, y=y, fill = elevation)) +
  geom_raster(data = campus_bath_df, aes(x=x, y=y, fill = bathymetry)) +
  geom_raster(data = campus_hillshade_df, aes(x=x, y=y, alpha = campus_hillshade)) +
  scale_fill_viridis_c(na.value="NA") +
  labs(title="Map 1", subtitle="wide view of campus") +
  geom_sf(data=buildings, color ="hotpink") +
  geom_sf(data=habitat, color="darkorchid1") +
  geom_sf(data=bikeways, color="yellow") +
  coord_sf()

ggsave("images/map1.3.png", plot=last_plot())

# now we need to clip to the extent that we want
# further format the color ramps

