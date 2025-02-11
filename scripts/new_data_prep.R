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
drive_download("https://drive.google.com/file/d/15bJbjUIzjLLOOFvZzoQA_DBXs_UOOc7u/view?usp=drive_link", 
               "downloaded_data/data.zip", overwrite = TRUE)

unzip("downloaded_data/data.zip", exdir = "downloaded_data", overwrite = TRUE)


# 3 do any actual data preparation
# ----------------------------------------------

# 3a downsample large files 
# ----------------------------

# Ep 1: Downsize the campus DEM 
campus_DEM <- rast("downloaded_data/greatercampusDEM/greatercampusDEM_1_1.tif")

campus_DEM_downsampled <- aggregate(campus_DEM, fact = 4, fun=mean,
                                    filename = "source_data/campus_DEM.tif",
                                    overwrite = TRUE)



# Ep 3: Reprojecting Rasters
#  downsample the bathymetry
bathymetry <- 
  rast("downloaded_data/Bathymetry_OffshoreCoalOilPoint/Bathymetry_2m_OffshoreCoalOilPoint.tif")

# downsample it so it's runnable
bathymetry_downsample <- aggregate(bathymetry, fact = 4)
writeRaster(bathymetry_downsample, "source_data/SB_bath.tif", filetype="GTiff", overwrite=TRUE)




# 3b derive data from downloads
# ----------------------------

# Hillshade
# ep 2
# map 1
# create a hillshade for our area of an appropriate resolution

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

# we should delete slope and aspect. They will not be needed anymore



# 4 rename and move files over to source_data
# --------------------------------------------

# episode 4
file.copy("downloaded_data/w_campus_1ft/", "source_data/cirgis_1ft/")
dir.create("source_data/planet", showWarnings = FALSE)
file.copy("downloaded_data/planet/", "source_data/planet/", recursive = TRUE)


# episode 6
dir.create("source_data/campus_buildings", showWarnings = FALSE)
file.copy("downloaded_data/Campus_Buildings/", "source_data/campus_buildings/", recursive = TRUE)

dir.create("source_data/icm_bikes", showWarnings = FALSE)
file.copy("downloaded_data/bike_paths/", "source_data/icm_bikes/", recursive = TRUE)

dir.create("source_data/library_bikes", showWarnings = FALSE)

file.copy("downloaded_data/3853-s3-282-2u5_p255_2016_u5/", 
  "source_data/library_bikes/", 
  recursive = TRUE)


# 5 remove any files that are not needed