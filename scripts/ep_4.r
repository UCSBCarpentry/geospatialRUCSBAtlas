# episode 4
# raster math.
# raster overlay() function.
# extract pixel values for defined locations (ie crop?)
# Export raster data as a GeoTIFF file.



# UCSB version:
# do raster math on the bathymetry later to make sea level zero
# or is it the DEM that has sea level at 5ft?



# setup environment
# library(raster)
# library(rgdal)
library(tidyverse)
library(terra)

# reload rasters
# from output folder
campus_DEM <- rast("output_data/campus_DEM.tif")
campus_DEM
plot(campus_DEM)

# remember: this is the one we cropped, so the 2 extents are the same.
campus_bath <- rast("output_data/campus_bathymetry.tif")
campus_bath
plot(campus_bath)
# do they have the same projections?
campus_DEM
campus_bath
# Yes

campus_DEM %>%  
  ncell()

summary(campus_DEM)
str(campus_DEM)
crs(campus_DEM)

campus_DEM_df <- as.data.frame(campus_DEM, xy=TRUE) %>%
  rename(elevation = greatercampusDEM_1_1) # rename to match code later
str(campus_DEM_df)

campus_bath_df <- as.data.frame(campus_bath, xy=TRUE) %>%
  rename(bathymetry = SB_bath_2m)
str(campus_bath_df)


# best coast line bins from ep 2
# from ep 2, these are best sea level bins:
custom_bins <- c(-3, 4.9, 5, 7.5, 10, 25, 40, 70, 100, 150, 200)

campus_DEM_df <- campus_DEM_df %>% 
  mutate(binned = cut(elevation, breaks=custom_bins))


ggplot() + 
  geom_raster(data = campus_DEM_df, aes(x=x, y=y, fill = binned)) + 
  coord_sf() # to keep map's proportions

# this sea level doesn't make much sense, 
# why is it 5 ft? 

# so let's do raster math to set see level to 0
sea_level <- campus_DEM - 5

sea_level_df <- as.data.frame(sea_level, xy=TRUE) %>%
  rename(elevation = greatercampusDEM_1_1)

summary(sea_level_df)
custom_sea_bins <- c(-8, -.1, 0, 3, 5, 7.5, 10, 25, 40, 70, 100, 150, 200)

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

# end of ep. 4:
# write a new geoTIFF with the new 
# sea level = 0 version of the data


merge(x, y, ..., first=TRUE, na.rm=TRUE,


# ep 4 challenge to add:
# bare earth vs canopy for 2 different sources?
# necessarily up in the hills? Or for buildings
# on campus?

