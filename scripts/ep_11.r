# ep 11
# cropping rasters

# library(raster)
library(tidyverse)
library(terra)
library(sf)
library(geojsonsf)

# clean the environment and hidden objects
rm(list=ls())

current_episode <- 11

# Crop a raster to a vector extent

campus_DEM <- rast("source_data/campus_DEM.tif")
campus_DEM_df <- as.data.frame(campus_DEM, xy = TRUE, na.rm=FALSE)

# get a geojson and turn that into a vector
ncos_aoi <- vect("source_data/ncos_aoi.geojson")

colnames(campus_DEM_df)

# projection error
ggplot() +
  geom_raster(data = campus_DEM_df, aes(x = x, y = y, fill = greatercampusDEM_1_1)) +
  scale_fill_gradientn(name = "Elevation", colors = terrain.colors(10)) +
#  geom_sf(data = ncos_aoi, color = "blue", fill = NA) +
  coord_sf()

# what episode does this come from?
ncos_aoi <- project(ncos_aoi, campus_DEM)


# now we crop
campus_DEM_cropped <- crop(x=campus_DEM, y=ncos_aoi)
campus_DEM_cropped_df <- as.data.frame(campus_DEM_cropped, xy = TRUE, na.rm=FALSE)

# st_as_sfc is new here. 
ggplot() +
  geom_sf(data = st_as_sfc(st_bbox(campus_DEM)), fill = "green",
          color = "green", alpha = .2) +
  geom_raster(data = campus_DEM_cropped_df,
              aes(x = x, y = y, fill = greatercampusDEM_1_1)) +
  scale_fill_gradientn(name = "Elevation", colors = terrain.colors(10)) +
  coord_sf()

# same extents
# with a tiny strange mismatch that we 
# should be able to explain
ggplot() +
#   geom_sf(ncos_aoi) +  
  geom_raster(data = campus_DEM_cropped_df,
              aes(x = x, y = y, fill = greatercampusDEM_1_1)) +
  scale_fill_gradientn(name = "Elevation", colors = terrain.colors(10)) +

  coord_sf()

# the lesson goes on to show the extents of a bunch of our datasets
# but the objects aren't loaded. and the lesson narrative is
# 'which is the biggest?'










# output will be a side-by-side raster of 2 drastically different
# resolutions
# get a box 
sb_channel_extent <- geojson_sf("scripts/socal_aoi.geojson") %>% 
  vect()
plot(sb_channel_extent)


# get hi-res data
# which is an output of episode 2(?)
# and is also Zoom 3?
campus_bath <- rast("output_data/ep_3_campus_bathymetry.tif")
plot(campus_bath)
campus_bath_df <- as.data.frame(campus_bath)

# get low-res data
# zoom 1, aka, Map 4 from map_4_5_6.r
west_us <- rast("source_data/dem90_hf/dem90_hf.tif")
plot(west_us)
polys(sb_channel_extent)

# the above overlay don't work because of different CRSs
sb_channel_extent <- project(sb_channel_extent, west_us)
# this time it does:
plot(west_us)
polys(sb_channel_extent, border="red", lwd=2)

# west_us_df <- as.data.frame(west_us, xy=TRUE)
# colnames(west_us_df)


# make some gg overlays
# this ggplot crashes
#ggplot() +
#  geom_raster(data = west_us_df, aes(x=x, y=y, fill = dem90_hf)) +
#  coord_sf()

# Crop it to local area defined by 
# socal_aoi.geojson which came from planet
# this geojson is the extent we want to crop to
# in the lesson, it would be the HARV AOI 1-polygon shapefile

west_us_cropped <- crop(x=west_us, y=ext(sb_channel_extent))

plot(west_us_cropped)



str(west_us)

# project it to match west_us
# why do we project this into itself?
crs(west_us) == crs(west_us_cropped)

west_us_cropped <- project(x=west_us, y=west_us)
crs(west_us)

# now you can plot them together
# to confirm that's the correct extent
# that you want to crop to
plot(west_us_cropped)
polys(sb_channel_extent, col=NA)

buildings <- st_read("source_data/Campus_Buildings/Campus_Buildings.shp")

# get/make some bounding boxes for 3 layers:
bath_extent <- ext(campus_bath)
buildings_extent <- ext(buildings)

bath_extent_shape <- vect(bath_extent)
buildings_extent_shape <- vect(buildings_extent)
campus_extent_shape <- sb_channel_extent


campus_crs <- crs(campus_extent_shape)


writeVector(campus_extent_shape, "output_data/ep_11_aoi_campus.shp", overwrite=TRUE)
writeVector(bath_extent_shape, "output_data/ep_11_aoi_bath.shp", overwrite=TRUE)
writeVector(buildings_extent_shape, "output_data/ep_11_aoi_buildings.shp", overwrite=TRUE)

campus_box <- st_read("output_data/ep_11_aoi_campus.shp")
bath_box <- st_read("output_data/ep_11_aoi_bath.shp")
buildings_box <- st_read("output_data/ep_11_aoi_buildings.shp")


#ggplot () +
#  geom_sf(data = campus_box, color = "black", fill = NA) +
#  geom_sf(data = bath_box, color = "red", fill = NA) +
#  geom_sf(data = buildings_box, color = "purple", fill = NA)


# this tells me I want to use the campus DEM bounding box
# for my overview map.

# Let's crop bathymetry to the extent of campus
# bath_cropped <- crop(x=bath, y=campus_box)
# oops. we need to re-project

# project_from <- crs(campus) 

# my_res <- res(raster("output_data/campus_DEM.tif") )

# bath_reprojected <- projectRaster(bath, 
#                    crs = project_from, 
#                    res = my_res)

  
# still need:
# selecting pixels with a buffer
# look for photos under water?
