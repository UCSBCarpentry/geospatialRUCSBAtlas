#############################################
# UCSB Data Overview Map

library(tidyverse)
library(rgdal)
library(RColorBrewer)
library(sf)
library(emoji)

buildings <- st_read("source_data/Campus_Buildings/Campus_Buildings.shp")
signs <- st_read("source_data/Coal_Oil_Sign_Inventory/Inventory.shp")
birds <- st_read("source_data/NCOS_Bird_Observations_20190619_web/NCOS_Bird_Observations_20190619_web.shp")
habitat <- st_read("source_data/NCOS_Shorebird_Foraging_Habitat/NCOS_Shorebird_Foraging_Habitat.shp")

# this is quite large, so we will downsample it
campus_DEM <- raster("source_data/greatercampusDEM/greatercampusDEM_1_1.tif")
campus_DEM_downsampled <- aggregate(campus_DEM, fact = 4)

campus_DEM_df <- as.data.frame(campus_DEM_downsampled, xy=TRUE) %>% 
  rename(altitude = greatercampusDEM_1_1)



# filter on attributes
names(signs)
names(birds)

# 9 signs need to be fixed.
unique(signs$Condition)
fix_me <- signs %>% 
  filter(Condition != "Good")
nrow(fix_me)


# plot the signs
#  color by attribute
# by default we get a graticule
ggplot () +
  geom_sf(data = signs, aes(color = factor(Condition)), size = 1.5) +
  labs(color = 'Condition') +
  ggtitle("just the Signs")
    coord_sf()

    
# just the birds
    ggplot () +
      geom_sf(data = birds, aes(color = factor(NCOS_Bird_)), size = 1, show.legend = FALSE) +
      ggtitle("just the Birds")
    coord_sf()
    
    
    
# plot the buildings
ggplot() +
  geom_sf(data = buildings, size = 0.1, color = 'black', fill = "cyan1") +
  ggtitle("just the Campus Buildings")


# plot the DEM
ggplot() +
  geom_raster(data = campus_DEM_df, aes(x=x, y=y, fill = altitude)) +
  scale_fill_gradient2(na.value = "lightgrey", 
                       low="black", 
                       mid="azure1", 
                       high="cornsilk3",
                       midpoint=0) +
  coord_quickmap() +
  ggtitle("just the DEM")



# Overview Map
ggplot() +
  theme(legend.position = "bottom") +
  geom_raster(data = campus_DEM_df, 
              aes(x=x, y=y, fill = altitude)) +
  scale_fill_gradient2(na.value = "lightgrey", 
                       low="black", 
                       mid="azure1", 
                       high="cornsilk3",
                       midpoint=0,
                       ) +
  geom_sf(data = signs, aes(color = factor(Condition)), size = 1.5) +
  labs(color = 'Condition') +
  geom_sf(data = birds, show.legend = FALSE, aes(color = factor(NCOS_Bird_), size = 1)) +
  geom_sf(data = habitat, show.legend = TRUE) +
  geom_sf(data = buildings, show.legend = TRUE) +
  coord_sf()
  
  
  



# hey, something to explore
# the output of this shows 10 
habitat
names(habitat)
# so 5 values we can map on
unique(habitat$Elev_Range)
# can't use levels because it's not a factor
levels(habitat$Elev_Range)

# add multiple geometries.
names(birds)

