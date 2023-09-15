# ep 11
# cropping rasters

library(raster)
library(rgdal)
library(sf)
library(tidyverse)

# we want to crop our raster layers
# to a common extent. 
# let's make it buildings.

getwd()

# get our data
campus <- raster("output_data/campus_DEM.tif")
bath <- raster("output_data/SB_bath.tif")
buildings <- st_read("source_data/Campus_Buildings/Campus_Buildings.shp")

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
