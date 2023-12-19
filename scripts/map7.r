# map 7
# the zoom to Cali locator sheet

library(terra)
library(geojsonsf)
library(sf)

# Zoom 3
# full campus extent hillshade made from 
# campus_DEM
campus_DEM <- rast("output_data/campus_DEM.tif") 


# Zoom 2
# Bite of California hillshade
# use extent of campus_DEM as the overlaid locator
campusExtent <- ext(campus_DEM)

#Crop the western region DEM to local area 
#crop to SLO/SB/VEN/LA/OC/SD region
west_us <- rast("downloaded_data/dem90_hf/dem90_hf.tif")
plot(west_us)

# this geojson is the extent we want to crop to.
socalExtent <- geojson_sf("scripts/socal_aoi.geojson")
socalExtent <- vect(socalExtent)
socalExtent <- project(socalExtent, crs(west_us))

socal_cropped <- crop(x=west_us, y=socalExtent)
plot(socal_cropped)


# Zoom 1
# California hillshade
# still need to figure out the color scale
world <- rast("downloaded_data/GRAY_HR_SR_OB.tif")
plot(world)

caliExtent <- geojson_sf("scripts/cali.geojson")
cali_zoom_1 <- crop(x=world, y=caliExtent)
plot(cali_zoom_1)

