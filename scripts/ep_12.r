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
# path to files:
skySatPath <- "source_data/SkySatCollect"
passes <- list.files(skySatPath, 
                     recursive = TRUE, 
                     pattern = ".tif$")  
passes

# which tifs are the ones we want?
# the first in each sequence of 3!
passes_1 <- rast(paste(skySatPath, passes[1], sep='//'))
passes_2 <- rast(paste(skySatPath, passes[2], sep='//'))
passes_3 <- rast(paste(skySatPath, passes[3], sep='//'))

passes_1
passes_2
passes_3

# which tifs are the ones we want?
plotRGB(passes_1, r = 1,  g = 2, b = 3, scale=1932)
plotRGB(passes_2, r = 1,  g = 2, b = 3, scale=1932)
plotRGB(passes_3, r = 1,  g = 2, b = 3, scale=1932)
# the other two are alpha and a stack
# of 8 attributes

passes
# we want every third one, starting at #1
# could probably make a regex, but ...
# let's try a look.....
loop_index <- c(1,4,7,10,13)
# transformation is a SpatRasterDataset that turns out
# to have 4 SpatRasters inside of it.
transformation <- sds()
for (x in loop_index)
{
  name <- passes[x]
  name <- rast(paste(skySatPath, passes[x], sep='//'))  
  name
  transformation <- sds(transformation, c(name))
} 
transformation
str(transformation)
# I got the loop, but I can't figure out how to add a SpatRaster
# to a SpatRasterDataset so ...

# make the rasts one at a time?
rast1 <- rast("source_data/SkySatCollect/20161210_185631_ssc3_u0001_pansharpened_clip.tif")
rast2 <- rast("source_data/SkySatCollect/20190630_184548_ssc2_u0003_pansharpened_clip.tif")
rast3 <- rast("source_data/SkySatCollect/20191212_183345_ssc2_u0001_pansharpened_clip.tif")
rast4 <- rast("source_data/SkySatCollect/20220627_214052_ssc7_u0001_pansharpened_clip.tif")

# nope. extents don't match
transformation <- sds(rast1, rast2, rast4)
# by trial and error I figured out it was
# 3 that didn't match.

rast1
plotRGB(rast1, 1,2,3, scale=1932)

setMinMax(rast2)
rast2
plotRGB(rast2, 1,2,3, scale=2486)

setMinMax(rast3)
rast3
plotRGB(rast3, 1,2,3, scale=3465)

setMinMax(rast4)
rast4
plotRGB(rast4, 1,2,3, scale=6385)
