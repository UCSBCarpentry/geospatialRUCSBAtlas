# graphics for local examples for 
# R geospatial

# when you finish developing this, you should output all the figs
# to named files.

#############################################
# setup for each episode

library(tidyverse)
library(raster)
library(rgdal)
library(RColorBrewer)

# setwd("C:/users/your_file_path")

#############################################
# ep. 1

# get info about your first raster dataset
GDALinfo("source_data/greatercampusDEM/greatercampusDEM_1_1.tif")

# make it into an object you can manipulate
campus_DEM <- raster("source_data/greatercampusDEM/greatercampusDEM_1_1.tif")

# run the object, units are in feet
# 5 feet x 5 feet pixels
campus_DEM

# get summary of object, min and max make sense for UCSB
summary(campus_DEM)

# we know there's a deeper hole than .1 feet, so...
# can force it to calculate on all pixels
summary(campus_DEM, maxsamp = ncell(campus_DEM))

# or do that the tidy way with pipes
# and get different output
campus_DEM %>% 
  ncell() %>% 
  summary()

# summary plots require a dataframe
campus_DEM_df <- as.data.frame(campus_DEM, xy = TRUE)

# both summmaries and str of the dataframe
# show you the name of the layer you'll need to 
# refer to.

str(campus_DEM_df)

ggplot() +
  geom_raster(data = campus_DEM_df, 
              aes(x=x, y=y, fill = greatercampusDEM_1_1)) +
  scale_fill_viridis_c() +
  coord_quickmap()

# faster base R plot
# also doesn't force you to remember the name of
# the data layer
plot(campus_DEM_df)


# that's still slow as molasses, 
# for instructional purposes, we need to downsample
# so our maps draw faster
# see episode 9 for 'aggregate'
campus_DEM_downsampled <- aggregate(campus_DEM, fact = 4)

# let's rename the column so we don't have to keep typing
# greatercampusDEM_1_1
campus_DEM_df <- as.data.frame(campus_DEM_downsampled, xy=TRUE) %>% 
  rename(altitude = greatercampusDEM_1_1)



# this one doesn't work out. so leave it behind.
#zoom_DEM <- raster("source_data/greatercampusDEM/DEMmosaic.tif")
#plot(zoom_DEM)

#zoom_df <- as.data.frame(zoom_DEM, xy=TRUE)
#ggplot() +
#  geom_raster(data = zoom_df, 
#              aes(x=x, y=y, fill = DEMmosaic)) +
#  scale_fill_viridis_c() +
#  coord_quickmap()


# deal with no data
ggplot() +
  geom_raster(data = campus_DEM_df, aes(x=x, y=y, fill = altitude)) +
  scale_fill_viridis_c(na.value = "deeppink") +
  coord_quickmap()


# lesson example highlights Harvard Forest pixels > 400m.
# for us, let's highlight below 1m above sea level.
ggplot() +
  geom_raster(data = campus_DEM_df, aes(x=x, y=y, fill = altitude)) +
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

# find only negative numbers in the column.
# only 12 lonely pixels below sea level
has.neg <- apply(campus_DEM_df, 1, function(campus_DEM_df) any(campus_DEM_df < 0))
length(which(has.neg))

# challenge:
# how many below 3.1 feet (1 m)?
has.neg <- apply(campus_DEM_df, 1, function(campus_DEM_df) any(campus_DEM_df < 3.12))
length(which(has.neg))

# 1561
# that's still not that many. What about all the water?



#############################################
# ep. 2

# look at the values in the DEM
str(campus_DEM_df)
unique(campus_DEM_df$altitude)

# that's too many. let's count them up tidily
campus_DEM_df %>% 
  group_by(altitude) %>% 
  count()
# that's still too many. can I tighten the group?