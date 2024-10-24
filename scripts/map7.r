# map 7
# an alternate to map 1
# for the bottom of the page on map 3


library(terra)


library(geojsonsf)
library(sf)
library(ggplot2)
library(tidyterra)
library(dplyr)
# needed to lay out multiple ggplots
library(cowplot)
library(ggpubr)


# make sure output window is 1x1
# because you muck with it a lot
par(mfrow = c(1,1))


library(planetR)
library(curl)

(get_auth)
plnt_quota

curl(url="https://api.planet.com/features/v1/ogc/my?format=api", open = "")
