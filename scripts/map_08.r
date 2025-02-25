# map 8 actually
# multi-band imagery
# and connecting to the Planet API

# for the episode about RGBs and multi-band rasters
# episode 5

library(terra)


library(geojsonsf)
library(sf)
library(ggplot2)
library(tidyterra)
library(dplyr)
# needed to lay out multiple ggplots
library(cowplot)
library(ggpubr)


# set map number
current_sheet <- 8
# set ggplot counter
current_ggplot <- 0

gg_labelmaker <- function(plot_num){
  gg_title <- c("Map:", current_sheet, " ggplot:", plot_num)
  plot_text <- paste(gg_title, collapse=" " )
  print(plot_text)
  current_ggplot <<- plot_num
  return(plot_text)
}


# make sure output window is 1x1
# because you muck with it a lot
par(mfrow = c(1,1))


# library(planetR)
library(curl)

# (get_auth)
# plnt_quota

curl(url="https://api.planet.com/features/v1/ogc/my?format=api", open = "")
