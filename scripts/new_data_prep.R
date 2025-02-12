# rAtlas data download and prep

library(terra)
library(curl)
library(googledrive)
library(tidyverse)
library(sf)
library(ff)

dir.create("downloaded_data", showWarnings = FALSE)
dir.create("source_data", showWarnings = FALSE)

# 1 establish a connection to our public google drive 
#   later on from S3


# 2 download and extract the most recent zip wad geo.zip
# ----------------------------------------------
drive_download("https://drive.google.com/file/d/1Nsflxin9ce8mFpDK_1uvgsC12mRitRDK/view?usp=sharing", 
               "downloaded_data/data.zip", overwrite = TRUE)

unzip("downloaded_data/data.zip", exdir = "source_data", overwrite = TRUE)


# 3 do any actual data preparation
# ----------------------------------------------

# 3a downsample large files 
# ----------------------------

# Ep 1: Downsize the campus DEM 
campus_DEM <- rast("downloaded_data/greatercampusDEM/greatercampusDEM_1_1.tif")

campus_DEM_downsampled <- aggregate(campus_DEM, fact = 4, fun=mean,
                                    filename = "source_data/campus_DEM.tif",
                                    overwrite = TRUE)





# 3b derive data from downloads
# ----------------------------

# Hillshade
# ep 2
# map 1
# create a hillshade for our area of an appropriate resolution

aspect <- terrain(campus_DEM_downsampled, 
                  v="aspect", unit="radians", neighbors=8, 
                  filename="output_data/aspect.tif", overwrite = TRUE)
plot(aspect)

slope <- terrain(campus_DEM_downsampled, 
                 v="slope", unit = "radians", neighbors=8, 
                 filename="output_data/slope.tiff", overwrite = TRUE)
plot(slope)

hillShade <- shade(slope, aspect, 
                   angle=40, direction=170, normalize=TRUE, 
                   filename="source_data/campus_hillshade.tif", overwrite = TRUE)
grays <- colorRampPalette(c("black", "white"))(255)
plot(hillShade, col=grays)

# we should delete slope and aspect. They will not be needed anymore



# 4 rename and move files over to source_data
# --------------------------------------------




# 5 remove any files that are not needed