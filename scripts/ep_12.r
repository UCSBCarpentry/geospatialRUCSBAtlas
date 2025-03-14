# episode 12: time series rasters
library(terra)
library(scales)
library(tidyverse)
library(ggplot2)

# clean the environment and hidden objects
rm(list=ls())

current_episode <- 12


getwd()

# make a list of all your tiffs
# these little NDVIs get calculated by map 12.
#    --make sure you have run map 12 
ndvi_series_path <- list.files("output_data/ndvi", full.names = TRUE)

# build a raster stack
ndvi_series_stack <- rast(ndvi_series_path)

# challenge: what are the x,y resolutions?
# what units are the resolution in?
yres(ndvi_series_stack)
xres(ndvi_series_stack)
# fun! we don't have square pixels.


str(ndvi_series_stack)
summary(ndvi_series_stack[,1])

# convert to a data frame
ndvi_series_df <- as.data.frame(ndvi_series_stack, xy=TRUE, na.rm=FALSE) %>% 
  pivot_longer(-(x:y), names_to = "date", values_to= "value")
str(ndvi_series_df)

# unlike in the lesson, our NDVIs go from -1 to 1, like they are supposed to
# so scale factors are not necessary.
ggplot() +
  geom_raster(data = ndvi_series_df , aes(x = x, y = y, fill = value)) +
  facet_wrap(~ date)

# View Distribution of Raster Values

# Explore Unusual Data Patterns
# by comparing to weather data
# which we can get here: 
# https://files.countyofsb.org/pwd/hydrology/historic%20data/rainfall/XLS%20Dailys/200dailys.xls

# change dates from characters to dates

# plot daily precipation for 2023-2024

# Challenge: examine RGB raster files
# What explains our NDVI big changes?