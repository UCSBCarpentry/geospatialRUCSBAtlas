#############################################
# ep 7 and on w/ UCSB vector data

library(tidyverse)
library(rgdal)
library(RColorBrewer)
library(sf)

buildings <- st_read("source_data/Campus_Buildings/Campus_Buildings.shp")

# count the objects and attributes
st_geometry_type(buildings)

# see the CRS
st_crs(buildings)

# do it fast
plot(buildings)

# do it pretty
# by default we get a graticule
ggplot() +
  geom_sf(data = buildings, size = 0.1, color = 'black', fill = "gray") +
  ggtitle("Campus Buildings")

# setting variables
signs <- st_read("source_data/Coal_Oil_Sign_Inventory/Inventory.shp")
birds <- st_read("source_data/NCOS_Bird_Observations_20190619_web/NCOS_Bird_Observations_20190619_web.shp")
habitat <- st_read("source_data/NCOS_Shorebird_Foraging_Habitat/NCOS_Shorebird_Foraging_Habitat.shp")

#graphing variables
ggplot() +
  geom_sf(data = signs, size = 0.1, color = 'black', fill = "cyan1")

ggplot() +
  geom_sf(data = birds, size = 0.1, color = 'black', fill = "cyan1")

ggplot() +
  geom_sf(data = habitat, size = 0.1, color = 'black', fill = "cyan1")

# hey, something to explore
# the output of this shows 10 
habitat
names(habitat)
# so 5 values we can map on
unique(habitat$Elev_Range)
# can't use levels because it's not a factor
levels(habitat$Elev_Range)


# filter on attributes
names(signs)
names(birds)

# 9 signs need to be fixed.
unique(signs$Condition)
fix_me <- signs %>% 
  filter(Condition == "Poor")
nrow(fix_me)

#  color by attribute
ggplot () +
  geom_sf(data = signs, aes(color = factor(Condition)), size = 1.5) +
  labs(color = 'Condition') +
  coord_sf()

#############################################
# ep. 8


# add multiple geometries.
names(birds)

campus_DEM <- raster("source_data/greatercampusDEM/greatercampusDEM_1_1.tif")
campus_DEM_df <- as.data.frame(campus_DEM, xy=TRUE)

ggplot() +
  geom_raster(data = campus_DEM_df, 
              aes(x=x, y=y, fill = greatercampusDEM_1_1)) +
  scale_fill_gradient2(na.value = "lightgrey", 
                       low="black", 
                       mid="azure1", 
                       high="cornsilk3",
                       midpoint=0) +
  geom_sf(data = signs) +
  geom_sf(data = birds) +
  geom_sf(data = habitat) +
  geom_sf(data = buildings)

ggplot() +
  geom_raster(data = campus_DEM_df, aes(x=x, y=y, fill = greatercampusDEM_1_1)) +
  scale_fill_gradient2(na.value = "lightgrey", 
                       low="black", 
                       mid="azure1", 
                       high="cornsilk3",
                       midpoint=0) +
  coord_quickmap()

