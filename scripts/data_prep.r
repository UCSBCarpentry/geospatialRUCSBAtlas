# this script sets up data that will be used
# for 2 purposes:
# An episode-by-episode, task-by-task duplication of the
# GeoSpatial R lesson
# and
# A markdown atlas of the UCSB campus.

library(terra)
# curl is going to be better than download.file
library(curl)
library(googledrive)

# Get Campus Rasters
# **********************


#### ep 1: Starting with rasters ####
# find another one with NA's if this one doesn't have any

# Download the data from the Google Drive
drive_download("https://drive.google.com/file/d/1bkIVwJESL99Kd5N9_0QqwctgmpXYFbR8/view?usp=sharing",
                "downloaded_data/campus_DEM.zip", overwrite=TRUE)
# Unzip the archive
unzip("downloaded_data/campus_DEM.zip", exdir = "downloaded_data") # The zip archive on the GDrive has one extra level of nesting

# Rename the file and put it in the source_data folder
file.copy(from='downloaded_data/greatercampusDEM/greatercampusDEM/greatercampusDEM_1_1.tif', 
            to='source_data/campus_DEM.tif')

# Delete the zip archive
file.remove("downloaded_data/campus_DEM.zip")



#### ep 3: Reprojecting Rasters ####

# here's where we need curl: so it doesn't time out
curl_download("https://pubs.usgs.gov/ds/781/OffshoreCoalOilPoint/data/Bathymetry_OffshoreCoalOilPoint.zip", 
              "downloaded_data/Bathymetry_OffshoreCoalOilPoint.zip")

# Unzip the archive
unzip("downloaded_data/Bathymetry_OffshoreCoalOilPoint.zip", exdir = "downloaded_data/bathymery") # The zip archive on the GDrive has one extra level of nesting

# copy the file needed for episode 3
file.copy(from='downloaded_data/bathymery/Bathymetry_2m_OffshoreCoalOilPoint.tif', 
            to='source_data/SB_bath_2m.tif')

# Delete the zip archive
file.remove("downloaded_data/Bathymetry_OffshoreCoalOilPoint.zip")


# Get Campus Imagery
# *********************
# ep 5
# CIRGIS 1ft Campus
download.file("https://drive.google.com/drive/folders/1XoOOD3xcTaSevQZGtwB9ndIwaYoUbwIU?usp=drive_link",
  "source_data/w_campus_1ft.tif")

# Planet 50cm WCOS?
# with arc.open()
# the planet will have a funny band combo
# when it first opens

# Get Campus Vectors
# **********************
# Episode 6
## Part of repo:
# POINTS
# Bird Observations
# LINES:

# POLYGONS
# Buildings (good extent example?)
# Foraging Habitat?
# AOI's (Can be used later for clipping extents)
#       (You should create them in this script)

# LINES
# X-drive?
# ("source_data/bike_paths/bikelanescollapsedv8.shp")
# AGO?
# ("source_data/bike_paths/cgis_2014003_ICM_BikePath.shp")
# POINTS


# Global vectors for insets
# NED raster
# kelp shapefile?
# would be episode 9

# episode 10
# csv of lat-long pairs
# NCOS photo points
# might have to backwards engineer this
# https://ucsb.maps.arcgis.com/apps/webappviewer/index.html?id=52f2fb744eb549289bed20adf34edfd7




# manipulations start here


# ep 2: Hillshade
# create a hillshade for our area of an appropriate resolution
campus_DEM <- rast("source_data/greatercampusDEM/greatercampusDEM_1_1.tif")

aspect <- terrain(campus_DEM_downsampled, 
        opt="aspect", unit="radians", neighbors=8, 
        filename="output_data/aspect.tiff", overwrite = TRUE)
slope <- terrain(campus_DEM_downsampled, 
        opt="slope", neighbors=8, 
        filename="output_data/slope.tiff", overwrite = TRUE)

hillShade(slope, aspect, angle=260, direction=0, 
          filename="output_data/hillshade.tiff", overwrite = TRUE, 
          normalize=FALSE)



unzip("source_data/Bathymetry_OffshoreCoalOilPoint.zip",
      overwrite = TRUE, 
      exdir = "source_data/Bathymetry_OffshoreCoalOilPoint")

# Ep 3: Reprojecting Rasters
bathymetry <- 
  raster("source_data/Bathymetry_OffshoreCoalOilPoint/Bathymetry_2m_OffshoreCoalOilPoint.tif")

# downsample it so it's runnable
bathymetry_downsample <- aggregate(bathymetry, fact = 4)
writeRaster(bathymetry_downsample, "output_data/SB_bath.tif", format="GTiff", overwrite=TRUE)

# ep 5
# downsample the West Campus CIRGIS multi-band image
# natural_color <- brick("source_data/cirgis2020/w_campus.tif")
# nbands(natural_color)
# x <- nrow(natural_color) / 10
# y <- ncol(natural_color) / 10
# new_res <- raster(nrow = x, ncol = y)
# extent(new_res) <- extent(natural_color)
# natural_color_down <- resample(natural_color, new_res, method="bilinear") 
# nbands(natural_color_down)
# writeRaster(natural_color_down, "output_data/w_campus.tif", format="GTiff", overwrite=TRUE)
# I made this in ArcGIS because SLOWWWWWWWWW.....
# w_campus_1ft.tif

# downsizing the campus DEM so that it's more usable
campus_DEM <- raster("source_data/greatercampusDEM/greatercampusDEM_1_1.tif")

#this produces errors, but the output gets made
campus_DEM_downsampled <- aggregate(campus_DEM, fact = 4,
                                    filename = "output_data/campus_DEM.tif",
                                    overwrite = TRUE)
