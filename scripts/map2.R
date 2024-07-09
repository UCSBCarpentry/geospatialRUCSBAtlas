# map 2
# Stylized trees, bikeways, walkways, and water
# water is yet to be defined.
# core skills from the lesson are in ep. 7


# use to demo a more exotic ggplot(theme=)

library(tidyverse)
library(raster)
library(sf)


trees <- vect("source_data/trees/DTK_012116.shp")
plot(trees)
names(trees)

summary(trees)
summary(trees$SPP)
unique(trees$SPP)

summary(trees$HT)
unique(trees$HT)

# let's make a size vector
tree_height <- unique(trees$HT)

# ggplot with points
# sized by height
ggplot() +
  geom_point(data = trees, aes(x=x, y=y))







bikes <- vect("source_data/bike_paths/bikelanescollapsedv8.shp")
plot(bikes)  
ggplot() +
  geom_sf(data = bikes)
