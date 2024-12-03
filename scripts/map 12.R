# map 12
# let's build monthly NDVI's for campus
# as in episode 12 

# clean the environment and hidden objects
rm(list=ls())

library(scales)
library(tidyr)
library(dplyr)
library(ggplot2)
# library(raster)
library(terra)
library(geojsonsf) # to handle geojson
# library(sf) #<- to handle geojson (not geojsonsf? -KL)


# NDVIs were premade in the Carpentries lesson, but
# we already know enough raster math to make our
# own, as in 
# episode 4

# brick is raster. rast is terra
# the 2 different ndvis looks VERY different when
# you do this raster math
# for now we leave bricks behind
# image <- brick(tiff_path, n1=8)

# make an NDVI for 1 file
tiff_path <- c("source_data/UCSB_campus_23-24_psscene_analytic_8b_sr_udm2/PSScene/")

# for reference, plot one of our 8 band files with
# semi-natural color
image <- rast(paste(tiff_path, "20230912_175450_00_2439_3B_AnalyticMS_SR_8b_clip.tif", sep=""))
# ala-episode 5
plotRGB(image, r=6,g=3,b=1, stretch = "hist")
image

summary(image)

# here is the NDVI calculation:
#(NIR - Red) / (NIR + Red)
ndvi_tiff <- ((image[[8]] - image[[6]]) / (image[[8]] + image[[6]]))

plot(ndvi_tiff)
summary(values(ndvi_tiff))

# not sure how the columns get named "NIR" 
# probably the first layer imported
# we will circle back to that
names(ndvi_tiff)
ndvi_tiff


# We need a common extent to make
# a raster stack
# we'll use the original AOI from our Planet request:
ucsb_extent <- vect("source_data/ucsb_60sqkm_planet_extent.geojson")
str(ucsb_extent)
crs(ucsb_extent)
crs(image) # <---- we want to standardize on this CRS
crs(ndvi_tiff)

# go ahead and assign it:
ucsb_extent <- project(x=ucsb_extent, y=image)
crs(ucsb_extent)

# the CRSs are now the same
crs(ucsb_extent) == crs(image)

# but the extents are different
ext(ucsb_extent) == ext(image)
ext(ucsb_extent) == ext(ndvi_tiff)


# I need to extend my calculated NDVI to the AOI extent
ndvi_tiff <- extend(ndvi_tiff, ucsb_extent)
plot(ndvi_tiff)
ndvi_tiff


# extents are still different after extend:
ext(ucsb_extent) == ext(ndvi_tiff)

# so reset the extent back to the AOI
# extent object:
set.ext(ndvi_tiff, ext(ucsb_extent))


# now they are exactly the same extent
ext(ucsb_extent) == ext(ndvi_tiff)

plot(ndvi_tiff)
dim(ndvi_tiff)
str(ndvi_tiff)
names(ndvi_tiff)

# this works in ggplot too
ndvi_tiff_df <- as.data.frame(ndvi_tiff, xy=TRUE) %>% 
  pivot_longer(-(x:y), names_to = "variable", values_to= "value")

str(ndvi_tiff_df)

ggplot() +
  geom_raster(data = ndvi_tiff_df , aes(x = x, y = y, fill = value)) 




# load 23-24 8-band rasters
# loop over the files and build a raster stack

# get a file list
# ep 12
scene_paths <- list.files("source_data/UCSB_campus_23-24_psscene_analytic_8b_sr_udm2/PSScene",
                          full.names = TRUE,
                          pattern = "8b_clip.tif")

# someplace to put our images
dir.create("output_data/ndvi", showWarnings = FALSE)


# calculate the NDVIs 
# and fill in (extend) to the AOI
# loop
# this takes a while
for (images in scene_paths) {
    source_image <- rast(images)
    ndvi_tiff <- ((source_image[[8]] - source_image[[6]]) / (source_image[[8]] + source_image[[6]])) %>% 
      round(2)
    new_filename <- (substr(images, 67,92))
    new_path <- paste("output_data/ndvi/", new_filename, ".tif", sep="")
    ndvi_tiff <- extend(ndvi_tiff, ucsb_extent, fill=NA, snap="near")
    set.ext(ndvi_tiff, ext(ucsb_extent))
    names(ndvi_tiff) <- substr(new_filename, 0,14)
    print(names(ndvi_tiff))
    print(new_filename)
    print(dim(ndvi_tiff))
#    plot(ndvi_tiff)
    writeRaster(ndvi_tiff, new_path, overwrite=TRUE)
        }



# 3 or 4 of the resulting tiffs are wonky
# their dimensions are wildly off.
# but almost all of them are 2217 x 3541 pixels
# let's get rid of the ones that aren't:

# # get a list of the new files:
ndvi_series_names <- list.files("output_data/ndvi")
ndvi_series_names <- paste("output_data/ndvi/", ndvi_series_names, sep="")

ndvi_series_names
testraster <- rast("output_data/ndvi/20230912_175450_00_2439_3B.tif")
summary(values(testraster))


# check the files's resolutions and 
# keep only the 2217x3541 ones.
length(ndvi_series_names)
str(ndvi_series_names)
valid_tiff <- c(2217,3541,1)
str(valid_tiff)

dim(ndvi_tiff) == valid_tiff
test <- rast(ndvi_series_names[1])
str(test)
str(dim(test))

# delete any files that aren't the standard 
# resolution
for (image in ndvi_series_names) {
  test_size <- rast(image)
  # length 1 qualifier 
   test_result <- (dim(test_size) == valid_tiff)
   print(test_result)  
  ifelse((dim(test_size) == valid_tiff), print("A match!!!"), file.remove(image))
}

# reload the names
ndvi_series_names <- list.files("output_data/ndvi")
ndvi_series_paths <- paste("output_data/ndvi/", ndvi_series_names, sep="")

# now we can see there are 4 fewer tiffs.
length(ndvi_series_names)

# now we can build a raster stack with no errors
ndvi_series_stack <- rast(ndvi_series_paths)

summary(ndvi_series_stack[,1])

# whooo hoooo! no errors ... but ...
str(ndvi_series_stack)
nlyr(ndvi_series_stack)
# but it's crapped out:
summary(values(ndvi_series_stack))
# or is it:
plot(ndvi_series_stack)

# duplicate column names / dates can be made
# this turns out to be a feature!
# need to put it back in later


# pivot
# comes from the lesson
ndvi_series_df <- as.data.frame(ndvi_series_stack, xy=TRUE) %>% 
  pivot_longer(-(x:y), names_to = "variable", values_to= "value")

str(ndvi_series_df)
summary(ndvi_series_df)

str(ndvi_series_df)
unique(ndvi_series_df$variable)
unique(ndvi_series_df$value)

# this output is really slow
ggplot() +
  geom_raster(data = ndvi_series_df , aes(x = x, y = y, fill = value)) +
  facet_wrap(~ variable)



# visually there's nothing going on
# does my 'feature' about combining layers actually
# add values together as they are stacking up?
# visually these are subtle, so to find
# the 'greenest' months here, we can make
# histograms
# make bins
# OR figure the mean NDVI for each image as in ep 14.

# this default one shows us what?
# a fatter and pretty tall April?
ggplot(ndvi_series_df) +
  geom_histogram(aes(value)) + 
  facet_wrap(~variable)


# display the binned histograms of the NDVIs
# we can use cut to make 10 bins

ndvi_series_binned_df <-  ndvi_series_df %>% 
  mutate(bins = cut(value, breaks=10)) 

ggplot(ndvi_series_binned_df) +
  geom_bar(aes(bins)) + 
  facet_wrap(~variable)

# that's better. And shows us where we can make custom bins
summary(ndvi_series_binned_df)

local_ndvi_breaks <- c(-1, 0, .001, .01, .1, .11, .115, .2, 1)

ndvi_series_custom_binned_df <-  ndvi_series_df %>% 
  mutate(bins = cut(value, breaks=local_ndvi_breaks)) 

ggplot(ndvi_series_custom_binned_df, aes(x=bins)) +
  geom_bar() + 
  facet_wrap(~variable)
# this is still a visual judgement call.


# this is the OR from above.
# visually we can't see the greenest, so 
# let's make a dataframe of average NDVI
# and plot them
avg_NDVI <- global(ndvi_series_stack, mean, na.rm=TRUE)

## that passes the smell test! April and September(?)
avg_NDVI

str(avg_NDVI)
plot(avg_NDVI$mean)

# need to access the row names.
row.names(avg_NDVI)

ndvi_months <- c(row.names(avg_NDVI))
avg_NDVI <- mutate(avg_NDVI, months=ndvi_months)
str(avg_NDVI)

avg_NDVI
summary(avg_NDVI)


# I just can't get these to plot logically.
plot(avg_NDVI)
ggplot(avg_NDVI, aes(x=months, y=mean) +
    geom_point())




# Julian dates: that's in the lesson, mean()# Julian dates: that's in the lesson, but ours uses calendar dates
# challenge: change object names to Julian dates

# What month was the Greenest?

# we'll need weather data to mimic the lesson.
# or use our brains and eyes to define 
# when was it rainiest?