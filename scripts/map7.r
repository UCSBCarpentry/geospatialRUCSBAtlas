# map 7
# the zoom to Cali locator sheet

library(terra)
library(geojsonsf)
library(sf)

# Zoom 3
# hillshade made from 
# campus_DEM in episode 2
campus_DEM <- rast("output_data/campus_DEM.tif") 
plot(campus_DEM)
my_crs = crs(campus_DEM)

# Zoom 2
# Bite of California hillshade
# overlay the extent of campus_DEM as a locator
campusExtent <- ext(campus_DEM)
campusExtent <- vect(campusExtent)
plot(campusExtent)

#Crop the western region DEM to local area defined by geojson
west_us <- rast("downloaded_data/dem90_hf/dem90_hf.tif")
plot(west_us)
west_us <- project(west_us, my_crs)


# this geojson is the extent we want to crop to.
socalExtent <- geojson_sf("scripts/socal_aoi.geojson")
socalExtent <- vect(socalExtent)
socalExtent <- project(socalExtent, my_crs)

cali_zoom_2 <- crop(x=west_us, y=socalExtent)
plot(cali_zoom_2)


# Zoom 1
# California hillshade overview
# still need to figure out the color scale
world <- rast("downloaded_data/GRAY_HR_SR_OB.tif")
plot(world)

world <- project(world, my_crs)
cali_clip_extent <- geojson_sf("scripts/cali.geojson")
cali_zoom_1 <- crop(x=world, y=cali_clip_extent)
plot(cali_zoom_1)
polys(socalExtent, col="black")


crs(campus_DEM)
crs(cali_zoom_1)
crs(cali_zoom_2)
crs(socalExtent)
