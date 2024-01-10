# map 1
# Wide overview of campus


library(tidyverse)
library(raster)
# library(rgdal)
library(terra)

# set up objects
# the basic setup is bathymetry and topography
# mashed together

campus_DEM <- rast("output_data/campus_DEM.tif") 
crs(campus_DEM)

# does bathymetry still needs to be re-projected in order to overlay?
bath <- rast("output_data/SB_bath.tif") 
crs(bath)

# can't overlay them because they are different CRS's
# that's part of the narrative of the lesson.
plot(campus_DEM)
plot(bath)
plot(bath + campus_DEM, na.rm=TRUE)

campus_projection <- crs(campus_DEM)

bath <- project(bath, campus_projection)
plot(campus_DEM)
plot(bath)

crs(campus_DEM) == crs(bath)

#################################
# this still won't work because the extents are different.
plot(bath + campus_DEM)





# I need to get projection and resolution objects somewhere.
# so I 'copy' the one that I already have:
(my_projection <- raster("output_data/campus_DEM.tif") %>%
  crs()) 

# same with resolution:
my_res <- res(raster("output_data/campus_DEM.tif") )

str(bath)
# reproject the bathymetry data using the
# projection of the DEM:
reprojected_bath <- projectRaster(bath, 
                                  crs = my_projection)

bath_df <- as.data.frame(reprojected_bath, 
                         xy=TRUE) %>% 
  rename(depth = layer) 


# create those two dataframes
campus_DEM_df <- campus_DEM %>% 
  as.data.frame(xy=TRUE) %>% 
  rename(elevation = layer)
crs(campus_DEM_df)

bath_df <- as.data.frame(bath, xy=TRUE)



# add custom bins to each.
# these were based on experimentation
custom_DEM_bins <- c(-3, -.01, .01, 2, 3, 4, 5, 10, 40, 200)
campus_DEM_df <- campus_DEM_df %>% 
  mutate(binned_DEM = cut(elevation, breaks = custom_DEM_bins))

str(campus_DEM_df)

custom_bath_bins <- c(1, -5, -15, -35, -45, -55, -60, -65, -75, -100, -125)

str(bath_df)
bath_df <- bath_df %>% 
  mutate(binned_bath = cut(layer, breaks=custom_bath_bins))

str(bath_df)

str(campus_DEM_df)

# overlays works!!!!!
ggplot() + 
  geom_raster(data = bath_df, aes(x=x, y=y, fill = binned_bath)) +
  scale_fill_manual(values = terrain.colors(10)) +
  geom_raster(data=campus_DEM_df, aes(x=x, y=y, fill = binned_DEM)) +
  scale_fill_manual(values = terrain.colors(19))
  coord_quickmap()


  ggplot() +
    geom_raster(data = bath_df, aes(x=x, y=y, fill = depth)) +
    geom_raster(data = campus_DEM_df, aes(x=x, y=y, fill = elevation)) +
    scale_fill_viridis_c(na.value="white") +
    coord_quickmap()
  
  ggplot() +
    geom_raster(data = bath_df, aes(x=x, y=y, fill = depth)) +
    geom_raster(data = campus_DEM_df, aes(x=x, y=y, fill = elevation)) +
    scale_fill_viridis_c(na.value="NA") +
    coord_quickmap()
  
  
# now we need to clip to the extent that we want
# further format the color ramps here
# overlay the other layers
  
  