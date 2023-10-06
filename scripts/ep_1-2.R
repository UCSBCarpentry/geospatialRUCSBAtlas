# graphics for local examples for 
# R geospatial
# episodes 1 and 2

#############################################
# setup for each episode

#library(raster)
#library(rgdal)
library(tidyverse)
library(terra)
# library(RColorBrewer)

# setwd("C:/users/your_file_path")

#############################################
# ep. 1

# get info about your first raster dataset
describe("source_data/campus_DEM.tif")

# make it into an object you can manipulate
campus_DEM <- rast("source_data/campus_DEM.tif")

# run the object, units are in feet
# 5 feet x 5 feet pixels
campus_DEM

# get summary of object, min and max make sense for UCSB
summary(campus_DEM)

# we know there's a deeper hole than .1 feet, so...
# can force it to calculate on all pixels
summary(campus_DEM, maxsamp = ncell(campus_DEM))

# or do that the tidy way with pipes
# and get different format output
campus_DEM %>%  
  ncell() %>% 
  summary()

# summary plots require a dataframe
campus_DEM_df <- as.data.frame(campus_DEM, xy = TRUE)

# both summaries and str of the dataframe
# show you the name of the layer you'll need to 
# refer to.
str(campus_DEM_df)

#do we want to change the layer name from greater...to layer?
names(campus_DEM_df)[names(campus_DEM_df) == 'campus_DEM'] <- 'layer'

ggplot() +
  geom_raster(data = campus_DEM_df, 
              aes(x=x, y=y, fill = layer)) +
  scale_fill_viridis_c() +
  coord_quickmap()

# faster base R plot
# also doesn't force you to remember the name of
# the data layer
plot(campus_DEM)

colnames(campus_DEM_df)

# rename the column so it makes more sense.
colnames(campus_DEM_df) <- c('x', 'y', 'elevation')

str(campus_DEM_df)
# now plot with that new name
ggplot() +
  geom_raster(data = campus_DEM_df, 
              aes(x=x, y=y, fill = elevation)) +
  scale_fill_viridis_c() +
  coord_quickmap()

#I dont think we have any NAs 
# deal with no data
# that tends to be the part around the edges
ggplot() +
  geom_raster(data = campus_DEM_df, aes(x=x, y=y, fill = elevation)) +
  scale_fill_viridis_c(na.value = "deeppink") +
  coord_quickmap()

# that's not actually what we want. let's white it out.
ggplot() +
  geom_raster(data = campus_DEM_df, aes(x=x, y=y, fill = elevation)) +
  scale_fill_viridis_c(na.value = "white") +
  coord_quickmap()

# histogram
ggplot() +
  geom_histogram(data = campus_DEM_df, aes(elevation), bins = 5)

ggplot() +
  geom_histogram(data = campus_DEM_df, aes(elevation), bins = 50)




# this essentially begins ep. 2
#################################
# lesson example bins / highlights Harvard Forest pixels > 400m.
# for us, let's highlight our holes.
summary(campus_DEM_df)



#############################
custom_bins <- c(-3, -.01, .01, 2, 3, 4, 5, 10, 40, 200)

campus_DEM_df <- campus_DEM_df %>% 
  mutate(binned_DEM = cut(elevation, breaks = custom_bins))

unique(campus_DEM_df$binned_DEM)

# there's sooooo few
ggplot() +
  geom_bar(data = campus_DEM_df, aes(binned_DEM))

# log scale works better
# this shows that there's nothing at zero.
# and a little bit of negative
ggplot() +
  geom_bar(data = campus_DEM_df, aes(binned_DEM)) +
  scale_y_continuous(trans='log10')

ggplot() + 
  geom_raster(data = campus_DEM_df, aes(x=x, y=y, fill = binned_DEM)) +
  coord_quickmap()

# let's go again with what we've learned
custom_bins <- c(-3, 0, 2, 5, 10, 25, 40, 70, 100, 150, 200)

campus_DEM_df <- campus_DEM_df %>% 
  mutate(binned_DEM = cut(elevation, breaks = custom_bins))

# this shows sea level at 2-5 ft
ggplot() + 
  geom_raster(data = campus_DEM_df, aes(x=x, y=y, fill = binned_DEM)) +
  coord_quickmap()


# challenge
# use custom bins to figure out a good place to put sea level
custom_bins <- c(-3, 4, 4.8, 5, 10, 25, 40, 70, 100, 150, 200)
custom_bins <- c(-3, 4.9, 5, 7.5, 10, 25, 40, 70, 100, 150, 200)

campus_DEM_df <- campus_DEM_df %>% 
  mutate(binned_DEM = cut(elevation, breaks = custom_bins))
ggplot() + 
  geom_raster(data = campus_DEM_df, aes(x=x, y=y, fill = binned_DEM)) +
  coord_quickmap()



# this isn't so nice
ggplot() + 
  geom_raster(data = campus_DEM_df, aes(x=x, y=y, fill = binned_DEM)) +
  scale_fill_manual(values = terrain.colors(10)) +
  coord_quickmap()

# let's seize control of our bins
coast_palette <- terrain.colors(10)

# set 4-5 ft a nice sea blue
coast_palette[4] <- "#1d95b3"
coast_palette

# where's my nice blue?
ggplot() + 
  geom_raster(data = campus_DEM_df, aes(x=x, y=y, fill = binned_DEM)) +
  scale_fill_manual(values = coast_palette) +
  coord_quickmap()


# hillshade layer
#ok we have to do something here to make a hillshade
#since one doesn't exist

#10:30PM musings told kristi to do it, 
# need rename the fill to layer tho

campus_hillshade_df <- 
  rast("source_data/campus_hillshade.tif") %>% 
  as.data.frame(xy = TRUE)

str(campus_hillshade_df)

# plot the hillshade
ggplot() + 
  geom_raster(data = campus_hillshade_df, 
              aes(x=x, y=y, fill = campus_hillshade)) +
  coord_quickmap()

# overlay
# not sure if this is displaying as desired
ggplot() + 
    geom_raster(data=campus_DEM_df, aes(x=x, y=y, fill = elevation)) +
    geom_raster(data = campus_hillshade_df, 
              aes(x=x, y=y, alpha = campus_hillshade)) +
    scale_fill_viridis_c() + 
  ggtitle("Elevation and Hillshade") +
  coord_quickmap()

#kristi had enough stopped here
# I'm not sure this graph does anything for us anymore
ggplot() +
  geom_raster(data = campus_DEM_df, aes(x=x, y=y, fill = elevation)) +
  scale_fill_gradient2(na.value = "lightgray", 
                       low="red", 
                       mid="white", 
                       high="cornsilk3",
                       guide = "colourbar",
                        midpoint = 3.12, aesthetics = "fill") +
  coord_quickmap()

# we can't see them, because there are too few.
# how few?
summary(campus_DEM_df)

# this attempts to find only negative elevations,
# but it doesn't work.
has.neg <- apply(campus_DEM_df, 1, function(campus_DEM_df) any(campus_DEM_df$elevation < 0))

# challenge:
# how many pixels are below 3.1 feet (1 m)?
below_3 <- apply(campus_DEM_df, 1, function(campus_DEM_df) any(campus_DEM_df < 3.12))

length(which(below_3))




#############################################
# ep. 2

# look at the values in the DEM
str(campus_DEM_df)
unique(campus_DEM_df$elevation)

# that's too many. let's count them up tidily
campus_DEM_df %>% 
  group_by(elevation) %>% 
  count()
# that's still too many. this is part
# of why bins are handy
plot(campus_DEM_df$binned_DEM)

