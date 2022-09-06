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
GDALinfo("output_data/campus_DEM.tif")

# make it into an object you can manipulate
campus_DEM <- raster("output_data/campus_DEM.tif")

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

ggplot() +
  geom_raster(data = campus_DEM_df, 
              aes(x=x, y=y, fill = campus_DEM)) +
  scale_fill_viridis_c() +
  coord_quickmap()

# faster base R plot
# also doesn't force you to remember the name of
# the data layer
plot(campus_DEM_df)



# let's rename the column so we don't have to keep typing
# greatercampusDEM_1_1
campus_DEM_df <- as.data.frame(campus_DEM_downsampled, xy=TRUE) %>% 
  rename(elevation = greatercampusDEM_1_1)

# now plot with that new name
# our new, smaller DEM_df maps quicker.
ggplot() +
  geom_raster(data = campus_DEM_df, 
              aes(x=x, y=y, fill = elevation)) +
  scale_fill_viridis_c() +
  coord_quickmap()

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
ggplot() +
  geom_bar(data = campus_DEM_df, aes(binned_DEM)) +
  scale_y_continuous(trans='log10')

ggplot() + 
  geom_raster(data = campus_DEM_df, aes(x=x, y=y, fill = binned_DEM)) +
  coord_quickmap()


# let's go again with what we've learned
custom_bins <- c(-3, 2, 3, 4, 5, 10, 25, 40, 70, 100, 200)

campus_DEM_df <- campus_DEM_df %>% 
  mutate(binned_DEM = cut(elevation, breaks = custom_bins))

ggplot() + 
  geom_raster(data = campus_DEM_df, aes(x=x, y=y, fill = binned_DEM)) +
  coord_quickmap()

# that's 10 bins. let's see what natural color looks like
terrain.colors(10)

# yuck! we can seize more control over this
# later
ggplot() + 
  geom_raster(data = campus_DEM_df, aes(x=x, y=y, fill = binned_DEM)) +
  scale_fill_manual(values = terrain.colors(10))
    coord_quickmap()


# hillshade layer

campus_hillshade_df <- 
  raster("output_data/hillshade.tiff") %>% 
  as.data.frame(xy = TRUE)

# plot the hillshade
ggplot() + 
  geom_raster(data = campus_hillshade_df, 
              aes(x=x, y=y, alpha = hillshade)) +
  scale_alpha(range = c(0.15, 0.65), guide = "none") +
  coord_quickmap()

# overlay
ggplot() + 
    geom_raster(data=campus_DEM_df, aes(x=x, y=y, fill = elevation)) +
    geom_raster(data = campus_hillshade_df, 
              aes(x=x, y=y, alpha = hillshade)) +
    scale_fill_viridis_c() + 
  scale_alpha(range = c(0.15, 0.65), guide = "none") +
  ggtitle("Elevation and Hillshade")
  coord_quickmap()



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
unique(campus_DEM_df$elevation)

# that's too many. let's count them up tidily
campus_DEM_df %>% 
  group_by(elevation) %>% 
  count()
# that's still too many. can I tighten the group?