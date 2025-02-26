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
streams <- st_read("source_data/california_streams/California_Streams.shp")

# streams is giant
# streams_cropped was made earlier
streams_cropped <- st_read("source_data/california_streams/streams_crop.shp")
crs(streams_cropped)

campus_projection == crs(streams_cropped)

# streams is really big
# and streams_cropped is too close
# is this the first time we use $geometry?
plot(streams_cropped$geometry)

# let's make a different crop of streams
# to the zoom 2 extent from map 4

# issue: when we exported this in map 4, it didn't come with
# a CRS. So we need to set it here.
bite_extent <- st_read("output_data/zoom_2_extent.shp")
crs(bite_extent)

bite_extent_crs_set <- st_set_crs(bite_extent, crs(streams_cropped))
crs(bite_extent_crs_set) 
plot(bite_extent_crs_set$geometry)

crs(bite_extent_crs_set) == crs(streams)

# this makes garbage because different crs?
# missting bounding box?
streams_crop2bite <- st_crop(streams, st_bbox(bite_extent_crs_set))

plot(streams_crop2bite$geometry)



plot(places$geometry)
plot(coast$geometry)
plot(campus_border$geometry)


# 4 layers, 4 different CRSs
crs(places, proj=TRUE)
crs(coast, proj=TRUE)
crs(campus_border, proj=TRUE)
crs(streams, proj=TRUE)

# are any of them what we have declared to be 
# the campus projection?
campus_projection == crs(places)
campus_projection == crs(coast)
campus_projection == crs(campus_border)
campus_projection == crs(streams)




# these are all different
st_crs(campus_border)
st_crs(places)
st_crs(streams_crop2bite)
st_crs(coast)

ggplot() +
  geom_sf(data = places) +
  aes(color = "purple") +
  ggtitle(gg_labelmaker(current_ggplot+1), subtitle="Map 9.1: Cali Places")+
  coord_sf()

ggplot() +
  geom_sf(data = coast, color="purple") +
  ggtitle(gg_labelmaker(current_ggplot+1), subtitle="Map 9.2: Cali Coast")+
  coord_sf()


# do they overlay before re-projection?
ggplot() +
  geom_sf(data = places,color="purple") +
  geom_sf(data = coast, color="blue") +
  ggtitle(gg_labelmaker(current_ggplot+1), subtitle="Map 9.3: Places and Coast SUCCESS") +
  coord_sf()
# they do!

ggplot() +
  geom_sf(data = streams_crop2bite, color="blue") +
  ggtitle(gg_labelmaker(current_ggplot+1), subtitle="just the streams") +
  coord_sf()


ggplot() +
  geom_sf(data = places,color="purple") +
  geom_sf(data = coast, color="gray") +
  geom_sf(data = streams_crop2bite, color="blue") +
  ggtitle(gg_labelmaker(current_ggplot+1), subtitle="Map 9.4: ???") +
  coord_sf()
# fails!

st_crs(coast)

# start by putting the coast and streams in the same CRS
streams_crop2bite_4326 <- st_transform(streams_crop2bite, st_crs(coast))

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

  