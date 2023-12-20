# map 7 in reverse
# the zoom to Cali locator sheet

# we crop the rasters before reprojecting them.
# because that's faster

library(terra)
library(geojsonsf)
library(sf)

# geojson AOI's are used to clip source DEM's
# they are first re-projected to match the source
# DEM's CRS. 

# We'll need a grayscale palette later
grays <- colorRampPalette(c("black", "white"))(255)



# ###########################
# Zoom 3
# hillshade made from 
# campus_DEM in episode 2
campus_DEM <- rast("output_data/campus_DEM.tif") 

# we are going to reuse this CRS throughout
my_crs = crs(campus_DEM)

plot(campus_DEM, col=grays)

# hillshades are made of slopes and aspects
campus_slope <- terrain(campus_DEM, "slope", unit="radians")
plot(campus_slope)
campus_aspect <- terrain(campus_DEM, "aspect", unit="radians")
plot(campus_aspect)
campus_hillshade <- shade(campus_slope, campus_aspect,
                          angle = 25,
                          direction = 320,
                          normalize = TRUE)
plot(campus_hillshade, col=grays)


# we'll need a polygon that's the extent
# of campus
campusExtent <- ext(campus_DEM)
campusExtent <- vect(campusExtent)
plot(campusExtent)

# ############################
# Zoom 2
# Bite of California hillshade

#Crop western region DEM to local area defined by geojson
west_us <- rast("downloaded_data/dem90_hf/dem90_hf.tif")
plot(west_us)

# this geojson is the extent we want to crop to.
socalExtent <- geojson_sf("scripts/socal_aoi.geojson")
socalExtent <- vect(socalExtent)

# project it to match west_us
socalExtent <- project(socalExtent, crs(west_us))
crs(socalExtent)
cali_zoom_2 <- crop(x=west_us, y=socalExtent)
plot(cali_zoom_2, col=grays)

# put the extent back into the default projection
socalExtent <- project(socalExtent, my_crs)
# project my cropped DEM
cali_zoom_2 <- project(cali_zoom_2, my_crs)

# hillshades are made of slopes and aspects
socal_slope <- terrain(cali_zoom_2, "slope", unit="radians")
plot(socal_slope)
socal_aspect <- terrain(cali_zoom_2, "aspect", unit="radians")
plot(socal_aspect)
socal_hillshade <- shade(socal_slope, socal_aspect,
                          angle = 15,
                          direction = 270,
                          normalize = TRUE)
plot(socal_hillshade, col=grays)




# overlay the extent of campus_DEM as a locator
plot(cali_zoom_2, col=grays)
polys(campusExtent, color="red")




# #####################
# Zoom 1
# California hillshade overview
# this one came as a hillshade.
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

plot(cali_zoom_1, col=grays)
polys(socalExtent, col="red")

# save the 3 graphics
# write out the new files for later use.
# zoom 1
# zoom 2
# zoom 3

# page layout start
par(mfrow = c(1,3))

plot(cali_zoom_1, col=grays)
polys(socalExtent, col="red")

plot(socal_hillshade, col=grays)
polys(campusExtent, col="red")

plot(campus_hillshade, col=grays)

# reset par when you're done
par(mfrow = c(1,1))
