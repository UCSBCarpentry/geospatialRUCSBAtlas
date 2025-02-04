# graphics for local examples for 
# R geospatial
# episodes 1 and 2

#############################################
# setup for each episode

library(tidyverse)
library(terra)
library(RColorBrewer)

# setwd("C:/users/your_file_path")

# start fresh
rm(list=ls())

#############################################
# ep. 1

# get info about your first raster dataset
describe("source_data/campus_DEM.tif")

# make it into an object you can manipulate
campus_DEM <- rast("source_data/campus_DEM.tif")

# run the object, units are in feet
# 20 feet x 20 feet pixels
campus_DEM

# get summary of object, min and max make sense for UCSB
summary(campus_DEM)

# we know there's a deeper hole than .1 feet, so...

# can force it to calculate on all pixels
summary(values(campus_DEM))


# or do that the tidy way with pipes
campus_DEM %>%  
  values() %>% 
  summary()

# summary plots require a dataframe
# (if we remove the NA's that screws up the narrative later)
campus_DEM_df <- as.data.frame(campus_DEM, xy = TRUE, na.rm=FALSE)

# both summaries and str of the dataframe
# show you the name of the layer you'll need to 
# refer to.
str(campus_DEM_df)
summary(campus_DEM_df)

#change the elevation field named greatercampusdem_1_1 to elevation 
#we will stick to this naming convention the rest of the lesson
names(campus_DEM_df)[names(campus_DEM_df) == 'greatercampusDEM_1_1'] <- 'elevation'

ggplot() + geom_raster(data = campus_DEM_df, 
              aes(x=x, y=y, fill = elevation)) +
 scale_fill_viridis_c() 




# faster terra plot (hey, I thought plot was base)
# also doesn't force you to remember the name of
# the data layer
# all of a sudden this is funny:
plot(campus_DEM)

# Check CRS ####
# https://epsg.io/2874
crs(campus_DEM, proj = TRUE)
crs(campus_DEM)


# min and max values
minmax(campus_DEM)
# these are showing NaN now:
max(values(campus_DEM))

campus_DEM <- setMinMax(campus_DEM)

nlyr(campus_DEM)

str(campus_DEM)

# NAs tend to be the data
# that tends to be the part around the edges
# but they don't have to be.
ggplot() +
  geom_raster(data = campus_DEM_df, aes(x=x, y=y, fill = elevation)) +
  scale_fill_viridis_c(na.value = "deeppink") 


# We can maybe find one that doesn't have any to 
# demonstrate this as zero:
sum(is.na(campus_DEM_df$elevation))

# the lesson pulls in a rgb raster at this point:

######################

############
# challenge: look at a different raster's nodata values?
campus_bath <- rast("source_data/SB_bath.tif")
crs(campus_bath)
str(campus_bath)
colnames(campus_bath)

campus_bath_df <- as.data.frame(campus_bath, xy=TRUE, na.rm=FALSE)
str(campus_bath_df)

# does this one have NA's?
sum(is.na(campus_bath_df$SB_bath_2m))
summary(campus_bath)

# you betcha.
# 69366 of them

### bad data example goes here.
# both these warning messages tells us there's more going on.
# ie: values out of scale range
ggplot() +
  geom_histogram(data = campus_DEM_df, aes(elevation))

ggplot() +
  geom_histogram(data = campus_bath_df, aes(SB_bath_2m))

# crs() and str() don't tell us what bad data values are.

describe("source_data/SB_bath.tif")
# [61] "  NoData Value=nan" 
describe("source_data/campus_DEM.tif")
# [64] "  NoData Value=nan"


###################


# histogram to look at the elevation distribution

# for argument's sake, this should be a different dataset. 
# like a DSM instead of DEM??

ggplot() +
  geom_histogram(data = campus_DEM_df, aes(elevation))

ggplot() +
  geom_histogram(data = campus_DEM_df, aes(elevation), bins = 5)

ggplot() +
  geom_histogram(data = campus_DEM_df, aes(elevation), bins = 20)

# at some point, the negative values disappear from the visualization
# that's not helpful.


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

# there's sooooo few negative values that you can't see them.

ggplot() +
  geom_bar(data = campus_DEM_df, aes(binned_DEM))

# but think about landscapes. elevation tends to be
# a log. (I know this because I am a geographer)
# log scale works better
# this shows that there's nothing at zero.
# and a little bit of negative
ggplot() +
  geom_bar(data = campus_DEM_df, aes(binned_DEM)) +
  scale_y_continuous(trans='log10')

ggplot() + 
  geom_raster(data = campus_DEM_df, aes(x=x, y=y, fill = binned_DEM)) 


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
custom_bins <- c(-3, 4.9, 5.1, 7.5, 10, 25, 40, 70, 100, 150, 200)

campus_DEM_df <- campus_DEM_df %>% 
  mutate(binned_DEM = cut(elevation, breaks = custom_bins))
ggplot() + 
  geom_raster(data = campus_DEM_df, aes(x=x, y=y, fill = binned_DEM)) 
  



# this isn't so nice
ggplot() + 
  geom_raster(data = campus_DEM_df, aes(x=x, y=y, fill = binned_DEM)) +
  scale_fill_manual(values = terrain.colors(10)) 
  #coord_quickmap()

# let's seize control of our bins
coast_palette <- terrain.colors(10)

# set 4.9-5 ft a nice sea blue
coast_palette[2] <- "#1d95b3"
coast_palette[3] <- "#1c9aed"
coast_palette

# where's my nice blue?
ggplot() + 
  geom_raster(data = campus_DEM_df, aes(x=x, y=y, fill = binned_DEM)) +
  scale_fill_manual(values = coast_palette)
  #coord_quickmap()





# hillshade layer
#ok we have to do something here to make a hillshade
#since one doesn't exist

# insert script from map 7 here.

describe("source_data/campus_hillshade.tif")


campus_hillshade_df <- 
  rast("source_data/campus_hillshade.tif") %>% 
  as.data.frame(xy = TRUE)

campus_hillshade_df
str(campus_hillshade_df)

# plot the hillshade
ggplot() + 
  geom_raster(data = campus_hillshade_df, 
              aes(x=x, y=y, fill = hillshade)) +
  coord_quickmap()

# overlay
# not sure if this is displaying as desired
ggplot() + 
    geom_raster(data=campus_DEM_df, aes(x=x, y=y, fill = elevation)) +
    geom_raster(data = campus_hillshade_df, 
              aes(x=x, y=y, alpha = hillshade)) +
    scale_fill_viridis_c() + 
  ggtitle("Elevation and Hillshade") 
  #coord_quickmap()

# I'm not sure this graph does anything for us anymore
# it would if it displayed the red. 
ggplot() +
  geom_raster(data = campus_DEM_df, aes(x=x, y=y, fill = elevation)) +
  scale_fill_gradient2(na.value = "lightgray", 
                       low="red", 
                       mid="white", 
                       high="cornsilk3",
                       guide = "colourbar",
                        midpoint = 3.12, aesthetics = "fill") 
  #coord_quickmap()

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

