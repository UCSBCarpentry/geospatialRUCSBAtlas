# rAtlas data download and prep

library(terra)
# curl is going to be better than download.file
library(curl)
library(googledrive)
library(tidyverse)
library(sf)

dir.create("downloaded_data", showWarnings = FALSE)
dir.create("source_data", showWarnings = FALSE)

# 1 establish a connection to our public google drive 
#   later on from S3

# 2 download and extract the most recent zip wad

# 3 do any actual data preparation
#   manipulations start here

# ep 2: Hillshade
# create a hillshade for our area of an appropriate resolution

# downsize the campus DEM so that it's more usable
# so that learners can run this faster.
campus_DEM <- rast("downloaded_data/greatercampusDEM/greatercampusDEM/greatercampusDEM_1_1.tif")

campus_DEM_downsampled <- aggregate(campus_DEM, fact = 4, fun=mean,
                                    filename = "source_data/campus_DEM.tif",
                                    overwrite = TRUE)


# make hillshades for map 1
# and episode 1
aspect <- terrain(campus_DEM_downsampled, 
                  v="aspect", unit="radians", neighbors=8, 
                  filename="source_data/aspect.tif", overwrite = TRUE)
plot(aspect)

slope <- terrain(campus_DEM_downsampled, 
                 v="slope", unit = "radians", neighbors=8, 
                 filename="source_data/slope.tiff", overwrite = TRUE)
plot(slope)

hillShade <- shade(slope, aspect, 
                   angle=40, direction=170, normalize=TRUE, 
                   filename="source_data/campus_hillshade.tif", overwrite = TRUE)
grays <- colorRampPalette(c("black", "white"))(255)
plot(hillShade, col=grays)

# Ep 3: Reprojecting Rasters
bathymetry <- 
  rast("source_data/SB_bath_2m.tif")

# downsample it so it's runnable
bathymetry_downsample <- aggregate(bathymetry, fact = 4)
writeRaster(bathymetry_downsample, "source_data/SB_bath.tif", filetype="GTiff", overwrite=TRUE)


# 4 remove any files that are not needed