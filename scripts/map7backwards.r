# map 7 in reverse
# the zoom to Cali locator sheet

# this time, we crop the rasters before reprojecting them.
# because that will be faster

library(terra)
library(geojsonsf)
library(sf)

# Zoom 3
# hillshade made from 
# campus_DEM in episode 2
campus_DEM <- rast("output_data/campus_DEM.tif") 
plot(campus_DEM)
my_crs = crs(campus_DEM)

# we'll need a polygon that's the extent
# of campus
campusExtent <- ext(campus_DEM)
campusExtent <- vect(campusExtent)
plot(campusExtent)


# Zoom 2
# Bite of California hillshade

#Crop western region DEM to local area defined by geojson
west_us <- rast("downloaded_data/dem90_hf/dem90_hf.tif")
plot(west_us)
# west_us <- project(west_us, my_crs)


# this geojson is the extent we want to crop to.
socalExtent <- geojson_sf("scripts/socal_aoi.geojson")
socalExtent <- vect(socalExtent)

# project it to match west_us
socalExtent <- project(socalExtent, crs(west_us))
crs(socalExtent)
cali_zoom_2 <- crop(x=west_us, y=socalExtent)
plot(cali_zoom_2)

# put the extent back into the default projection
socalExtent <- project(socalExtent, my_crs)
# project my cropped DEM
cali_zoom_2 <- project(cali_zoom_2, my_crs)

# overlay the extent of campus_DEM as a locator
plot(cali_zoom_2)
polys(campusExtent)

# Zoom 1
# California hillshade overview
# still need to figure out the color scale
world <- rast("downloaded_data/GRAY_HR_SR_OB.tif")
plot(world)

cali_clip_extent <- geojson_sf("scripts/cali.geojson")
cali_clip_extent <- vect(cali_clip_extent)
cali_clip_extent <- project(cali_clip_extent, crs(world))
cali_zoom_1 <- crop(x=world, y=cali_clip_extent)
plot(cali_zoom_1)

cali_zoom_1 <- project(cali_zoom_1, my_crs)

plot(cali_zoom_1)
polys(socalExtent)

# write out the new files for later use.
# zoom 1
# zoom 2

# save the 3 graphics
