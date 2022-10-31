# ep 11
# cropping rasters

library(raster)
library(rgdal)
library(sf)

# we want to make our data the extent of the campus DEM

campus <- raster("output_data/campus_DEM.tif")

campus_extent <- extent(campus)
campus_extent_shape <- as(campus_extent, 'SpatialPolygons')

crs(campus)
crs(campus_extent_shape)

crs(campus_extent_shape) <- crs(campus)
shapefile(campus_extent_shape, "output_data/aoi.shp")

aoi <- st_read("output_data/aoi.shp")

ggplot () +
  geom_sf(data = aoi, color = "black", fill = NA)

# get the rasters for cropping
campus_DEM <- raster("output_data/campus_DEM.tif")
SB_bath <- raster("output_data/SB_bath.tif")