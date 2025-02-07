# episode 6: vector data

library(sf)
library(terra)
library(tidyverse)


# clean the environment and hidden objects
rm(list=ls())

current_episode <- 6


# compare extents of 2 bike path files
# these will give a warning message about projections
bikes_a <- st_read("source_data/bike_paths/bikelanescollapsedv8.shp")
bikes_b <- st_read("source_data/library_bikes/bikelanescollapsedv8.shp")
birds <- st_read("source_data/NCOS_bird_observations/NCOS_Shorebird_Foraging_Habitat.shp")



# you can see when you create the object that the CRS's
# and bounding boxes are different

# if you look at just the bounding boxes, you might think
# you have data from opposite sides of the world.
st_bbox((bikes_a))
st_bbox((birds))


# st_bbox((bikes_b))


# here in the lesson there's lots of comparisons of metadata
# in sf it lets you know point, line, polygon

# shapefiles generally overlay automagically
# but that's handled in detail in ep 8

# LINES
str(bikes_a)
# POINTS
str(birds)

# this example might be more striking if there
# were new west campus bike paths
ggplot() +
  geom_sf(data=bikes_b, color = "red") +
  coord_sf() 

ggplot() +
  geom_sf(data=bikes_a, color = "red", size = .75) +
  geom_sf(data=bikes_b, color = "blue", size = 1.5) +
      coord_sf()


# CHALLENGE ###############################
# Load and inspect:

# POLYGONS
# buildings shapefile
buildings <- st_read("source_data/Campus_Buildings/Campus_Buildings.shp")

ggplot() +
  geom_sf(data=buildings, color = "red") +
  coord_sf()

# campus Areas of Interest (AOIs) as geojson
greatercampus <- st_read("source_data/greater_UCSB-campus-aoi.geojson")
ggplot() +
  geom_sf(data=greatercampus, color = "red") +
  coord_sf()

# if I tell you these are a zoom, how would you confirm?
westcampus <- st_read("source_data/UCSB-30-sqkm-aoi.geojson")
maincampus <- st_read("source_data/UCSB-85sqkm-aoi.geojson")

# you could tell visually!
ggplot() +
  geom_sf(data=greatercampus, color = "red") +
  geom_sf(data=maincampus, color = "green") +
  geom_sf(data=westcampus, color = "blue") +
  coord_sf()


# POINTS
# bird observations
ggplot() +
  geom_sf(data=birds, color = "red") +
  coord_sf()


# all together
# intentional error: wrong order
ggplot() +
  geom_sf(data=bikes_b, color = "blue", size = 1.5) +
  geom_sf(data=bikes_a, color = "red", size = .75) +
  geom_sf(data=buildings, color = "gray") +
  geom_sf(data=greatercampus, color = "red") +
  geom_sf(data=maincampus, color = "green") +
  geom_sf(data=westcampus, color = "blue") 


# filled polygons need to go on the bottom
ggplot() +
  geom_sf(data=greatercampus, color = "red", size = 2) +
  geom_sf(data=maincampus, color = "green") +
  geom_sf(data=westcampus, color = "blue") +
  geom_sf(data=bikes_b, color = "blue", size = 1.5) +
  geom_sf(data=bikes_a, color = "red", size = .75) +
  geom_sf(data=buildings, color = "gray") +
  coord_sf()


# keep adding. 
# where should birds go in the stack?
ggplot() +
  geom_sf(data=greatercampus, color = "red", size = 2) +
  geom_sf(data=maincampus, color = "green") +
  geom_sf(data=westcampus, color = "blue") +
  geom_sf(data=bikes_b, color = "blue", size = 2) +
  geom_sf(data=bikes_a, color = "red", size = .75) +
  geom_sf(data=buildings, color = "gray") +
  geom_sf(data=birds, color = "red", size = 2) +
      coord_sf()
