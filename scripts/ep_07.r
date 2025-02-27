#############################################
# geospatial R UCSB examples
# ep 7 : visualizing by attribute


library(tidyverse)
library(RColorBrewer)
library(terra)

# clean the environment and hidden objects
rm(list=ls())

current_episode <- 7

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

# do we need to remake our objects?
buildings <- st_read("source_data/Campus_Buildings/Campus_Buildings.shp")
# trees ?

birds <- st_read("source_data/NCOS_Bird_Survey_Data_20190724shp/NCOS_Bird_Survey_Data_20190724_web.shp")
plot(birds$geometry)

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
# plot(buildings, max.plot = 20)

# do it pretty
# by default we get a graticule
# but how do we get at those attributes?
ggplot() +
  geom_sf(data = buildings) +
  ggtitle("Campus Buildings")

buildings$bld_date %>% unique() %>% length() 

colnames(buildings)
ggplot() +
  geom_sf(data = buildings, aes(fill=bld_date, color=bld_date )) +
  scale_fill_continuous() +
  ggtitle(gg_labelmaker(current_ggplot+1), subtitle="Campus Buildings")



# A: you could do it with a filter 

# B: and then plot one-by-one layer

# C: with an aes()
# this one gives a gradient
ggplot() +
  geom_sf(data = buildings, aes(color = bld_date), size = 1.5) +
  ggtitle("Campus Buildings", subtitle = "by age") +
  ggtitle(gg_labelmaker(current_ggplot+1)) +
  coord_sf()

# this one gives distinct colors
ggplot() +
  geom_sf(data = buildings, aes(color = factor(bld_date)), size = 1.5) +
  ggtitle(gg_labelmaker(current_ggplot+1), subtitle="Campus Buildings, by age") +
  coord_sf()


# We will want to bin that somehow, just like we
# binned the campus elevation dataset
# decade by decade?

# an example more analagous to the lesson would be 
# bird types as a categorical variable.


# more objects to map
habitat <- st_read("source_data/NCOS_Shorebird_Foraging_Habitat/NCOS_Shorebird_Foraging_Habitat.shp")

colnames(birds)
plot(birds, max.plot = 20)

# make a composite bird column: all the types of birds
birds_df <- as.data.frame(birds)


# hey, something to explore
# the output of this shows 10 
# habitat
# names(habitat)
# so 5 values we can map on
# unique(habitat$Elev_Range)
# can't use levels because it's not a factor
# levels(habitat$Elev_Range)


# filter on attributes
names(birds)

unique(birds$Species)

# color by attribute
ggplot () +
  geom_sf(data = birds, aes(color = factor(Species)), size = 1.5) +
  ggtitle(gg_labelmaker(current_ggplot+1)) +
  coord_sf()


