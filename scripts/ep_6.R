# episode 6: vector data

library(sf)

# compare extents of 2 bike path files
bikes_a <- st_read("source_data/bike_paths/bikelanescollapsedv8.shp")
bikes_b <- st_read("source_data/bike_paths/cgis_2014003_ICM_BikePath.shp")

# you can see when you create the object that the CRS's
# and bounding boxes are different

# if you look at just the bounding boxes, you might think
# you have data from opposite sides of the world.
st_bbox((bikes_a))
st_bbox((bikes_b))


# here in the lesson there's lots of comparisons of metadata

# ep 7 is mapping by individual attributes.
# for now I'm skipping to ep 8: overlays'

ggplot() +
  geom_sf(data=bikes_b, color = "red") +
  geom_sf(data=bikes_a, color = "blue") 
  
ggplot() +
  geom_sf(data=bikes_b, color = "blue", size = 1.5) +
  geom_sf(data=bikes_a, color = "red", size = .75)


# get more data
buildings <- st_read("source_data/Campus_Buildings/Campus_Buildings.shp")

ggplot() +
  geom_sf(data=bikes_b, color = "blue", size = 1.5) +
  geom_sf(data=bikes_a, color = "red", size = .75) +
  geom_sf(data=buildings, color = "gray")
