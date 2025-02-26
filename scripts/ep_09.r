# episode 9
# more about CRS
# when vectors don't line up


library(sf)
library(dplyr)
library(ggplot2)
library(terra)

# clean the environment and hidden objects
rm(list=ls())

current_episode <- 9

# make our ggtitles automagically #######
# set ggplot counter
current_ggplot <- 0

gg_labelmaker <- function(plot_num){
  gg_title <- c("Episode:", current_episode, " ggplot:", plot_num)
  plot_text <- paste(gg_title, collapse=" " )
  print(plot_text)
  current_ggplot <<- plot_num
  return(plot_text)
}
# every ggtitle should be:
# ggtitle(gg_labelmaker(current_ggplot+1))
# end automagic ggtitle           #######




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

crs(places)
crs(coast)


# deal with streams
streams <- vect("source_data/california_streams/California_Streams.shp")
zoom_2_extent <- vect("scripts/socal_aoi.geojson")


crs(zoom_2_extent)
crs(streams)

ext(zoom_2_extent)
ext(streams)

zoom_2_extent_4_streams <- project(zoom_2_extent, streams)

crs(zoom_2_extent_4_streams)
crs(streams)

ext(zoom_2_extent_4_streams)
ext(streams)

# `intersect` would also work here
streams_zoom_2 <- crop(streams, ext(zoom_2_extent_4_streams))
streams_zoom_2

str(streams_zoom_2)
summary(streams_zoom_2)
plot(streams_zoom_2)

campus_projection == crs(streams_zoom_2)

# make a ggplot of streams_zoom_2
ggplot() +
  geom_sf(data=streams_zoom_2, mapping=aes(color="blue")) +
  coord_sf()

# look at our other vectors
ggplot() +
  geom_sf(data=places, color = "red") +
  geom_sf(data=coast, color = "blue") +
  ggtitle(gg_labelmaker(current_ggplot+1)) +
  coord_sf() 


# can I put in streams now?
ggplot() +
  geom_sf(data=streams_zoom_2, color="lightblue") +
  geom_sf(data=places, color = "red") +
  geom_sf(data=coast, color = "blue") +
  ggtitle(gg_labelmaker(current_ggplot+1), subtitle=" Very subtle streams") +
  coord_sf() 

ggplot() +
  geom_sf(data=places, color = "red") +
  geom_sf(data=coast, color = "blue") +
  geom_sf(data=streams_zoom_2, color="lightblue") +
  ggtitle(gg_labelmaker(current_ggplot+1), subtitle=" Very subtle streams") +
  coord_sf() 




# 4 layers, 4 different CRSs
crs(places, proj=TRUE)
crs(coast, proj=TRUE)
crs(campus_border, proj=TRUE)
crs(streams_zoom_2, proj=TRUE)

# these are all different
st_crs(campus_border)
st_crs(places)
st_crs(streams_zoom_2)
st_crs(coast)


# are any of them what we have declared to be 
# the campus projection?
campus_projection == crs(places)
campus_projection == crs(coast)
campus_projection == crs(campus_border)
campus_projection == crs(streams_zoom_2)


# they all map individually
ggplot() +
  geom_sf(data = places) +
  aes(color = "purple") +
  ggtitle(gg_labelmaker(current_ggplot+1), subtitle="Cali Places")+
  coord_sf()

ggplot() +
  geom_sf(data = coast, color="purple") +
  ggtitle(gg_labelmaker(current_ggplot+1), subtitle="Cali Coast")+
  coord_sf()

# do they overlay before re-projection?
ggplot() +
  geom_sf(data = places,color="purple") +
  geom_sf(data = coast, color="blue") +
  ggtitle(gg_labelmaker(current_ggplot+1), subtitle=": Places and Coast SUCCESS") +
  coord_sf()
# they do!

ggplot() +
  geom_sf(data = streams_zoom_2, color="blue") +
  ggtitle(gg_labelmaker(current_ggplot+1), subtitle="just the streams") +
  coord_sf()


ggplot() +
  geom_sf(data = places,color="purple") +
  geom_sf(data = coast, color="gray") +
  geom_sf(data = streams_zoom_2, color="blue") +
  ggtitle(gg_labelmaker(current_ggplot+1), subtitle="Map 9.4: ???") +
  coord_sf()
# fails!

st_crs(coast)

# start by putting the coast and streams in the same CRS
streams_crop2bite_4326 <- project(streams_zoom_2, crs(coast))

# now they should overlay:
ggplot() +
  geom_sf(data = places,color="purple") +
#  geom_sf(data = coast, color="purple") +
  geom_sf(data = streams_crop2bite_4326, color="blue") +
  ggtitle(gg_labelmaker(current_ggplot+1), subtitle="Well? ???") +
  coord_sf()


ggplot() +
  geom_sf(data = streams_crop2bite_4326, color = "blue") +
  geom_sf(data = coast, color = "black",alpha = 0.25,size = 5) +
  ggtitle(gg_labelmaker(current_ggplot+1), subtitle="Streams and Coast") +
  coord_sf()

ggplot() +
  geom_sf(data = streams_crop2bite_4326, color = "blue") +
  geom_sf(data = coast, color = "black",alpha = 0.25,size = 5) +
  geom_sf(data = places,color="purple") +
  ggtitle(gg_labelmaker(current_ggplot+1), subtitle="Streams and Coast and Places") +
  coord_sf()

  