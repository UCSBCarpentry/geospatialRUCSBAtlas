# episode 9
# more about CRS
# when vectors don't line up

# clean the environment and hidden objects
rm(list=ls())

current_episode <- 9

library(sf)
library(dplyr)
library(ggplot2)
library(terra)


# ############
# start: batho_topo
# get a raster for context. 
# this is worked through in map_01.r 

campus_DEM <- rast("source_data/campus_DEM.tif") 
campus_projection <- crs(campus_DEM)

campus_bath <- rast("source_data/SB_bath.tif") 
campus_bath <- project(campus_bath, campus_projection)

campus_bath_20m <- resample(campus_bath, campus_DEM)

res(campus_DEM) == res(campus_bath_20m)

# make one DEM that is both bathymetry and elevation
# by combining campus_DEM and sea_level_0
campus_bathotopo <- merge(campus_bath_20m, campus_DEM)

plot(campus_DEM)
plot(campus_bath_20m)
plot(campus_bathotopo)

writeRaster(campus_bathotopo, "output_data/campus_bathotopo.tif", overwrite=TRUE)
# end: batho_topo
# ############


# Start the lesson narrative:
# we have populated places and streams to work with
# I don't pipe through st_zm here. ????

places <- st_read("source_data/tl_2023_06_place/tl_2023_06_place.shp")
coast <- st_read("source_data/pacific_ocean-shapefile/3853-s3_2002_s3_reg_pacific_ocean_lines.shp")
campus_border <- st_read("output_data/ep_3_campus_borderline.shp")
streams <- st_read("source_data/california_streams/California_Streams.shp")

# created along the way for a map
streams_cropped <- st_read("source_data/california_streams/streams_crop.shp")

# streams is really big, so let's crop it
# to zoom 2 extent from map 4
# issue: when we export this in map 4, it didn't come with
# a CRS. So we need to set it here.
streams <- st_transform(streams, crs(streams_cropped))
bite_extent <- st_read("output_data/zoom_2_extent.shp")

# this makes garbage because different crs?
streams_bite <- st_crop(streams, bite_extent)

crs(streams_bite) == crs(bite_extent)
bite_extent <- st_transform(bite_extent, crs(streams_bite))

crs(streams_bite) 
crs(bite_extent)



# these are all different
st_crs(campus_border)
st_crs(places)
st_crs(streams_bite)
st_crs(coast)

ggplot() +
  geom_sf(data = places) +
  aes(color = "purple") +
  ggtitle("Map 9.1: Cali Places") +
  coord_sf()

ggplot() +
  geom_sf(data = coast, color="purple") +
  ggtitle("Map 9.2: Cali Coast") +
  coord_sf()

ggplot() +
  geom_sf(data = streams_bite, color="blue") +
  ggtitle("Map 9.3: Streams") +
  coord_sf()


# do they overlay before re-projection?
ggplot() +
  geom_sf(data = places,color="purple") +
  geom_sf(data = coast, color="purple") +
  ggtitle("Map 9.3: Places and Coast SUCCESS") +
  coord_sf()
# they do!

ggplot() +
  geom_sf(data = places,color="purple") +
  geom_sf(data = coast, color="purple") +
  geom_sf(data = streams_bite, color="blue") +
  ggtitle("Map 9.4: ???") +
  coord_sf()
# fails!

# start by putting the coast and streams in the same CRS
streams_bite <- st_transform(streams_bite, st_crs(coast))

# now they should overlay:
ggplot() +
  geom_sf(data = places,color="purple") +
  geom_sf(data = coast, color="purple") +
  geom_sf(data = streams_bite, color="blue") +
  ggtitle("Map 9.5: Well?") +
  coord_sf()


ggplot() +
  geom_sf(data = streams_bite, color = "blue") +
  geom_sf(data = coast, color = "black",alpha = 0.25,size = 5) +
  ggtitle("Map 9.5: Streams and Coast") +
  coord_sf()

ggplot() +
  geom_sf(data = streams, color = "blue") +
  geom_sf(data = coast, color = "black",alpha = 0.25,size = 5) +
  geom_sf(data = places,color="purple") +
  ggtitle("Map 9.6: Streams and Coast and Places???") +
  coord_sf()

  