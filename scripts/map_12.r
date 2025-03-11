# map 12
# let's build monthly NDVI's for campus
# as in episode 12 

# to answer the question:
# What month was the greenest?

# clean the environment and hidden objects
rm(list=ls())

# set map number
current_sheet <- 12
# set ggplot counter
current_ggplot <- 0

gg_labelmaker <- function(plot_num){
  gg_title <- c("Map:", current_sheet, " ggplot:", plot_num)
  plot_text <- paste(gg_title, collapse=" " )
  print(plot_text)
  current_ggplot <<- plot_num
  return(plot_text)
}


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
# for now we leave raster::bricks behind

# make an NDVI for 1 file
tiff_path <- c("source_data/planet/planet/20232024_UCSB_campus_PlanetScope/PSScene/")

# for reference, plot ONE of our 8 band files with
# semi-natural color
# this is PlanetScope

image <- rast(paste(tiff_path, "20230912_175450_00_2439_3B_AnalyticMS_SR_8b_clip.tif", sep=""))
# ala-episode 5
plotRGB(image, r=6,g=3,b=1, stretch = "hist")
image

summary(image)

# here is the NDVI calculation:
#(NIR - Red) / (NIR + Red)
ndvi_tiff <- ((image[[8]] - image[[6]]) / (image[[8]] + image[[6]]))*10000 

# plot(ndvi_tiff)
summary(values(ndvi_tiff))
str(ndvi_tiff)
class(ndvi_tiff)
str(ndvi_tiff$nir)
values(ndvi_tiff)

# convert to integer for speed
# this doesn't work
# ndvi_tiff <- as.integer(ndvi_tiff)


# not sure how the columns get named "NIR" 
# probably the first layer imported
# we will circle back to that
names(ndvi_tiff)
ndvi_tiff


# We need a common extent to 
# stack things up
# we'll use the original AOI from our Planet request:
ucsb_extent <- vect("source_data/planet/planet/ucsb_60sqkm_planet_extent.geojson")
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
# plot(ndvi_tiff)
ndvi_tiff


# extents are still different after extend:
ext(ucsb_extent) == ext(ndvi_tiff)

# so reset the extent back to the AOI
# extent object:
set.ext(ndvi_tiff, ext(ucsb_extent))


# now they are exactly the same extent
ext(ucsb_extent) == ext(ndvi_tiff)

#plot(ndvi_tiff)
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
scene_paths <- list.files("source_data/planet/planet/20232024_UCSB_campus_PlanetScope/PSScene/",
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
    source_image <- aggregate(source_image, fact = 4)
    ndvi_tiff <- ((source_image[[8]] - source_image[[6]]) / (source_image[[8]] + source_image[[6]]))
    new_filename <- (substr(images, 67,90))
    new_path <- paste("output_data/ndvi/", new_filename, ".tif", sep="")
    ndvi_tiff <- extend(ndvi_tiff, ucsb_extent, fill=NA, snap="near")
    set.ext(ndvi_tiff, ext(ucsb_extent))
    names(ndvi_tiff) <- substr(new_filename, 0,13)
    print(names(ndvi_tiff))
    print(new_filename)
    print(dim(ndvi_tiff))
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

# take a look at one. range of values looks realistic
ls("output_data/ndvi")

# these two lines are throwing an error that they dont exist 

testraster <- rast("output_data/ndvi/20230912_175450_00_243.tif")
summary(values(testraster))

# try this:
list.files("output_data/ndvi")
# it shows you are a digit off. 


# check the files's resolutions and 
# keep only the 2217x3541 ones.
# 554 x 885 now that we are downsampled
length(ndvi_series_names)
str(ndvi_series_names)
valid_tiff <- c(554,885,1)
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

# whooo hoooo! no errors 
str(ndvi_series_stack)
nlyr(ndvi_series_stack)
summary(values(ndvi_series_stack))

# they plot!:
# 20230427 still looks suspicious
plot(ndvi_series_stack)

#ggsave("images/ndvi_series_stack.png", plot=last_plot())



# duplicate column names / dates can be made
# this turns out to be a feature!
# need to put it back in later


# pivot
# comes from the lesson
# kristi changed the names of the columns here - bye variable
ndvi_series_df <- as.data.frame(ndvi_series_stack, xy=TRUE) %>% 
  pivot_longer(-(x:y), names_to = "image_date", values_to= "NDVI_value")

str(ndvi_series_df)
summary(ndvi_series_df)

str(ndvi_series_df)
unique(ndvi_series_df$variable)


### let's crop this and remake the dataframe so that the ggplot 
# facet_wrap runs in a reasonable amount of time.
ncos_extent <- vect("source_data/planet/planet/ncos_aoi.geojson")
ncos_extent <- project(ncos_extent, ndvi_series_stack)

ndvi_series_stack <- crop(ndvi_series_stack, ncos_extent)


# kristi changed names here too
ndvi_series_df <- as.data.frame(ndvi_series_stack, xy=TRUE, na.rm=FALSE) %>% 
  pivot_longer(-(x:y), names_to = "image_date", values_to= "NDVI_value")
str(ndvi_series_df)

# this output should be pretty speedy
# scales are correct!!!!
ggplot() +
  geom_raster(data = ndvi_series_df , aes(x = x, y = y, fill = NDVI_value)) +
  facet_wrap(~ image_date)

# we need a diverging color scheme
ggplot() +
  geom_raster(data = ndvi_series_df , aes(x = x, y = y, fill = NDVI_value)) +
  scale_fill_distiller(palette = "RdYlBu", direction = 1) +
  facet_wrap(~ image_date) +
  theme_minimal() +
  ggtitle(gg_labelmaker(current_ggplot+1))


# fix those facet labels!
# this is what it should look like:
str(ndvi_series_df)
year_month_label <- substr(ndvi_series_df$image_date, 2,9)
year_month_label

# now that we've tested, mutate here to add the new column:
ndvi_series_w_dates_df <- mutate(ndvi_series_df, yyyymmdd = substr(ndvi_series_df$image_date, 2,9))
ndvi_series_w_dates_df
str(ndvi_series_w_dates_df)

ggplot() +
  geom_raster(data = ndvi_series_w_dates_df , aes(x = x, y = y, fill = NDVI_value)) +
  scale_fill_distiller(palette = "RdYlBu", direction = 1) +
  facet_wrap(~ yyyymmdd) +
  theme_minimal() +
  ggtitle(gg_labelmaker(current_ggplot+1))


# maybe you were attempting to add the column here?
#ndvi_series_df$variable <- year_month_label
#ndvi_series_df$variable
#str(ndvi_series_df)




#mutate into year month day columns?
#use tidyr separate to split ymd into sep columns? 
#no delimiter so use positions? 


# attempted as.date(format = '%Y-%m-%d) but....
# also realized jd is not part of the metadata?

ndvi_names <- names(ndvi_series_df)
ndvi_names <- gsub("")

# repeat the above ggplot label each facet
# with only the first 8 characters of the variable
ggplot() +
  geom_raster(data = ndvi_series_df , aes(x = x, y = y, fill = value)) +
  scale_fill_distiller(palette = "RdYlBu", direction = 1) +
  facet_wrap(~ variable) +
  theme_minimal() +
  xlab("YY-MM") +
  ggtitle(gg_labelmaker(current_ggplot+1))



# visually there's nothing going on
# does my 'feature' about combining layers actually
# add values together as they are stacking up?
# visually these are subtle, so to find
# the 'greenest' months here, we can make
# histograms
# make bins
# OR figure the mean NDVI for each image as in ep 14.

# this default one shows us what?
# looks like April 2024 is the greenest:

ggplot(ndvi_series_df) +
  geom_histogram(aes(value)) + 
  facet_wrap(~variable) +
  ggtitle(gg_labelmaker(current_ggplot+1))



# display the binned histograms of the NDVIs
# we can use cut to make 10 bins

ndvi_series_binned_df <-  ndvi_series_df %>% 
  mutate(bins = cut(value, breaks=10)) 

ggplot(ndvi_series_binned_df) +
  geom_bar(aes(bins)) + 
  facet_wrap(~variable) +
  ggtitle(gg_labelmaker(current_ggplot+1))


# that's better. And shows us where we can make custom bins
summary(ndvi_series_binned_df)

local_ndvi_breaks <- c(-1, 0, .001, .01, .1, .11, .115, .2, 1)

ndvi_series_custom_binned_df <-  ndvi_series_df %>% 
  mutate(bins = cut(value, breaks=local_ndvi_breaks)) 

ggplot(ndvi_series_custom_binned_df, aes(x=bins)) +
  geom_bar() + 
  facet_wrap(~variable) +
  ggtitle(gg_labelmaker(current_ggplot+1))
# this is still a visual judgement call.


# this is the OR from above.
# visually we can't see the greenest, so 
# let's make a dataframe of average NDVI
# and plot them
# this is from ep. 14:
avg_NDVI <- global(ndvi_series_stack, mean, na.rm=TRUE)
## that passes the smell test! April and September(?)

str(avg_NDVI)
ncol(avg_NDVI)

ndvi_months <- c(row.names(avg_NDVI))
avg_NDVI <- mutate(avg_NDVI, months=ndvi_months)
str(avg_NDVI)

colnames(avg_NDVI) <- c("MeanNDVI", "Month")

avg_NDVI



avg_NDVI
summary(avg_NDVI)
str(avg_NDVI)

# here we go #############

# finally: a logical plot of average NDVIs over time. 
plot(avg_NDVI$MeanNDVI)

avg_NDVI_df <- as.data.frame(avg_NDVI, rm.na=FALSE)
str(avg_NDVI_df)

# we want the dates. or the
# 5th and 6th character of the dates


# thi# thi# this plot less so:
ggplot(avg_NDVI_df, mapping = aes(Month, MeanNDVI)) +
  geom_point()



# we need to arrange these by month to show change.
# Julian dates: that's in the lesson, mean()# Jugeom_point()# Julian dates: that's in the lesson, mean()# Julian dates: that's in the lesson, but ours uses calendar dates
# challenge: change object names to Julian dates





# What month was the Greenest?

# we'll need weather data to mimic the lesson.
# or use our brains and eyes to define 
# when was it rainiest?


current_sheet <- "Map 12 Complete"
current_sheet
