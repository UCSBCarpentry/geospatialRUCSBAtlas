# map 12
# let's build monthly NDVI's for campus
# as in episode 12 


library(terra)
library(scales)
library(tidyr)
library(ggplot2)
library(raster)
library(geojsonsf) # to handle geojson
# library(sf) #<- to handle geojson (not geojsonsf? -KL)


# NDVIs were premade in the Carpentries lesson, but
# we already know enough raster math to make our
# own


# make an NDVI for 1 file
tiff_path <- c("source_data/UCSB_campus_23-24_psscene_analytic_8b_sr_udm2/PSScene/20230912_175450_00_2439_3B_AnalyticMS_SR_8b_clip.tif")

#(NIR - Red) / (NIR + Red)

# brick is raster. rast is terra
# the ndvi looks VERY different
image <- brick(tiff_path, n1=8)
image <- rast(tiff_path)


ndvi_tiff <- (image[[8]] - image[[6]] / image[[8]] + image[[6]])
plot(ndvi_tiff)
plotRGB(image, r=6,g=3,b=1, stretch = "hist")

# load 23-24 8-band rasters
# loop over the files and build a raster stack

# get a file list
scene_paths <- list.files("source_data/UCSB_campus_23-24_psscene_analytic_8b_sr_udm2/PSScene",
                          full.names = TRUE,
                          pattern = "8b_clip.tif")
scene_paths[1]
str(scene_paths)

# someplace to put our images
dir.create("output_data/ndvi", showWarnings = FALSE)

# We need a common extent to make
# a raster stack
ucsb_extent <- vect("source_data/ucsb_60sqkm_planet_extent.geojson")
str(ucsb_extent)
crs(ucsb_extent)
crs(ndvi_tiff)

# this tests to see if we can take our calculated NDVIs
# and reproject them to the CRS of our AOI
ucsb_extent <- project(ucsb_extent, ndvi_tiff)

# can I also extend it?
# yes I can.
ndvi_tiff <- extend(ndvi_tiff, ucsb_extent)
plot(ndvi_tiff)

# calculate the NDVIs 
# and set them to the same extent
# loop
for (images in scene_paths) {
    source_image <- rast(images)
    ndvi_tiff <- (source_image[[8]] - source_image[[6]] / source_image[[8]] + source_image[[6]])
    new_filename <- (substr(images, 67,92))
    new_filename <- paste("output_data/ndvi/", new_filename, ".tif", sep="")
    print(new_filename)
    ndvi_tiff <- extend(ndvi_tiff, ucsb_extent)
    plot(ndvi_tiff)
    writeRaster(ndvi_tiff, new_filename, filetype="GTiff", overwrite=TRUE)
        }



# # get a list of the new files:
ndvi_series_names <- list.files("output_data/ndvi")
ndvi_series_names <- paste("output_data/ndvi/", ndvi_series_names, sep="")
length(ndvi_series_names)

length()# build raster stack
# build raster stack
## STOP HERE [rast]extents do not match error 
ndvi_series_stack <- rast(ndvi_series_names)
ndvi_series_stack <- brick(ndvi_series_names, n1=23)


# make bins

# display the binned histograms of the NDVIs

# Julian dates: that's in the lesson, but ours uses calendar dates
# challenge: change object names to Julian dates

# What month was the Greenest?

# we'll need weather data

# when was it rainiest?