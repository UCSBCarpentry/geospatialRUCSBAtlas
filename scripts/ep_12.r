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
# NDVI data gets calculated by map 12. 
ndvi_series_path <- list.files("output_data/ndvi", full.names = TRUE)

# build a raster stack
ndvi_series_stack <- rast(ndvi_series_path)

str(ndvi_series_stack)
summary(ndvi_series_stack[,1])

# make the data 4x smaller so everything is faster
ndvi_series_stack <- aggregate(ndvi_series_stack, fact=4, fun="mean")


# convert to a data frame
ndvi_series_df <- as.data.frame(ndvi_series_stack, xy=TRUE, na.rm=FALSE) %>% 
  pivot_longer(-(x:y), names_to = "variable", values_to= "value")
str(ndvi_series_df)


ggplot() +
  geom_raster(data = ndvi_series_df , aes(x = x, y = y, fill = value)) +
  facet_wrap(~ variable)

