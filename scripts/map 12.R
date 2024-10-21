# map 12
# let's build monthly NDVI's for campus
# as in episode 12 

library(scales)
library(tidyr)
library(ggplot2)
# library(raster)
library(terra)
library(geojsonsf) # to handle geojson
# library(sf) #<- to handle geojson (not geojsonsf? -KL)


# NDVIs were premade in the Carpentries lesson, but
# we already know enough raster math to make our
# own


# make an NDVI for 1 file
tiff_path <- c("source_data/UCSB_campus_23-24_psscene_analytic_8b_sr_udm2/PSScene/20230912_175450_00_2439_3B_AnalyticMS_SR_8b_clip.tif")

# brick is raster. rast is terra
# the 2 different ndvis looks VERY different when
# you do this raster math

# image <- brick(tiff_path, n1=8)
image <- rast(tiff_path)
plotRGB(image, r=6,g=3,b=1, stretch = "hist")
image

# here is the NDVI calculation:
#(NIR - Red) / (NIR + Red)
ndvi_tiff <- (image[[8]] - image[[6]] / image[[8]] + image[[6]])

plot(ndvi_tiff)
# not sure how the columns get named "NIR" 
# probably the first layer imported:
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

# bingo
set.ext(ndvi_tiff, ext(ucsb_extent))

# put it on there again:
# don:t do this 
# ndvi_tiff <- ext(ucsb_extent)

ext(ndvi_tiff)<-ext(ucsb_extent)

# now they are exactly the same extent
ext(ucsb_extent)
str(ucsb_extent)

ext(ndvi_tiff)

plot(ndvi_tiff)
# now they are exactly the same extent
ext(ucsb_extent) == ext(ndvi_tiff)

(ndvi_tiff)


# load 23-24 8-band rasters
# loop over the files and build a raster stack

# get a file list
scene_paths <- list.files("source_data/UCSB_campus_23-24_psscene_analytic_8b_sr_udm2/PSScene",
                          full.names = TRUE,
                          pattern = "8b_clip.tif")

# someplace to put our images
dir.create("output_data/ndvi", showWarnings = FALSE)


# calculate the NDVIs 
# and fill in (extend) to the AOI
# loop
for (images in scene_paths) {
    source_image <- rast(images)
    ndvi_tiff <- (source_image[[8]] - source_image[[6]] / source_image[[8]] + source_image[[6]])
    new_filename <- (substr(images, 67,92))
    new_filename <- paste("output_data/ndvi/", new_filename, ".tif", sep="")
    ndvi_tiff <- extend(ndvi_tiff, ucsb_extent, snap="near")
    set.ext(ndvi_tiff, ext(ucsb_extent))
    print(new_filename)
    print(dim(ndvi_tiff))
    # plot(ndvi_tiff)
    writeRaster(ndvi_tiff, new_filename, overwrite=TRUE)
        }



# # get a list of the new files:
ndvi_series_names <- list.files("output_data/ndvi")
ndvi_series_names <- paste("output_data/ndvi/", ndvi_series_names, sep="")

#check
length(ndvi_series_names)
str(ndvi_series_names)



# build raster stack
ndvi_series_stack <- rast(ndvi_series_names)
ndvi_series_stack <- c(ndvi_series_names)

# again: brick is outdated
# ndvi_series_stack <- brick(ndvi_series_names, n1=20)

# throws an error here, even if you hand-delete the non=conforming tiffs
ndvi_series_df <- as.data.frame(ndvi_series_stack, xy=TRUE) %>% 
  pivot_longer(-(x:y), names_to = "variable", values_to= "value")



ggplot() +
  geom_raster(data = ndvi_series_df , aes(x = x, y = y, fill = value)) +
  facet_wrap(~ variable)

# make bins

# display the binned histograms of the NDVIs

# Julian dates: that's in the lesson, but ours uses calendar dates
# challenge: change object names to Julian dates

# What month was the Greenest?

# we'll need weather data

# when was it rainiest?