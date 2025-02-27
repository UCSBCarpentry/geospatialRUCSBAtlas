# episode 6: vector data

library(sf)
library(terra)
library(tidyverse)


# clean the environment and hidden objects
rm(list=ls())

current_episode <- 6

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



# compare extents of 2 bike path files
# these will give a warning message about projections
bikes_icm <- st_read("source_data/icm_bikes/bike_paths/bikelanescollapsedv8.shp")
bikes_library <- st_read("source_data/library_bikes/3853-s3-282-2u5_p255_2016_u5/bikelanescollapsedv8.shp")
birds_habitat <- st_read("source_data/NCOS_Shorebird_Foraging_Habitat/NCOS_Shorebird_Foraging_Habitat.shp")
birds_points <- st_read("source_data/NCOS_Bird_Survey_Data_20190724shp/NCOS_Bird_Survey_Data_20190724_web.shp")




# you can see when you create the object that the CRS's
# and bounding boxes are different

# if you look at just the bounding boxes, you might think
# you have data from opposite sides of the world.
st_bbox((bikes_icm))
st_bbox((birds_habitat))


st_bbox((bikes_library))


# here in the lesson there's lots of comparisons of metadata
# in sf it lets you know point, line, polygon

# shapefiles generally overlay automagically
# but that's handled in detail in ep 8

# LINES
str(bikes_icm)

# POINTS
# I don't think these birds are points
str(birds_points)

# this example might be more striking if there
# were new west campus bike paths
ggplot() +
  geom_sf(data=bikes_icm, color = "red") +
  geom_sf(data=birds_points) +
  ggtitle(gg_labelmaker(current_ggplot+1)) +
  coord_sf() 

ggplot() +
  geom_sf(data=bikes_icm, color = "red", size = .75) +
  geom_sf(data=bikes_library, color = "blue", size = 1.5) +
  ggtitle(gg_labelmaker(current_ggplot+1)) +
      coord_sf()

ggplot() +
  geom_sf(data=bikes_library, color = "blue", size = 1.5) +
  geom_sf(data=bikes_icm, color = "red", size = .75) +
  ggtitle(gg_labelmaker(current_ggplot+1)) +
  coord_sf()



# CHALLENGE ###############################
# Load and inspect:

# POLYGONS
# buildings shapefile
buildings <- st_read("source_data/Campus_Buildings/Campus_Buildings.shp")

ggplot() +
  geom_sf(data=buildings, color = "red") +
  ggtitle(gg_labelmaker(current_ggplot+1)) +
  coord_sf()

# campus Areas of Interest (AOIs) as geojson
greatercampus <- st_read("source_data/planet/planet/greater_UCSB-campus-aoi.geojson")
ggplot() +
  geom_sf(data=greatercampus, color = "red") +
  ggtitle(gg_labelmaker(current_ggplot+1)) +
  coord_sf()

# if I tell you these are a zoom, how would you confirm?
westcampus <- st_read("source_data/planet/planet/UCSB-30-sqkm-aoi.geojson")
maincampus <- st_read("source_data/planet/planet/UCSB-85sqkm-aoi.geojson")

# you could tell visually!
ggplot() +
  geom_sf(data=greatercampus, color = "red") +
  geom_sf(data=maincampus, color = "green") +
  geom_sf(data=westcampus, color = "blue") +
  ggtitle(gg_labelmaker(current_ggplot+1)) +
  coord_sf()


# POINTS
# bird habitat polygons
ggplot() +
  geom_sf(data=birds_habitat, color = "red") +
  ggtitle(gg_labelmaker(current_ggplot+1)) +
  coord_sf()


# all together
# intentional error: wrong order
ggplot() +
  geom_sf(data=bikes_icm, color = "blue", size = 1.5) +
  geom_sf(data=bikes_library, color = "red", size = .75) +
  geom_sf(data=buildings, color = "gray") +
  geom_sf(data=greatercampus, color = "red") +
  geom_sf(data=maincampus, color = "green") +
  geom_sf(data=westcampus, color = "blue") +
  ggtitle(gg_labelmaker(current_ggplot+1), subtitle="Error!")
  


# filled polygons need to go on the bottom
ggplot() +
  geom_sf(data=greatercampus, color = "red", size = 2) +
  geom_sf(data=maincampus, color = "green") +
  geom_sf(data=westcampus, color = "blue") +
  geom_sf(data=bikes_icm, color = "blue", size = 1.5) +
  geom_sf(data=bikes_library, color = "red", size = .75) +
  geom_sf(data=buildings, color = "gray") +
  ggtitle(gg_labelmaker(current_ggplot+1)) +
  coord_sf()


# keep adding. 
# where should birds go in the stack?
# add birds here
ggplot() +
  geom_sf(data=greatercampus, color = "red", size = 2) +
  geom_sf(data=maincampus, color = "green") +
  geom_sf(data=westcampus, color = "blue") +
  geom_sf(data=bikes_icm, color = "blue", size = 2) +
  geom_sf(data=bikes_library, color = "red", size = .75) +
  geom_sf(data=buildings, color = "gray") +
  geom_sf(data=birds_points, color = "purple") +
  geom_sf(data=birds_habitat, color = "lawngreen", size = 2) +
  ggtitle(gg_labelmaker(current_ggplot+1)) +
  coord_sf()
