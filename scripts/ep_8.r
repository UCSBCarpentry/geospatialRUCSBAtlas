#############################################
# ep. 8

# clean the environment and hidden objects
rm(list=ls())

current_episode <- 8


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
