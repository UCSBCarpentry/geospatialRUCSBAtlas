# map 2
# Stylized trees, bikeways, walkways, and water
# water is yet to be defined.
# core skills from the lesson are in ep. 7

# clean the environment and hidden objects
rm(list=ls())

# To-dos:
#  * Add water
#  * Step-by-step explanation of all the information added to the plot
#  * Also explanation on how to filter out trees with height 0. Maybe some descriptive statistics
#  * Find out how spat_vector() handles projections. trees (EPSG:3857) and bikes (EPSG:2229) have
#    different projections and extents, but spat_vector() seems to handle it automatically

# use to demo a more exotic ggplot(theme=)

library(tidyverse)
library(raster)
library(sf)
library(terra)
library(tidyterra)
library(ggspatial)


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
  geom_spatvector(data=trees, aes(size=HT))

# We could modify it a bit to reduce the scale of the dots
ggplot() +
  geom_spatvector(data=trees, aes(size=HT)) +
  scale_size_continuous(range = c(0, 2))


# Bikepaths
bikes <- vect("source_data/bike_paths/bikelanescollapsedv8.shp")
plot(bikes)
names(bikes)

# using ggplot
ggplot() +
  geom_spatvector(data=bikes)

# plotting bike paths on top ob trees layer
ggplot() +
  geom_spatvector(data=trees, aes(size=HT)) +
  scale_size_continuous(range = c(0, 2)) +
  geom_spatvector(data=bikes, colour = 'green') +
  theme_minimal()

# Map with all details
ggplot() +
  geom_spatvector(data=trees, aes(size=HT), colour='darkgreen') +
  scale_size_continuous(name = 'Tree Height (ft)', range = c(0, 2)) +
  geom_spatvector(data = bikes, aes(colour = 'Bike Paths'), linewidth = 1) +
  scale_colour_manual(name = "Bike Paths", values = c('Bike Paths' = 'black')) +
  theme_minimal() + 
  theme(
    panel.grid = element_blank(),
    panel.border = element_rect(color = "black", fill = NA, linewidth = 0.5),
    plot.title = element_text(hjust = 0.5),
    plot.subtitle = element_text(hjust = 0.5)
  ) +
  labs(title = 'Stylized thematic map of UCSB campus',
       subtitle = 'Trees, bike paths, and water') +
  annotation_scale(location = "br", style = 'ticks', pad_y = unit(0.1, "cm"), unit_category = 'imperial') +
  annotation_north_arrow(location = "tr", which_north = "true", style = north_arrow_nautical())



