# This script will gradually transform
# into downloading the canonical data for
# the rAtlas and transforming / downsampling it
# and otherwise preparing it as we wrote the 
# episodes and maps of the rAtlas.

# Its day-to-day function has been replaced by new_data_prep.r

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
library(sf)

# to connect to AGO data
library(arcgisutils)

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
unzip("downloaded_data/campus_DEM.zip", 
      exdir = "downloaded_data",
      overwrite = TRUE) 

# Rename the file and put it in the source_data folder
# note the extra level of nesting
file.copy(from='downloaded_data/greatercampusDEM/greatercampusDEM/greatercampusDEM_1_1.tif', 
            to='source_data/campus_DEM.tif')

# Delete the zip archive
file.remove("downloaded_data/campus_DEM.zip")



#### ep 3: Reprojecting Rasters ####

# here's where we need curl: so it doesn't time out
curl_download("https://pubs.usgs.gov/ds/781/OffshoreCoalOilPoint/data/Bathymetry_OffshoreCoalOilPoint.zip", 
              "downloaded_data/Bathymetry_OffshoreCoalOilPoint.zip", quiet=FALSE)

# Unzip the archive
unzip("downloaded_data/Bathymetry_OffshoreCoalOilPoint.zip", 
      exdir = "downloaded_data/bathymetry",
      overwrite = TRUE) 

# copy the file needed for episode 3
file.copy(from='downloaded_data/bathymetry/Bathymetry_2m_OffshoreCoalOilPoint.tif', 
            to='source_data/SB_bath_2m.tif')

# Delete the zip archive
# file.remove("downloaded_data/Bathymetry_OffshoreCoalOilPoint.zip")

# largest extent raster
# global shaded relief from NaturalEarth
curl_download("https://naciscdn.org/naturalearth/10m/raster/GRAY_HR_SR_OB.zip",
              "downloaded_data/global_raster.zip")
unzip("downloaded_data/global_raster.zip", exdir="source_data/global_raster", overwrite = TRUE)


# Elevation in the Western United States 90m DEM
# to prep for SLO/SB/VEN/LA/OC/SD region extent on map 7 
#https://www.sciencebase.gov/catalog/item/542aebf9e4b057766eed286a
# this is a big, unwieldy file
drive_download("https://drive.google.com/file/d/1aFqCondOLoXZW5iS1QOKit1txVDDdJ6h/view?usp=drive_link",
               "downloaded_data/dem90_hf.zip", overwrite=TRUE)

unzip("downloaded_data/dem90_hf.zip", exdir="source_data", overwrite = TRUE)

# Delete the zip archive
file.remove("downloaded_data/dem90_hf.zip")

# Get Campus Imagery
# *********************
# ep 5
# CIRGIS 1ft Campus
drive_download("https://drive.google.com/file/d/13ceWKBnTABOH5C9KDeBIJysSdjWuBMAj/view?usp=drive_link",
               "downloaded_data/w_campus_1ft.zip",
               overwrite = TRUE)
unzip("downloaded_data/w_campus_1ft.zip",
      exdir="source_data", overwrite = TRUE)

### UCSB Campus Map 12 23-24 PS Scene and GeoJSON

#Planet Scene 23-24
drive_download("https://drive.google.com/file/d/1-eeyJvCGqPgx7UJ7st-Vu8__e3dujQVx/view?usp=drive_link",
               "downloaded_data/UCSB_campus_23-24_psscene_analytic_8b_sr_udm2.zip",
               overwrite = TRUE)

unzip("downloaded_data/UCSB_campus_23-24_psscene_analytic_8b_sr_udm2.zip",
      exdir="source_data/UCSB_campus_23-24_psscene_analytic_8b_sr_udm2",
      overwrite = TRUE)

#delete zip archive
file.remove("downloaded_data/UCSB_campus_23-24_psscene_analytic_8b_sr_udm2.zip")

#UCSB_60KM Geojson
drive_download("https://drive.google.com/file/d/1-gAC4BRkcJXxGWUb73h2pa1QfyQ9y9yk/view?usp=drive_link",
               "source_data/ucsb_60sqkm_planet_extent.geojson",
               overwrite = TRUE)
# NCOS AOI
#drive_download("https://drive.google.com/open?id=12TtsAjq3MbALF9gaqo_JUxLBzBonaWev&usp=drive_fs",
#               "source_data/ncos_aoi.geojson",
#               overwrite = TRUE)


# Planet 50cm NCOS?
# Where art thou NCOS_07_25-26_2023.tif
# https://drive.google.com/open?id=1DFQpenwhWQQ1RWAiIQ4S31TYCDk05HCU&usp=drive_fs
# with arc.open()
# the planet will have a funny band combo
# when it first opens

# Get Campus Vectors
# **********************
# Episode 6
## Part of repo:
# POINTS
# Bird Observations
# Trees
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
drive_download("https://drive.google.com/file/d/1ssytmTbpC1rpT5b-h8AxtvSgNrsGQVNY/view?usp=drive_link",
               "downloaded_data/NCOS_Shorebird_Foraging_Habitat.zip", overwrite = TRUE)
unzip("downloaded_data/NCOS_Shorebird_Foraging_Habitat.zip", exdir = "source_data/NCOS_habitat") 

# get IV buildings
drive_download("https://drive.google.com/file/d/1-splwT-DNa6kFgqhaP8OTx_TkECfTo42/view?usp=sharing",
               "downloaded_data/iv_buildings.zip", overwrite=TRUE)
unzip("downloaded_data/iv_buildings.zip", exdir = "source_data") 

# POINTS
# NCOS Planted Trees???
# AGO: https://ucsb.maps.arcgis.com/home/item.html?id=6e05f326c17b4d84a626b42a3714c918


# 2018 Campus Tree Layer:
# Open to Public
# there may be a better version out there.
# https://ucsb.maps.arcgis.com/home/item.html?id=c6eb1b782f674be082f9eb764314dda5

# there's a version of this with a trailing 0
# trees_url <- "https://services1.arcgis.com/4TXrdeWh0RyCqPgB/ArcGIS/rest/services/Treekeeper_012116/FeatureServer/0"

# this breaks:
# says arc_open is not a function in arcgisutils
# its part of a function in arcgislayers 
# remote::install_github("r-argis/arcgis", dependencies = TRUE)
#trees_layer <- arc_open(trees_url)

# not quite sure how to get this FeatureServer
# into a usable format
# trees_layer_sf <- arc_select(trees_layer)
# trees_layer_sf <- vect(trees_layer, type="points")
# colnames(trees_layer)

# dir_local <- file.vector_layers()dir_local <- file.path("source_data/trees")
# dir.create(dir_local, showWarnings = FALSE)

# so I'm faking it by putting a shapefile in the Carpentry google drive
drive_download("https://drive.google.com/file/d/1vu82OhdgrSL8qhlXBqEndohAvcgDmJ83/view?usp=drive_link",
               "downloaded_data/Treekeeper_012116.zip", overwrite = TRUE)
unzip("downloaded_data/Treekeeper_012116.zip", exdir = "source_data/trees") 

trees_sf <- vect("source_data/trees/DTK_012116.shp")
plot(trees_sf)

# Water data for map 2
# * California Streams https://data.cnra.ca.gov/dataset/california-streams
curl_download("https://data-cdfw.opendata.arcgis.com/api/download/v1/items/92b18d9e091d469fa69d256fb395b946/shapefile?layers=0",
              "downloaded_data/california_streams.zip")
unzip("downloaded_data/california_streams.zip", exdir="source_data/california_streams", overwrite = TRUE)
file.remove("downloaded_data/california_streams.zip")

# It's very large, so let's crop it here in data prep
# so map 2 makes itself faster later on:

streams <- vect("source_data/california_streams/California_Streams.shp")

# crop California streams
# to the extent of
# UCSB trees:
crs(streams, describe=TRUE)
ext(streams)
trees <- vect("source_data/trees/DTK_012116.shp")
streams_crop <- crop(streams, trees)
plot(trees)
crs(trees, describe=TRUE)
ext(trees)

streams_crop <- crop(streams, trees) %>% 
  writeVector("source_data/california_streams/streams_crop.shp", overwrite = TRUE)

# * Pacific Ocean Lines https://geodata.library.ucsb.edu/catalog/3853-s3_2002_s3_reg_pacific_ocean_lines
# geodata URLs are not static

# so google drive it is:
drive_download("https://drive.google.com/file/d/1-uMzG_chfHqiIQgoluQzA-iemLA5tY8Z/view?usp=sharing",
               "downloaded_data/pacific_ocean-shapefile.zip", overwrite=TRUE)

unzip("downloaded_data/pacific_ocean-shapefile.zip", exdir="source_data/california_coastline", overwrite = TRUE)

# Foraging Habitat?
# AOI's (Can be used later for clipping extents)
#       (You should create them in this script)


# LINES - this is bike paths
# X-drive
# version is 3853-s3-282-2u5_p255_2016_u5
# and is copied to carpentry google drive.


drive_download("https://drive.google.com/file/d/1_Rt6HGF4LsIbZPMP6vZFm67H5MlzlIW1/view?usp=drive_link", 
              "downloaded_data/bike_paths.zip", overwrite=TRUE)
unzip("downloaded_data/bike_paths.zip", exdir = "source_data/bike_paths/", overwrite=TRUE)




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
campus_DEM <- rast("downloaded_data/greatercampusDEM/greatercampusDEM/greatercampusDEM_1_1.tif")

campus_DEM_downsampled <- aggregate(campus_DEM, fact = 4, fun=mean,
                                    filename = "source_data/campus_DEM.tif",
                                    overwrite = TRUE)

#q: uh why are we downsampling here?
#a: so that learners can run this faster.


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

# campus_DEM_downsampled <- aggregate(campus_DEM, fact = 4,
#                                     filename = "source_data/campus_DEM.tif",
#                                     overwrite = TRUE)

# Ep 3: Reprojecting Rasters
bathymetry <- 
  rast("source_data/SB_bath_2m.tif")

# downsample it so it's runnable
bathymetry_downsample <- aggregate(bathymetry, fact = 4)
writeRaster(bathymetry_downsample, "source_data/SB_bath.tif", filetype="GTiff", overwrite=TRUE)

