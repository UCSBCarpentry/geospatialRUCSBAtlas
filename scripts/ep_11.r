# ep 11
# cropping rasters

# library(raster)
library(tidyverse)
library(terra)
library(sf)
library(geojsonsf)

# clean the environment and hidden objects
rm(list=ls())


# output will be a side-by-side raster of 2 drastically different
# resolutions
# get a box 
sb_channel_extent <- geojson_sf("scripts/socal_aoi.geojson") %>% 
  vect()
plot(sb_channel_extent)


# get hi-res data
# which is an output of episode 2(?)
# and is also Zoom 3?
campus_bath <- rast("output_data/campus_bath.tif")
plot(campus_bath)
campus_bath_df <- as.data.frame(campus_bath)

# get low-res data
# zoom 1, aka, Map 4 from map_4_5_6.r
zoom_2 <- rast("source_data/dem90_hf/dem90_hf.tif")
plot(zoom_2)
polys(sb_channel_extent)

# the above overlays don't work because of different CRSs
sb_channel_extent <- project(sb_channel_extent, zoom_2)
plot(zoom_2)
polys(sb_channel_extent)

zoom_2_df <- as.data.frame(zoom_2, xy=TRUE)
colnames(zoom_2_df)


# make some gg overlays
# this ggplot crashes
#ggplot() +
#  geom_raster(data = zoom_2_df, aes(x=x, y=y, fill = dem90_hf)) +
#  coord_sf()

# Crop it to local area defined by 
# socal_aoi.geojson which came from planet
# this geojson is the extent we want to crop to
# in the lesson, it would be the HARV AOI 1-polygon shapefile

zoom_2_extent <- ext(zoom_2)
zoom_2_cropped <- crop(x=zoom_2, y=ext(zoom_2))

#ggplot() +
#  geom_raster(data = zoom_2_df, aes(x=x, y=y, fill = dem90_hf))






# project it to match west_us
zoom_2_extent <- project(zoom_2_extent, crs(zoom_2))
crs(zoom_2_extent)

# now you can plot them together
# to confirm that's the correct extent
# that you want to crop to
plot(zoom_2)
polys(zoom_2_extent)





# make bounding boxes for each
campus_extent <- extent(campus)
bath_extent <- extent(bath)
buildings_extent <- extent(buildings)

campus_extent_shape <- as(campus_extent, 'SpatialPolygons')
bath_extent_shape <- as(bath_extent, 'SpatialPolygons')
buildings_extent_shape <- as(buildings_extent, 'SpatialPolygons')

crs(campus)
crs(campus_extent_shape)

crs(campus_extent_shape) <- crs(campus)
crs(bath_extent_shape) <- crs(bath)
crs(buildings_extent_shape) <- crs(buildings)

shapefile(campus_extent_shape, "output_data/aoi_campus.shp", overwrite=TRUE)
shapefile(bath_extent_shape, "output_data/aoi_bath.shp", overwrite=TRUE)
shapefile(buildings_extent_shape, "output_data/aoi_buildings.shp", overwrite=TRUE)

campus_box <- st_read("output_data/aoi_campus.shp")
bath_box <- st_read("output_data/aoi_bath.shp")
buildings_box <- st_read("output_data/aoi_buildings.shp")


ggplot () +
  geom_sf(data = campus_box, color = "black", fill = NA) +
  geom_sf(data = bath_box, color = "red", fill = NA) +
  geom_sf(data = buildings_box, color = "purple", fill = NA)


# this tells me I want to use the campus DEM bounding box
# for my overview map.

# Let's crop bathymetry to the extent of campus
bath_cropped <- crop(x=bath, y=campus_box)
# oops. we need to re-project

project_from <- crs(campus) 

my_res <- res(raster("output_data/campus_DEM.tif") )

bath_reprojected <- projectRaster(bath, 
                    crs = project_from, 
                    res = my_res)


campus_df <- as.data.frame(campus, xy=TRUE) %>% 
  rename(elevation=layer)

bath_df <- as.data.frame(bath_reprojected, xy=TRUE) %>% 
  rename(depth=layer)

str(campus_df)

# plot everyone together
# this won't overlay
ggplot() +
  geom_sf(data = buildings_box, color = "black", fill = NA) +
  geom_raster(data = campus_df, 
              aes(x=x, y=y, fill=elevation)) +
  scale_fill_viridis_c(na.value="NA")+
      geom_raster(data = bath_df, 
              aes(x=x, y=y, alpha=depth)) +
  coord_sf()
  
# still need:
# selecting pixels with a buffer
# look for photos under water?
