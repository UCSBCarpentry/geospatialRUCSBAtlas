# map 2
# Stylized trees, bikeways, walkways, and water
# water is yet to be defined.
## Two water sources used until now:
##  * Contours (10m): Offshore of Coal Oil Point https://earthworks.stanford.edu/catalog/stanford-yr944jr8118
##  * California Streams https://data.cnra.ca.gov/dataset/california-streams
# core skills from the lesson are in ep. 7

# clean the environment and hidden objects
rm(list=ls())


# Load required libraries
library(tidyverse)
library(terra)     # Required for loading vector data with vect() function
library(tidyterra) # Required for using geom_spatvector() with ggplot
library(ggspatial) # Required for map scale -annotation_scale()- and compass -annotation_north_arrow()-


## Read data
# Trees
trees <- vect("source_data/trees/DTK_012116.shp")
# Bikes
bikes <- vect("source_data/bike_paths/bikelanescollapsedv8.shp")
# Streams
streams <- vect("source_data/california_streams/California_Streams.shp")
# Offshore contours
offshore <- vect("source_data/offshore_coiloil/Contours_OffshoreCoalOilPoint.shp")


# Let's take a first quick look at our data and find out their projections
plot(trees)
crs(trees, describe=TRUE)
plot(bikes)
crs(bikes, describe=TRUE)
plot(streams) # Takes a lot of time, heavy file
crs(streams, describe=TRUE)
plot(offshore)
crs(offshore, describe=TRUE)

# We can see the different CRS our data has:
# * Trees: WGS84 - Pseudo-mercator / EPSG 3857
# * Bikes: NAD83 / EPSG 2229
# * Streams: WGS84  - Pseudo-mercator / EPSG 3857
# * Offshore: WGS84 - UTM Zone 11N / EPSG 32611

# So our first step will be to reproject our data to a common CRS. As the most 
# common one is WGS84 - Pseudo-mercator / EPSG 3857 from the `trees` data, we will
# use that one

# Use the project() function, the first parameter is the SpatVector we want to
# reproject, and the second argument is the desired crs we want it reprojected to.
# For the second argument, we can supply a SpatVector and terra will automatically
# get the crs from that SpatVector
bikes_proj <- project(bikes, trees)
offshore_proj <- project(offshore, trees)

## Challenge: Do we need to reproject the streams data?

# Now that our data is in the same CRS, let's check their extent
ext(trees) 
# * SpatExtent : -13344813.2450353, -13340270.0860384, 4083607.02801381, 4085810.69483412 (xmin, xmax, ymin, ymax)

ext(bikes_proj)
# * SpatExtent : -13344859.3101604, -13340139.1335369, 4083614.50498653, 4085816.84965297 (xmin, xmax, ymin, ymax)

ext(streams)
# * SpatExtent : -13851388.1259, -12638118.6176, 3827948.8521, 5309358.2157 (xmin, xmax, ymin, ymax)

ext(offshore_proj)
# * SpatExtent : -13358945.2438268, -13336909.6752497, 4074087.46157742, 4090166.00468701 (xmin, xmax, ymin, ymax)


# Our data has very different extents, as the trees and bikes data covers only campus,
# the offshore cover Coal Oil Point, and the streams cover all of California. For
# this reason, we will use the terra:crop() function so all SpatVectors have the
# same extent.

# We will base our map in the extent of the `trees` data, so we will crop all vectors
# to the extent of the `trees` data
bikes_crop <- crop(bikes_proj, trees)
streams_crop <- crop(streams, trees)
offshore_crop <- crop(offshore_proj, trees)

# With this dataset, let's do a first test of how our map would look like
ggplot() +
  geom_spatvector(data=trees, colour='darkgreen') +
  geom_spatvector(data = bikes_crop, colour='black') +
  geom_spatvector(data=offshore_crop, colour='darkblue') +
  geom_spatvector(data=streams_crop, , colour='lightblue')

# But we see that the current extent used is too narrow, we almost can't see
# the water streams or the offshore contours. So we are going to zoom out
# a 25% of the range in the x and y axis

# Store extent as object called `ext_trees`
ext_trees <- ext(trees)
# Calculate range in each axis
xrange <- ext_trees$xmax - ext_trees$xmin
yrange <- ext_trees$ymax - ext_trees$ymin
# Increase range by 25%
xrange <- xrange * 0.25
yrange <- yrange * 0.25
# Create new extent
new_ext <- ext(-xrange + ext_trees$xmin, xrange + ext_trees$xmax,
               -yrange + ext_trees$ymin, yrange + ext_trees$ymax)

# Crop the SpatVectors again, but with the new extent
bikes_crop <- crop(bikes_proj, new_ext)
streams_crop <- crop(streams, new_ext)
offshore_crop <- crop(offshore_proj, new_ext)

# Run again the plot to see the differences
ggplot() +
  geom_spatvector(data=trees, colour='darkgreen') +
  geom_spatvector(data = bikes_crop, colour='black') +
  geom_spatvector(data=offshore_crop, colour='darkblue') +
  geom_spatvector(data=streams_crop, , colour='lightblue')


# We will come back to stylize our map even more, but for now, let's explore
# the trees data, which contains more information beyond points for the location
# of the trees

# Let's see the names of the columns included in the trees data and some values of each
names(trees)
summary(trees)
head(trees)

# We can see a number of interesting features included in the data, like the
# location (Geogx, STREET and ADDRESS attributes), species (SPP), height (HT),
# condition (COND)
unique(trees$SPP)
summary(trees$HT)

# Let's plot the trees data scaling each point according to the height of the tree
ggplot() +
  geom_spatvector(data=trees, aes(size=HT), colour = 'darkgreen')

# We could modify it a bit to reduce the scale of the dots. Here the values
# in the range parameter means the size in milimeters of the dots, going from
# 0 mm to 2 mm
ggplot() +
  geom_spatvector(data=trees, aes(size=HT), colour = 'darkgreen') +
  scale_size_continuous(range = c(0, 2)) 

# But we can notice that there are trees with height 0, seedlings. Do we want to 
# keep these? Probably not. We could make a histogram to see the distribution 
# of the heights of the trees. But instead, let's just print the percentage of
# trees (or which is the same, the percentage of rows in the dataset) with
# height 0
ht_0 <- trees %>% filter(HT ==0) %>% nrow()
total <- nrow(trees)
perc_0 <- (ht_0 / total) * 100
print(sprintf("%.2f%%", perc_0))

# So we are going to filter our the 1,480 observations (13.46% of the total) of
# trees with height 0
trees_filt <- trees %>% 
  filter(HT > 0)

# Let's plot again to see the difference
ggplot() +
  geom_spatvector(data=trees_filt, aes(size=HT), colour = 'darkgreen') +
  scale_size_continuous(range = c(0, 2)) 

# Now we can starting adding our other sets of data. To start with, the bike paths,
# changing the theme to minimal
ggplot() +
  geom_spatvector(data=trees_filt, aes(size=HT), colour = 'darkgreen') +
  scale_size_continuous(range = c(0, 2)) +
  geom_spatvector(data=bikes_crop, colour = 'black') +
  theme_minimal()

# Increasing the width of the lines that represent the bike paths
ggplot() +
  geom_spatvector(data=trees_filt, aes(size=HT), colour = 'darkgreen') +
  scale_size_continuous(range = c(0, 2)) +
  geom_spatvector(data=bikes_crop, colour = 'black', linewidth = 1) +
  theme_minimal()

# Including the streams and offshore ocean contours
# Increasing the width of the lines that represent the bike paths
ggplot() +
  geom_spatvector(data=trees_filt, aes(size=HT), colour = 'darkgreen') +
  scale_size_continuous(range = c(0, 2)) +
  geom_spatvector(data=bikes_crop, colour = 'black', linewidth = 1) +
  geom_spatvector(data=streams_crop, colour = 'lightblue', linewidth = 1) +
  geom_spatvector(data=offshore_crop, colour = 'darkblue', linewidth = 1) +
  theme_minimal()

# Including the bike paths, streams and offshore to the legend.
# Save this plot in an object so we don't have to repeat the same code
map2_v1 <- ggplot() +
  geom_spatvector(data=trees_filt, aes(size=HT), colour = 'darkgreen') +
  scale_size_continuous(range = c(0, 2), name = 'Tree Height (ft)') +
  geom_spatvector(data=bikes_crop, linewidth = 1, aes(colour = 'Bike Paths')) +
  geom_spatvector(data=streams_crop, linewidth = 1, aes(colour = 'Streams')) +
  geom_spatvector(data=offshore_crop, linewidth = 1, aes(colour = 'Offshore Contours')) +
  scale_colour_manual(name = "Legend",
                    values = c('Trees' = 'darkgreen', 
                               'Bike Paths' = 'black',
                               'Streams' = 'lightblue',
                               'Offshore Contours' = 'darkblue')) +
  theme_minimal()
map2_v1

# Adding title, subtitle and title for the axes
map2_v2 <- map2_v1 +
  labs(title = 'Stylized thematic map of UCSB campus',
       subtitle = 'Trees, bike paths, and water',
       x = 'Longitude', y = 'Latitude')
map2_v2


# Modifying the aesthetics of the title and subtitle, removing the grid lines, 
# and adding a black border around the map
# title and subtitle
map2_v3 <- map2_v2 +
  theme(
    plot.title = element_text(hjust = 0.5),
    plot.subtitle = element_text(hjust = 0.5),
    panel.grid = element_blank(),
    panel.border = element_rect(color = "black", fill = NA, linewidth = 0.5)
  )
map2_v3
  
# Finally, adding a scale and a compass
map2_v4 <- map2_v3 +
  annotation_scale(location = 'bl', width_hint = 0.167) +
  annotation_north_arrow(location = 'bl', which_north = 'true', pad_x = unit(0, 'in'), pad_y = unit(0.3, 'in'), style = north_arrow_fancy_orienteering)
map2_v4

# Save this plot
ggsave(
  "images/map2.png",
  plot = map2_v4,
  width = 10, height = 7,
  dpi = 500,
  units = 'in'
)