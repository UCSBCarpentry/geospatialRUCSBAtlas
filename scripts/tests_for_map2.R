library(tidyverse)
library(raster)
library(sf)
library(terra)
library(tidyterra)
library(ggspatial)

water <- vect("C:/Users/jmuriel/Downloads/California_Streams/California_Streams.shp")
# plot(water)
# water

trees <- vect("source_data/trees/DTK_012116.shp")
trees
bikes <- vect("source_data/bike_paths/bikelanescollapsedv8.shp")
bikes

# st_bbox(water)
st_bbox(trees)

# water2 <- terra::crop(water, trees)
# plot(water2)
# 
# ggplot() +
#   geom_spatvector(data=bikes, colour = 'green') +
#   geom_spatvector(data=water2, colour = 'blue') +
#   theme_minimal()

w_coaloil <- vect("C:/Users/jmuriel/Downloads/yr944jr8118/data/Contours_OffshoreCoalOilPoint.shp")
plot(w_coaloil)
w_coaloil

plot(trees)

ggplot() +
  geom_spatvector(data=trees, colour = 'green') +
  geom_spatvector(data=w_coaloil, colour = 'blue') +
  theme_minimal()
  
w_coaloil2 <- terra::crop(w_coaloil, trees)
plot(water2)
plot(w_coaloil)

water3 <- terra::crop(water, w_coaloil)
water3
ggplot() +
  geom_spatvector(data=trees, colour = 'green') +
  geom_spatvector(data=water3, colour = 'blue') +
  theme_minimal()


water4 <- project(water, w_coaloil)
water4
w_coaloil
water4 <- terra::crop(water4, w_coaloil)
plot(water4)
ggplot() +
  geom_spatvector(data=water4, colour = 'lightblue') +
  geom_spatvector(data=w_coaloil, colour = 'blue') +
  geom_spatvector(data=trees, colour = 'darkgreen') +
  geom_spatvector(data=bikes, colour = 'black') +
  theme_minimal()

plot(trees)
ext(trees)
x_ext <-  as.integer(ext(trees)$xmax - ext(trees)$xmin)
y_ext <-  as.integer(ext(trees)$ymax - ext(trees)$ymin)
x_left <- as.integer(ext(trees)$xmin - x_ext*0.25)
x_right <- as.integer(ext(trees)$xmax + x_ext*0.25)
y_left <- as.integer(ext(trees)$ymin - y_ext*0.25)
y_right <- as.integer(ext(trees)$ymax + y_ext*0.25)


w_coaloil3 <- project(w_coaloil, trees)
w_coaloil4 <- terra::crop(w_coaloil3, ext(x_left, x_right, y_left, y_right))
water4 <- terra::crop(water, ext(x_left, x_right, y_left, y_right))



# ggplot() +
#   geom_spatvector(data=trees, colour = 'darkgreen') +
#   geom_spatvector(data=w_coaloil4, colour = 'blue') +
#   geom_spatvector(data=water4, colour = 'lightblue')
# 
# plot(trees)
# plot(w_coaloil)


ggplot() +
  geom_spatvector(data=trees %>% filter(HT > 0), aes(size=HT), colour='darkgreen') +
  scale_size_continuous(name = 'Tree Height (ft)', range = c(0, 2)) +
  geom_spatvector(data = bikes, aes(colour = 'Bike Paths'), linewidth = 1) +
  geom_spatvector(data=w_coaloil4, aes(colour = 'Offshore contours'), linewidth = 1) +
  geom_spatvector(data=water4, aes(colour = 'Streams'), linewidth = 1) +
  scale_colour_manual(name = "Legend",
                      values = c('Trees' = 'darkgreen', 
                                 'Bike Paths' = 'black',
                                 'Offshore contours' = 'darkblue',
                                 'Streams' = 'lightblue')) +
  theme_minimal() + 
  theme(
    panel.grid = element_blank(),
    panel.border = element_rect(color = "black", fill = NA, linewidth = 0.5),
    plot.title = element_text(hjust = 0.5),
    plot.subtitle = element_text(hjust = 0.5)
  ) +
  labs(title = 'Stylized thematic map of UCSB campus',
       subtitle = 'Trees, bike paths, and water',
       x = 'Longitude', y = 'Latitude') +
  annotation_scale(location = 'bl', width_hint = 0.167) +
  annotation_north_arrow(location = 'bl', which_north = 'true', pad_x = unit(0.53, 'in'), pad_y = unit(0.3, 'in'), style = north_arrow_fancy_orienteering)
  
  
  # annotation_scale(location = "bl", style = 'ticks', pad_y = unit(0.1, "cm"), unit_category = 'imperial') +
  # annotation_north_arrow(location = "tr", which_north = "true", style = north_arrow_nautical())
