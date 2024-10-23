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
# for now we leave bricks behind
# image <- brick(tiff_path, n1=8)

image <- rast(tiff_path)
plotRGB(image, r=6,g=3,b=1, stretch = "hist")
image

# here is the NDVI calculation:
#(NIR - Red) / (NIR + Red)
ndvi_tiff <- (image[[8]] - image[[6]] / image[[8]] + image[[6]])

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

# let's set up a better colorscheme for our later ggplots
ndvi_tiff_df <- as.data.frame(ndvi_tiff, xy=TRUE) %>% 
  pivot_longer(-(x:y), names_to = "variable", values_to= "value")

str(ndvi_tiff_df)

ggplot() +
  geom_raster(data = ndvi_tiff_df , aes(x = x, y = y, fill = value)) +
  scale_fill_viridis_c(option="D")





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
    new_path <- paste("output_data/ndvi/", new_filename, ".tif", sep="")
    ndvi_tiff <- extend(ndvi_tiff, ucsb_extent, snap="near")
    set.ext(ndvi_tiff, ext(ucsb_extent))
    names(ndvi_tiff) <- substr(new_filename, 0,8)
    print(names(ndvi_tiff))
    print(new_filename)
    print(dim(ndvi_tiff))
    plot(ndvi_tiff)
    writeRaster(ndvi_tiff, new_path, overwrite=TRUE)
        }

# 3 or 4 of the resulting tiffs are wonky
# their dimensions are wildly off.
# but almost all of them are 2217 x 3541 pixels
# let's get rid of the ones that aren't:

# # get a list of the new files:
ndvi_series_names <- list.files("output_data/ndvi")
ndvi_series_names <- paste("output_data/ndvi/", ndvi_series_names, sep="")

#check
length(ndvi_series_names)
str(ndvi_series_names)
valid_tiff <- c(2217,3541,1)
str(valid_tiff)

dim(ndvi_tiff) == valid_tiff
test <- rast(ndvi_series_names[1])
str(test)
str(dim(test))

# delete any files that arent't the standard 
# resolution
for (image in ndvi_series_names) {
  test_size <- rast(image)
  print(image)
  #  print(dim(test_size))
#  print(str(dim(test_size)))
# length 1 qualifier 
  test_result <- (dim(test_size) == valid_tiff)
  print(test_result)  
  ifelse((dim(test_size) == valid_tiff), print("A match!!!"), file.remove(image))
}

# reload the names
ndvi_series_names <- list.files("output_data/ndvi")
ndvi_series_paths <- paste("output_data/ndvi/", ndvi_series_names, sep="")
length(ndvi_series_names)

# build raster stack with no errors
ndvi_series_stack <- rast(ndvi_series_paths)

# whooo hoooo!
str(ndvi_series_stack)
nlyr(ndvi_series_stack)
names(ndvi_series_stack)

# one raster has outliers. NDVI = 71000
summary(values(ndvi_series_stack))

plot(ndvi_series_stack)

# pivot
# comes from the lesson
# and because we are pivoting on the dates, multiple
# rasters will get graphed together:
ndvi_series_df <- as.data.frame(ndvi_series_stack, xy=TRUE) %>% 
  pivot_longer(-(x:y), names_to = "variable", values_to= "value")

str(ndvi_series_df)
unique(ndvi_series_df$variable)


# this output is really dark.
ggplot() +
  geom_raster(data = ndvi_series_df , aes(x = x, y = y, fill = value)) +
  facet_wrap(~ variable)

# we need to scale our output.
# looks like by 100000
summary(ndvi_series_df$value)
ndvi_series_stack <- ndvi_series_stack/100000

# remake our dataframe:
ndvi_series_df <- as.data.frame(ndvi_series_stack, xy=TRUE) %>% 
  pivot_longer(-(x:y), names_to = "variable", values_to= "value")

# newly scaled plot, NDVI = 0:1
# and a new color scheme
# this is slow and the color scheme didn't work.
ggplot() +
  geom_raster(data = ndvi_series_df , aes(x = x, y = y, fill = value)) +
  scale_color_gradient(low="red", high="green") +
  facet_wrap(~ variable)

# visually these are subtle, so to find
# the 'greenest' months here, we can make
# histograms
# make bins

# display the binned histograms of the NDVIs

# Julian dates: that's in the lesson, but ours uses calendar dates
# challenge: change object names to Julian dates

# What month was the Greenest?

# we'll need weather data

# when was it rainiest?