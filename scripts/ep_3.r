# ep3.r
# re-project data
# overlays


# libraries for this episode:
library(tidyverse)
library(raster)
library(rgdal)

# set up objects from previous episodes

# read the campus DEM
campus_DEM_df <- raster("../output_data/campus_DEM.tif") %>% 
  as.data.frame(xy=TRUE) %>% 
  rename(elevation = layer)



# add the custom bins to the dataframe
custom_bins <- c(-3, -.01, .01, 2, 3, 4, 5, 10, 40, 200)
campus_DEM_df <- campus_DEM_df %>% 
  mutate(binned_DEM = cut(elevation, breaks = custom_bins))



# ep3 is reprojections. We need a raster in a different projection.
# how about bathymetry?
# SB_bath.tif came out of data_prep.r
# make it the tidy way, so that there's not an extra object
bath_df <- raster("../output_data/SB_bath.tif", xy=TRUE) %>% 
  as.data.frame(xy=TRUE) %>% 
  rename(depth = layer)

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
# get the original:
bath <- raster("../output_data/SB_bath.tif", xy=TRUE) 

projection(bath)

# I need to get projection and resolution objects somewhere.
my_projection <- raster("../output_data/campus_DEM.tif") %>%
  crs() 

my_res <- res(raster("../output_data/campus_DEM.tif") )

# there's an error here.
reprojected_bath <- projectRaster(bath, 
                      crs = my_projection, 
                      res = my_res)

plot(reprojected_bath)

# remake bath_df
bath_df <- as.data.frame(reprojected_bath, 
                         xy=TRUE) %>% 
  rename(depth = layer) 

str(bath_df)

# add the binned column to both dataframes
bath_df <- bath_df %>% 
  mutate(binned_bath = cut(depth, breaks = custom_bath_bins))

campus_DEM_df <- campus_DEM_df %>% 
  mutate(binned_DEM = cut(elevation, breaks = custom_bins))


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
  
  
# get a bounding box out of campus DEM to clip
# the bathymetry.
# later on we will clip to extend, but for now we will leave it at this:

# extent object
campus_border <- extent(campus_DEM_df)
str(campus_border)

#can be turned into a spatial object
campus_border_poly <- as(campus_border, 'SpatialPolygons')

# and written out to a file:
shapefile(campus_border_poly, '../output_data/campus_borderline.shp', overwrite=TRUE)

# from ep 11: crop the bathymetry to the extent
# of campus_DEM
bath_clipped <-crop(x=reprojected_bath, y=campus_border)

# now we can make a big, slow overview map, and save the clipped bathymetry
# for overlaying goodness:

# save the file:
# ep 4:
writeRaster(bath_clipped, "../output_data/campus_bath.tif",
            format="GTiff",
            overwrite=TRUE)

campus_bath_df <- as.data.frame(bath_clipped, xy=TRUE)
str(campus_bath_df)
colnames(campus_bath_df)

# now we have a smaller campus bathymetry file:
ggplot() +
  geom_raster(data = campus_DEM_df, aes(x=x, y=y, fill = elevation)) +
  geom_raster(data = campus_bath_df, aes(x=x, y=y, fill = layer)) +
      scale_fill_viridis_c(na.value="NA") +
  coord_quickmap()


