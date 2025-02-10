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


current_sheet <- 8

# make sure output window is 1x1
# because you muck with it a lot
par(mfrow = c(1,1))


library(planetR)
library(curl)

# (get_auth)
# plnt_quota

curl(url="https://api.planet.com/features/v1/ogc/my?format=api", open = "")
