#############################################
# geospatial R UCSB examples
# ep 7 : visualizing by attribute
# and 8 : overlays

library(tidyverse)
library(RColorBrewer)
library(terra)

# do we need to remake our objects?
buildings <- st_read("source_data/Campus_Buildings/Campus_Buildings.shp")
# trees 
birds <- st_read("source_data/NCOS_Bird_Observations_20190619_web/NCOS_Bird_Observations_20190619_web.shp")


# check out the attributes
st_geometry_type(buildings)
colnames(buildings)

# see the CRS
st_crs(buildings)


# 2 different ages in the table.
# one is a string. one is a number.
unique(buildings$date_bldg)
unique(buildings$bld_date)

# but how do we get at those attributes?
plot(buildings)

# do it pretty
# by default we get a graticule
# but how do we get at those attributes?
ggplot() +
  geom_sf(data = buildings) +
  ggtitle("Campus Buildings")

ggplot() +
  geom_sf(data = buildings, aes(bld_date)) +
  ggtitle("Campus Buildings")



# A: you could do it with a filter 

# B: and then plot one-by-one layer

# C: with an aes()
# this one gives a gradient
ggplot() +
  geom_sf(data = buildings, aes(color = bld_date), size = 1.5) +
  ggtitle("Campus Buildings", subtitle = "by age") +
  coord_sf()

# this one gives distinct colors
ggplot() +
  geom_sf(data = buildings, aes(color = factor(bld_date)), size = 1.5) +
  ggtitle("Campus Buildings", subtitle = "by age") +
  coord_sf()



# We will want to bin that somehow, just like we
# binned the campus elevation dataset
# decade by decade?

# an example more analagous to the lesson would be 
# bird types as a categorical variable.


# more objects to map
birds <- st_read("source_data/NCOS_Bird_Observations_20190619_web/NCOS_Bird_Observations_20190619_web.shp")
habitat <- st_read("source_data/NCOS_Shorebird_Foraging_Habitat/NCOS_Shorebird_Foraging_Habitat.shp")

colnames(birds)
plot(birds)

# make a composite bird column: all the types of birds
birds_df <- as.data.frame(birds)


# hey, something to explore
# the output of this shows 10 
habitat
names(habitat)
# so 5 values we can map on
unique(habitat$Elev_Range)
# can't use levels because it's not a factor
levels(habitat$Elev_Range)


# filter on attributes
names(birds)



#  color by attribute
ggplot () +
  geom_sf(data = signs, aes(color = factor(Condition)), size = 1.5) +
  labs(color = 'Condition') +
  coord_sf()


