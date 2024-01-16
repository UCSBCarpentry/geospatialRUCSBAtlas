# map 7 
# the zoom to Cali locator sheet

# we crop the rasters before reprojecting them.
# because that's faster

library(terra)
library(geojsonsf)
library(sf)
library(ggplot2)
library(tidyterra)
library(dplyr)



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


# geojson AOI's are used to clip source DEM's
# they are first re-projected to match the source
# DEM's CRS. 
# we'll need a polygon that's the extent
# of campus
campus_extent <- ext(campus_DEM)
campus_extent <- vect(campus_extent)
plot(campus_extent)

# so we have
# campus_hillshade and
# campus_extent

# ############################
# Zoom 2
# Bite of California hillshade

#Crop western region DEM to local area defined by geojson
west_us <- rast("downloaded_data/dem90_hf/dem90_hf.tif")
plot(west_us)

# this geojson is the extent we want to crop to.
# extent geojson came from planet
socal_extent <- geojson_sf("scripts/cali.geojson")
socal_extent <- vect(socal_extent)
plot(socal_extent)

# project it to match west_us
socal_extent <- project(socal_extent, crs(west_us))
crs(socal_extent)
cali_zoom_2 <- crop(x=west_us, y=socal_extent)
plot(cali_zoom_2, col=grays)

# put the extent back into the default projection
socal_extent <- project(socal_extent, my_crs)

# project my cropped DEM into my standard crs
# this is slow!!
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
plot(socal_hillshade, col=grays)
polys(campus_extent, col="red")




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
polys(socal_extent)

plot(cali_zoom_1, col=grays)
polys(socal_extent, col="red")

# save the 3 graphics
# write out the new files for later use.
# zoom 1
# zoom 2
# zoom 3


# page layout start
# ##########################
# 3 hillshades

par(mfrow = c(1,3))

plot(cali_zoom_1, col=grays)
polys(socal_extent, col="red")

plot(socal_hillshade, col=grays)
polys(campus_extent, col="red")

plot(campus_hillshade, col=grays)


# now do that to a file
png("images/3-zoom.png", width=1900)
par(mfrow = c(1,3))

plot(cali_zoom_1, col=grays)
polys(socal_extent, col="red")

plot(socal_hillshade, col=grays)
polys(campus_extent, col="red")

plot(campus_hillshade, col=grays)

dev.off()

# reset par when you're done
par(mfrow = c(1,1))


# turn the 2 new hillshades (zooms 2 & 3)
# into elevation over hillshade
# remember: zoom1 started as a hillshade.

# zoom3
# figure out the layer names
(campus_DEM)
(campus_hillshade)

zoom3 <- ggplot() +
  geom_raster(data = campus_DEM,
              aes(x=x, y=y, fill=layer)) +
  geom_raster(data=campus_hillshade,
              aes(x=x, y=y, alpha = hillshade)) +
  scale_fill_viridis_c() +
  scale_alpha(range = c(0.15, 0.65), guide="none")

# zoom2
socal_hillshade
cali_zoom_2

ggplot() +
  geom_raster(data = cali_zoom_2,
              aes(x=x, y=y, fill=dem90_hf)) +
  geom_raster(data=socal_hillshade,
              aes(x=x, y=y, alpha = hillshade)) +
  scale_fill_viridis_c() +
  scale_alpha(range = c(0.15, 0.65), guide="none")

# zoom1
# figure out the layer names


ggplot() +
  geom_raster(data = cali_zoom_1,
              aes(x=x, y=y, fill=dem90_hf)) +
  geom_raster(data=socal_hillshade,
              aes(x=x, y=y, alpha = hillshade)) +
  scale_fill_viridis_c() +
  scale_alpha(range = c(0.15, 0.65), guide="none")


cali_zoom_1
ggplot() +
  geom_raster(data = cali_zoom_1,
              aes(x=x, y=y, fill=GRAY_HR_SR_OB)) +
  scale_fill_viridis_c() 




# add the AOI polygons
# ########################


# zoom2
socal_hillshade
cali_zoom_2

summary(campus_extent)
plot(campus_extent)

zoom2 <- ggplot() +
  geom_raster(data = cali_zoom_2,
              aes(x=x, y=y, fill=dem90_hf)) +
  geom_raster(data=socal_hillshade,
              aes(x=x, y=y, alpha = hillshade)) +
  geom_sf(data=campus_extent, fill="NA") +
  scale_fill_viridis_c() +
  scale_alpha(range = c(0.15, 0.65), guide="none")

# zoom1
str(cali_zoom_1)
zoom1 <- ggplot() +
  geom_raster(data = cali_zoom_1,
              aes(x=x, y=y, fill=GRAY_HR_SR_OB)) +
  geom_spatvector(data=socal_extent, fill="NA") +
    scale_fill_viridis_c() 

# end of 2023 work
# I guess par doesn't work with ggplot outputs
par(mfrow = c(1,3))
zoom3
zoom2
zoom1

# polygons
places <- vect("downloaded_data/tl_2023_06_place.shp")
plot(places)

ggplot() + 
  geom_spatvector(data=places)

# how can I get a vector overlay into here?
# right now you are doing geom_raster, but I 
# think I should be using geom_spatraster
ggplot() +
  geom_raster(data = cali_zoom_2,
              aes(x=x, y=y, fill=dem90_hf)) +
  geom_raster(data=socal_hillshade,
              aes(x=x, y=y, alpha = hillshade)) +
  scale_fill_viridis_c() +
  scale_alpha(range = c(0.15, 0.65), guide="none")

ggplot() +
  geom_spatraster(data = cali_zoom_2,
              aes(fill=dem90_hf))
  

par(mfrow = c(1,3))

# reset par when you're done
par(mfrow = c(1,1))
