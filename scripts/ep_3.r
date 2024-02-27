# ep3.r
# re-project data
# overlays


# libraries for this episode:
library(tidyverse)
library(terra)
# library(rgdal)

# set up objects from previous episodes

# create the campus DEM
campus_DEM <- rast("source_data/campus_DEM.tif")

campus_DEM_df <-  campus_DEM %>% 
  as.data.frame(xy=TRUE) %>% 
  rename(elevation = greatercampusDEM_1_1)


# add the custom bins to the dataframe
custom_bins <- c(-3, -.01, .01, 2, 3, 4, 5, 10, 40, 200)
campus_DEM_df <- campus_DEM_df %>% 
  mutate(binned_DEM = cut(elevation, breaks = custom_bins))



# ep3 is reprojections. We need a raster in a different projection.
# how about bathymetry?
# SB_bath.tif came out of data_prep.r
# make it the tidy way, so that there's not an extra object
bath_rast <- rast("source_data/SB_bath.tif")  
bath_rast 

bath_df <-  bath_rast %>% 
  as.data.frame(xy=TRUE) %>% 
  rename(depth = SB_bath_2m)

str(bath_df)

summary(bath_df, maxsamp = ncell(bath_df))
# ^^ remember, those are negative numbers  
# summary also gives us a hint on ranges
# for custom bins

# the summary view also shows the pixel coordinates are different--
# so that's a clear indication these won't overlay.

# as in lesson 1
ggplot() +
  geom_raster(data = bath_df) +
  aes(x=x, y=y, fill=depth) +
  scale_fill_viridis_c() +
  coord_quickmap()

# histogram helps determine good bins
ggplot() +
  geom_histogram(data = bath_df, aes(depth), bins = 10)

# these should work:
custom_bath_bins <- c(1, -5, -15, -35, -45, -55, -60, -65, -75, -100, -125)

bath_df <- bath_df %>% 
  mutate(binned_bath = cut(depth, breaks=custom_bath_bins))

summary(bath_df)

ggplot() + 
  geom_raster(data = bath_df, aes(x=x, y=y, fill = binned_bath)) +
  scale_fill_manual(values = terrain.colors(10)) +
coord_quickmap()


# so now I am ready to overlay the two files
# this reproduces the '2 rasters with mismatched projections'
# part of the lesson
ggplot() +
  geom_raster(data = bath_df, aes(x=x, y=y, fill = binned_bath)) +
  geom_raster(data = campus_DEM_df, aes(x=x, y=y, alpha = elevation)) +
  scale_alpha(range = c(0.15, 0.65), guide = "none") +
  coord_quickmap()


# let's remake bath_df with a re-projected raster
# check the original bathymetry raster projection:
crs(bath_rast , proj=TRUE)

# I need to get projection and resolution objects somewhere.
crs(campus_DEM ) 
res(campus_DEM)

# We can reproject using the other raster as reference matching projection and resolution
reprojected_bath <- project(bath_rast, crs(campus_DEM))
reprojected_bath

# Have a look
plot(reprojected_bath)

# remake bath_df
bath_df <- as.data.frame(reprojected_bath, xy=TRUE) %>% 
  rename(depth = SB_bath_2m) 

str(bath_df)

# add the binned column to both dataframes
bath_df <- bath_df %>% 
  mutate(binned_bath = cut(depth, breaks = custom_bath_bins))


# so now they are in the same crs, and overlay!
ggplot() +
  geom_raster(data = bath_df, aes(x=x, y=y, fill = binned_bath)) +
  scale_alpha_binned(range = c(0.15, 0.65), guide = "none") +
  geom_raster(data = campus_DEM_df, aes(x=x, y=y, fill = binned_DEM)) +
  coord_quickmap()

# hide the NA's again
# scale_alpha doesn't seem to like na.value
# plot 2 custom binned maps for the sake of the overlay
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
  
  
# get a bounding box out of campus DEM to clip the bathymetry.
# later on we will clip to extent, but for now we will leave it at this:

# extent object
campus_border <- ext(campus_DEM)
campus_border

#can be turned into a spatial object
campus_border_poly <- as.polygons(campus_border, crs(campus_DEM))
campus_border_poly

# and written out to a file:
writeVector(campus_border_poly, 'output_data/campus_borderline.shp', overwrite=TRUE)

# from ep 11: crop the bathymetry to the extent
# of campus_DEM
bath_clipped <- crop(x=reprojected_bath, y=campus_border)
plot(bath_clipped)
# now we can make a big, slow overview map, and save the clipped bathymetry
# for overlaying goodness:

# save the file:
# ep 4:
writeRaster(bath_clipped, "output_data/campus_bath.tif",
            filetype="GTiff",
            overwrite=TRUE)

# Note that with the terra package, we could have done both reprojection and cropping at the same time by running:
# reprojected_bath <- project(bath_rast, campus_DEM)

campus_bath_df <- as.data.frame(bath_clipped, xy=TRUE)
str(campus_bath_df)
colnames(campus_bath_df)

# now we have a smaller campus bathymetry file:
ggplot() +
  geom_raster(data = campus_DEM_df, aes(x=x, y=y, fill = elevation)) +
  geom_raster(data = campus_bath_df, aes(x=x, y=y, fill = SB_bath_2m)) +
      scale_fill_viridis_c(na.value="NA") +
  coord_quickmap()


## to do
# there should be a 3rd and 4th raster in here to replicate
# the challenges.
# Is there a before-and-after DEM of WCOS?