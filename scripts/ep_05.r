# episode 5
# multi-band rasters
# ie: color

# clean the environment and hidden objects
rm(list=ls())


library(terra)
library(tidyverse)
# library(sf)
library(raster)

current_episode <- 5

# make our ggtitles automagically #######
# set ggplot counter
current_ggplot <- 0

gg_labelmaker <- function(plot_num){
  gg_title <- c("Episode:", current_episode, " ggplot:", plot_num)
  plot_text <- paste(gg_title, collapse=" " )
  print(plot_text)
  current_ggplot <<- plot_num
  return(plot_text)
}
# every ggtitle should be:
# ggtitle(gg_labelmaker(current_ggplot+1))
# end automagic ggtitle           #######





# do we still need raster in this lesson?
# yes. for now. 
natural_color <- raster("source_data/cirgis_1ft/w_campus_1ft.tif")
natural_color_terra <- rast("source_data/cirgis_1ft/w_campus_1ft.tif")



#This is Planet
planet_NCOS <- rast("source_data/planet/planet/2025-01-12_SkySat/20250112_185234_35_24f9_3B_AnalyticMS_8b_clip.tif")


# can do the quickplot, it's very mysterious
plot(planet_NCOS)
plot(natural_color)
plot(natural_color_terra)


str(natural_color)
class(natural_color)

# outputting it to stdout shows how
# many bands (5 and 4).
natural_color
planet_NCOS

# brick is from raster
# a brick is a new class for us
# nl is the number of layers it should expect.
natural_color_brick <- brick("source_data/cirgis_1ft/w_campus_1ft.tif")
natural_color_brick

plotRGB(natural_color_brick)


# we also have raster stack
natural_color_stack <- stack("source_data/cirgis_1ft/w_campus_1ft.tif")

planet_NCOS_stack <- stack("source_data/planet/planet/2025-01-12_SkySat/20250112_185234_35_24f9_3B_AnalyticMS_8b_clip.tif")

# still has 5 channels
natural_color_stack

# has 8 channels
planet_NCOS_stack

# plotRGB(NCOS, r=1, g=2, b=3)

str(natural_color)

# plotRGB is for stacks
plotRGB(natural_color_stack)

plotRGB(natural_color_stack, stretch = "lin")
plotRGB(natural_color_stack, stretch = "hist")


plotRGB(natural_color_stack,
        r = 1,
        g = 2, 
        b = 3)

plotRGB(natural_color_stack,
        r = 2,
        g = 3, 
        b = 4)

plotRGB(natural_color_stack,
        r = 3,
        g = 4, 
        b = 5)

plotRGB(natural_color_stack,
        r = 3,
        g = 2, 
        b = 1)

# the metadata shows 5 bands. How 
# about nodata value?

# as we did in ep. 1
# we can use >describe<
describe("source_data/w_campus_1ft/w_campus_1ft.tif")

# SpatRasterDataset
# comes from terra
natural_color_sds <- sds(natural_color_terra)

# later we will stack up some SkySat imagery into a time series.


# ##################################
# take 2
# Alternate path preparing better for
# episode 12
# we can do this with SkySat!
# SkySatPanSharp_B <- brick("source_data/SkySatCollect/20161210_185631_ssc3_u0001_pansharpened_clip.tif")
# SkySatPanSharp_S <- stack("source_data/SkySatCollect/20161210_185631_ssc3_u0001_pansharpened_clip.tif")


# stdout shows 4 bands
# plotRGB(SkySatPanSharp_B, r=1, g=2, b=3, scale=1932)
