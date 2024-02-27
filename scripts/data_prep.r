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
library(tidyverse)

# Get Campus Rasters
# **********************


#### ep 1: Starting with rasters ####
# find another one with NA's if this one doesn't have any
# In case the folder has been deleted
dir.create("downloaded_data", showWarnings = FALSE)
dir.create("source_data", showWarnings = FALSE)

# hi-res UCSB Campus DEM ####################################
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
unzip("downloaded_data/Bathymetry_OffshoreCoalOilPoint.zip", exdir = "downloaded_data/bathymetry") # The zip archive on the GDrive has one extra level of nesting

# copy the file needed for episode 3
file.copy(from='downloaded_data/bathymetry/Bathymetry_2m_OffshoreCoalOilPoint.tif', 
            to='source_data/SB_bath_2m.tif')

# Delete the zip archive
file.remove("downloaded_data/Bathymetry_OffshoreCoalOilPoint.zip")

# largest extent raster
# global shaded relief from NaturalEarth
curl_download("https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/raster/GRAY_HR_SR_OB.zip",
              "downloaded_data/global_raster.zip")
unzip("downloaded_data/global_raster.zip", exdir="downloaded_data", overwrite = TRUE)


# Elevation in the Western United States 90m DEM
# to prep for SLO/SB/VEN/LA/OC/SD region extent on map 7 
# https://www.sciencebase.gov/catalog/item/542aebf9e4b057766eed286a
# this is a big, unwieldy file
curl_download("https://www.sciencebase.gov/catalog/file/get/542aebf9e4b057766eed286a", 
              "downloaded_data/dem90_hf.zip")
unzip("downloaded_data/dem90_hf.zip", exdir="source_data", overwrite = TRUE)



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
# LINES: bike paths

# POLYGONS
# Buildings (good extent example?)

building_dir_url = "https://drive.google.com/drive/folders/1SwcCrBoa0a7I_kmBNCa3_zNQ6Aw9P-8H"
building_dir = drive_get(building_dir_url)

# create local dir
dir_local <- file.path("source_data",  tolower(building_dir$name))
dir.create(dir_local, showWarnings = FALSE)

# find files in folder on GD
files = drive_ls(building_dir)
files_bind <- bind_rows(files)

# Batch download the files
map2(files_bind$id, files_bind$name, ~drive_download(as_id(.x), path = file.path(dir_local, .y), overwrite = TRUE))

#NCOS birds 
download.file("https://drive.google.com/drive/folders/1ouG80A4qCkt2KF2h5mVXIsv074sSzwE9?usp=sharing",
               "downloaded_data/NCOS_Shorebird_Foraging_Habitat.zip", overwrite = TRUE)
unzip("downloaded_data/NCOS_Shorebird_Foraging_Habitat.zip", exdir = "source_data/NCOS_bird_observations") 

# Foraging Habitat?
# AOI's (Can be used later for clipping extents)
#       (You should create them in this script)


# LINES
# X-drive?
drive_download("https://drive.google.com/open?id=187OdKbbfTUtwN9wNunpmU6GeVM5dhQzE&usp=drive_fs", 
              "downloaded_data/bike_paths.zip", overwrite=TRUE)
unzip("downloaded_data/bike_paths.zip", exdir = "source_data/bike_paths/", overwrite=TRUE)

# ("source_data/bike_paths/bikelanescollapsedv8.shp")




# POINTS


# Global vectors for insets
# NED raster
# kelp shapefile?
# would be episode 9

# california populated places
curl_download("https://www2.census.gov/geo/tiger/TIGER2023/PLACE/tl_2023_06_place.zip", "downloaded_data/tl_2023_06_place.zip")
unzip("downloaded_data/tl_2023_06_place.zip", exdir="source_data/cal_pop_places", overwrite = TRUE)
     

# episode 10
# csv of lat-long pairs
# NCOS photo points
# might have to backwards engineer this
# https://ucsb.maps.arcgis.com/apps/webappviewer/index.html?id=52f2fb744eb549289bed20adf34edfd7


# manipulations start here

# ep 2: Hillshade
# create a hillshade for our area of an appropriate resolution

# downsizing the campus DEM so that it's more usable
# this nested folder structure, r does not like
   # ^^ because you had the path wrong
campus_DEM <- rast("downloaded_data/greatercampusDEM/greatercampusDEM/greatercampusDEM_1_1.tif")

#this produces errors, but the output gets made
campus_DEM_downsampled <- aggregate(campus_DEM, fact = 4, fun=mean,
                                    filename = "source_data/campus_DEM.tif",
                                    overwrite = TRUE)

#uh why are we downsampling here?
# above or below here?
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
                   filename="source_data/hillshade.tiff", overwrite = TRUE)
grays <- colorRampPalette(c("black", "white"))(255)
plot(hillShade, col=grays)

campus_DEM_downsampled <- aggregate(campus_DEM, fact = 4,
                                    filename = "source_data/campus_DEM.tif",
                                    overwrite = TRUE)

#  JB -- this is already done above 
# unzip("source_data/Bathymetry_OffshoreCoalOilPoint.zip",
#       overwrite = TRUE, 
#       exdir = "source_data/Bathymetry_OffshoreCoalOilPoint")

# Ep 3: Reprojecting Rasters
bathymetry <- 
  rast("source_data/SB_bath_2m.tif")

# downsample it so it's runnable
bathymetry_downsample <- aggregate(bathymetry, fact = 4)
writeRaster(bathymetry_downsample, "source_data/SB_bath.tif", filetype="GTiff", overwrite=TRUE)

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

