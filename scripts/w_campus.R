#############################################
# UCSB West Campus Detail

library(tidyverse)
library(rgdal)
library(RColorBrewer)
library(sf)
library(emoji)

buildings <- st_read("source_data/Campus_Buildings/Campus_Buildings.shp")
signs <- st_read("source_data/Coal_Oil_Sign_Inventory/Inventory.shp")
birds <- st_read("source_data/NCOS_Bird_Observations_20190619_web/NCOS_Bird_Observations_20190619_web.shp")
habitat <- st_read("source_data/NCOS_Shorebird_Foraging_Habitat/NCOS_Shorebird_Foraging_Habitat.shp")
bike_paths <- st_read("source_data/bikes/bikes.shp")

v_layers <- (c("buildings", "signs", "birds", "habitat", "bike_paths"))


# this is quite large, 
campus_DEM <- raster("source_data/greatercampusDEM/greatercampusDEM_1_1.tif")

# we need to crop it
# ep 11: Crop a Raster
# ?????

# I made mine by hand in Esri
w_campus_DEM_df <- raster("source_data/w_campus_dem/w_campus_dem.tif") %>% 
  as.data.frame(xy=TRUE)

summary(w_campus_DEM_df)

ggplot() +
  geom_raster(data = w_campus_DEM_df, aes(x=x, y=y, fill = w_campus_dem)) +
  scale_fill_gradient2(na.value = "lightgrey", 
                       low="black", 
                       mid="azure1", 
                       high="cornsilk3",
                       midpoint=0) +
  coord_quickmap() +
  ggtitle("West Campus Detail")

# crop our vectors to the raster extent
# opposite of ep 11

# get the raster extent
w_campus_outline <- extent(w_campus_DEM_df)

# crop each vectors to raster extent
# don't forget you have v_layers
v_layers
 
# buildings currently makes the map crap out
# buildings <- st_read("source_data/Campus_Buildings/Campus_Buildings.shp") %>% 
#  st_crop(w_campus_outline)

signs <- st_read("source_data/Coal_Oil_Sign_Inventory/Inventory.shp") %>% 
  st_crop(w_campus_outline)

# habitat does not like to be cropped
# habitat <- st_read("source_data/NCOS_Shorebird_Foraging_Habitat/NCOS_Shorebird_Foraging_Habitat.shp") %>% 
# st_crop(w_campus_outline)

bike_paths <- st_read("source_data/bikes/bikes.shp") %>% 
  st_crop(w_campus_outline)

birds <- st_read("source_data/NCOS_Bird_Observations_20190619_web/NCOS_Bird_Observations_20190619_web.shp") %>% 
  st_crop(w_campus_outline)


# so draw a map with 5 vectors and a raster
v_layers

ggplot() +
  geom_raster(data = w_campus_DEM_df, aes(x=x, y=y, fill = w_campus_dem)) +
  scale_fill_gradient2(na.value = "lightgrey", 
                       low="black", 
                       mid="azure1", 
                       high="cornsilk3",
                       midpoint=0) +
  geom_sf(data=signs) +
  geom_sf(data=birds) +
  geom_sf(data=habitat) +
  geom_sf(data=bike_paths, color = "red") +
    coord_sf() +
  ggtitle("West Campus Detail")


ggplot () +
  geom_sf(data = habitat,
          color = "red") +
  ggtitle("just the Habitat") +
  coord_sf()




ggplot() +
  geom_raster(data = w_campus_DEM_df, aes(x=x, y=y, fill = w_campus_dem)) +
  scale_fill_gradient2(na.value = "lightgrey", 
                       low="black", 
                       mid="azure1", 
                       high="cornsilk3",
                       midpoint=0) +
  geom_sf(data = bikes, color = "red")
    coord_quickmap() +
  ggtitle("West Campus Detail")
