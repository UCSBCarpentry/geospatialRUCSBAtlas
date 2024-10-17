# map 12
# let's build monthly NDVI's for campus
# as in episode 12 


library(terra)
library(scales)
library(tidyr)
library(ggplot2)
library(raster)


# NDVIs were premade in the Carpentries lesson, but
# we already know enough raster math to make our
# own



# make an NDVI for 1 file
tiff_path <- c("source_data/UCSB_campus_23-24_psscene_analytic_8b_sr_udm2/PSScene/20230912_175450_00_2439_3B_AnalyticMS_SR_8b_clip.tif")

#(NIR - Red) / (NIR + Red)

image <- brick(tiff_path, n1=8)
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

# calculate the NDVIs loop
for (images in scene_paths) {
    source_image <- brick(images, n1=8)
    ndvi_tiff <- (source_image[[8]] - source_image[[6]] / source_image[[8]] + source_image[[6]])
    new_filename <- (substr(images, 67,92))
    new_filename <- paste("output_data/ndvi/", new_filename, ".tif", sep="")
    print(new_filename)
    plot(ndvi_tiff)
    writeRaster(ndvi_tiff, new_filename, filetype="GTiff", overwrite=TRUE)
        }

# display the grid of NDVIs

# make bins

# display the binned histograms of the NDVIs

# Julian dates: that's in the lesson, but ours uses calendar dates
# challenge: change object names to Julian dates

# What month was the Greenest?

# we'll need weather data

# when was it rainiest?