# map 4-5-6 is a tryptic,
# that runs across the top of map 3
# zooming in to campus
# the zoom to Cali locator sheet

# the 3 maps are a grayscale alpha hillshades
# over DEMs, just as in the overlay
# episode of the canonical episode

# we crop the rasters before reprojecting them.
# because that's faster

# clean the environment and hidden objects
rm(list=ls())

library(terra)
library(geojsonsf)
library(sf)
library(ggplot2)
library(tidyterra)
library(dplyr)
library(ggpubr)
library(raster)

# make sure output window is 1x1
# because you muck with it a lot
par(mfrow = c(1,1))

# We'll need a grayscale palette later
grays <- colorRampPalette(c("black", "white"))(255)

# set map number
current_sheet <- 4
# set ggplot counter
current_ggplot <- 0

# our auto ggtitle maker
gg_labelmaker <- function(plot_num){
  gg_title <- c("Map:", current_sheet, " ggplot:", plot_num)
  plot_text <- paste(gg_title, collapse=" " )
  print(plot_text)
  current_ggplot <<- plot_num
  return(plot_text)
}

# set up a local CRS to use throughout
campus_DEM <- rast("source_data/campus_DEM.tif") 
campus_crs = crs(campus_DEM)
str(campus_crs)



# #####################
# Map 4
# Zoom 1: west US overview
# this one arrived as a hillshade.
# we will also need a DEM to match
world <- rast("source_data/global_raster/GRAY_HR_SR_OB.tif")
plot(world)

# clip first
# using an AOI we defined in Planet
zoom_1_extent <- geojson_sf("source_data/cali_overview.geojson")
zoom_1_extent <- vect(zoom_1_extent)
zoom_1_extent <- project(zoom_1_extent, crs(world))

zoom_1 <- crop(x=world, y=zoom_1_extent)

plot(zoom_1)



# ############################
# Map 5
# Zoom 2
# Bite of California

# Crop western region hillshade to our local region defined by 
# socal_aoi.geojson
zoom_2 <- rast("source_data/dem90_hf/dem90_hf.tif")
plot(zoom_2)

# this geojson is the extent we want to crop to
# extent geojson came from planet
zoom_2_crop_extent <- geojson_sf("source_data/socal_aoi.geojson")
zoom_2_crop_extent <- vect(zoom_2_crop_extent)

crs(zoom_2_crop_extent) == crs(zoom_2)

# project it to match west_us
zoom_2_crop_extent <- project(zoom_2_crop_extent, crs(zoom_2))
crs(zoom_2_crop_extent) == crs(zoom_2)

# now you can plot them together
# to confirm that's the correct extent
# that you want to crop to
plot(zoom_2)
polys(zoom_2_crop_extent)

# now crop to that extent
zoom_2_cropped <- crop(x=zoom_2, y=zoom_2_crop_extent)
plot(zoom_2_cropped)
crs(zoom_2_cropped)

# now we can start to use the extent of the campus_DEM
# for our closest zoom indicator
zoom_3_extent <- ext(campus_DEM)
zoom_3_extent <- vect(zoom_3_extent)
crs(zoom_3_extent)

set.crs(zoom_3_extent, crs(campus_DEM))
plot(zoom_3_extent)

crs(zoom_3_extent) == crs(zoom_2_cropped)

zoom_3_extent <- project(zoom_3_extent, crs(zoom_2_cropped))
crs(zoom_3_extent) == crs(zoom_2_cropped)

plot(zoom_2_cropped)
polys(zoom_3_extent, border="red", lwd=4)


# we now need a hillshade of the area to match:
# make zoom 2 into a hillshade
# hillshades are made of slopes and aspects
zoom_2_slope <- terrain(zoom_2_cropped, "slope", unit="radians")
plot(zoom_2_slope)
zoom_2_aspect <- terrain(zoom_2_cropped, "aspect", unit="radians")
plot(zoom_2_aspect)
zoom_2_hillshade <- shade(zoom_2_slope, zoom_2_aspect,
                          angle = 15,
                          direction = 270,
                          normalize = TRUE)

plot(zoom_2_hillshade)
polys(zoom_3_extent, border="red", lwd=4)

# ###########################
# Map 6
# Zoom 3: UCSB & Environs

plot(campus_DEM)

zoom_3 <- rast("source_data/campus_hillshade.tif")
plot(zoom_3, col = grays)



# ##########################
# do all the AOI polygons work with 
# the hillshades?
# make sure everything is in campus_CRS

# zoom 1: 
zoom_1 <- project(zoom_1, campus_crs)
campus_crs
crs(zoom_2_crop_extent)
zoom_2_crop_extent <- project(zoom_2_crop_extent, campus_crs)

plot(zoom_1, col = grays)
polys(zoom_2_crop_extent, border="red",lwd=5)

# zoom 2:
plot(zoom_2_hillshade, col = grays)
polys(zoom_3_extent, border="red", lwd=5)

# zoom 3:
# doesn't have a locator


# now we do it all again with ggplot
# and alphas
#################################################

# zoom 1 hillshade as ggplot
str(zoom_1)
zoom_1_df <- as.data.frame(zoom_1, xy=TRUE)
colnames(zoom_1_df)

zoom_1_plot <- ggplot() +
  geom_raster(data = zoom_1_df,
              aes(x=x, y=y, fill=GRAY_HR_SR_OB)) +
  scale_fill_continuous() +
  theme_dark() +
  coord_sf(crs=campus_crs) + 
  ggtitle(gg_labelmaker(current_ggplot+1), subtitle = "California")

zoom_1_plot

# overlay the AOI
zoom_1_plot <- ggplot() +
  geom_raster(data = zoom_1_df,
              aes(x=x, y=y, fill=GRAY_HR_SR_OB)) +
  geom_spatvector(data=zoom_2_crop_extent, color="red", fill=NA) +
  theme(axis.title.x=element_blank(), axis.title.y=element_blank(), legend.position="none") +
  coord_sf(crs=campus_crs) + 
  ggtitle(gg_labelmaker(current_ggplot+1), subtitle = "Zoom 1: California")

zoom_1_plot

# next you'll add the DEM
# we may not keep the blue color scheme


#################################################
# zoom 2 as ggplot
plot(zoom_2_hillshade)
polys(zoom_3_extent, border="red", lwd=2)

zoom_2_DEM_df <- as.data.frame(zoom_2_cropped, xy=TRUE)
colnames(zoom_2_DEM_df)

zoom_2_hillshade_df <- as.data.frame(zoom_2_hillshade, xy=TRUE)
colnames(zoom_2_hillshade_df)


# ggplot the hillshade
zoom_2_plot <- ggplot() +
  geom_raster(data = zoom_2_hillshade_df,
              aes(x=x, y=y, alpha=hillshade)) +
    scale_alpha(range = c(0.05, 0.5), guide="none") +
    geom_spatvector(data=zoom_3_extent, color="red", fill=NA) +
  theme(axis.title.x=element_blank(), axis.title.y=element_blank(), legend.position="none") +
  coord_sf() + 
  ggtitle(gg_labelmaker(current_ggplot+1), subtitle = "Bite of California hillshade")
zoom_2_plot

# ggplot the DEM
zoom_2_plot <- ggplot() +
  geom_raster(data = zoom_2_DEM_df,
              aes(x=x, y=y, fill=dem90_hf)) +
  scale_fill_viridis_c() +
  geom_spatvector(data=zoom_3_extent, color="red", fill=NA) +
  theme(axis.title.x=element_blank(), axis.title.y=element_blank(), legend.position="none") +
  coord_sf() + 
  ggtitle(gg_labelmaker(current_ggplot+1), subtitle = "Bite of California w DEM")
zoom_2_plot


# now overlay
zoom_2_plot <- ggplot() +
  geom_raster(data = zoom_2_DEM_df,
              aes(x=x, y=y, fill=dem90_hf)) +
  scale_fill_viridis_c() +
  geom_raster(data = zoom_2_hillshade_df,
              aes(x=x, y=y, alpha=hillshade)) +
  scale_alpha(range = c(0.05, 0.5), guide="none") +
  geom_spatvector(data=zoom_3_extent, color="red", fill=NA) +
  theme(axis.title.x=element_blank(), axis.title.y=element_blank(), legend.position="none") +
  coord_sf() + 
  ggtitle(gg_labelmaker(current_ggplot+1), subtitle = "Bite of California w DEM")
zoom_2_plot



#################################################
# zoom3 as ggplot
# this one isn't a hillshade
# but we have a hillshade available

campus_hillshade <- rast("source_data/campus_hillshade.tif") 
zoom_3_hillshade_df <- as.data.frame(campus_hillshade, xy=TRUE)
colnames(zoom_3_hillshade_df)

# ggplot the hillshade
zoom_3_plot <- ggplot() +
  geom_raster(data = zoom_3_hillshade_df,
              aes(x=x, y=y, alpha=hillshade)) +
  scale_alpha(range = c(0.05, 0.5), guide="none") +
  theme(axis.title.x=element_blank(), axis.title.y=element_blank(), legend.position="none") +
  coord_sf() + 
  ggtitle(gg_labelmaker(current_ggplot+1), subtitle = "Campus hillshade")
zoom_3_plot

# ggplot the DEM
zoom_3_DEM_df <- as.data.frame(campus_DEM, xy=TRUE)
str(zoom_3_DEM_df)

zoom_3_plot <- ggplot() +
  geom_raster(data = zoom_3_DEM_df,
              aes(x=x, y=y, fill=greatercampusDEM_1_1)) +
  scale_fill_viridis_c() +
  theme(axis.title.x=element_blank(), axis.title.y=element_blank(), legend.position="none") +
  coord_sf() + 
  ggtitle(gg_labelmaker(current_ggplot+1), subtitle = "UCSB DEM")
zoom_3_plot

# now overlay
crs(zoom_3_extent) == campus_crs
zoom_3_extent <- project(zoom_3_extent, campus_crs)
crs(zoom_3_extent) == campus_crs

zoom_3_plot <- ggplot() +
  geom_raster(data = zoom_3_DEM_df,
              aes(x=x, y=y, fill=greatercampusDEM_1_1)) +
  scale_fill_viridis_c() +
  geom_raster(data = zoom_3_hillshade_df,
              aes(x=x, y=y, alpha=hillshade)) +
  scale_alpha(range = c(0.05, 0.5), guide="none") +
  theme(axis.title.x=element_blank(), axis.title.y=element_blank(), legend.position="none") +
  coord_sf() + 
  ggtitle(gg_labelmaker(current_ggplot+1), subtitle = "UCSB & Surroundings")
zoom_3_plot



# #######################################################
# back to start of zoom 
# do these all look the same yet?

# zoom 1 needs a DEM
zoom_1_plot
# zoom 2 needs water
zoom_2_plot
# zoom 3 needs water, or should use topo_batho
zoom_3_plot



# now let's visualize things up 
# 'california populated places'
# which is census data. 
places <- vect("source_data/tl_2023_06_place/tl_2023_06_place.shp")
plot(places)
# overlay this on top of zoom 1 and zoom 2

zoom_1_plot <- ggplot() +
  geom_raster(data = zoom_1_df,
              aes(x=x, y=y, fill=GRAY_HR_SR_OB)) +
  geom_spatvector(data=places, fill="gray") +
  geom_spatvector(data=zoom_2_crop_extent, color="red", fill=NA) +
  theme(axis.title.x=element_blank(), axis.title.y=element_blank(), legend.position="none") +
  coord_sf(crs=campus_crs) + 
  ggtitle(gg_labelmaker(current_ggplot+1), subtitle = "Zoom 1: California w/places")

zoom_1_plot


# this is another CRS error
zoom_2_plot <- ggplot() +
  geom_raster(data = zoom_2_DEM_df,
              aes(x=x, y=y, fill=dem90_hf)) +
  scale_fill_viridis_c() +
  geom_raster(data = zoom_2_hillshade_df,
              aes(x=x, y=y, alpha=hillshade)) +
  scale_alpha(range = c(0.05, 0.5), guide="none") +
  geom_spatvector(data=places, fill="gray") +
  geom_spatvector(data=zoom_3_extent, color="red", fill=NA) +
  theme(axis.title.x=element_blank(), axis.title.y=element_blank(), legend.position="none") +
  coord_sf() + 
  ggtitle(gg_labelmaker(current_ggplot+1), subtitle = "Bite of California w DEM")
zoom_2_plot

# test and reproject as necessary
crs(zoom_3_extent) == campus_crs
crs(zoom_2_cropped) == campus_crs
crs(zoom_2_hillshade) == campus_crs
crs(places) == campus_crs

zoom_2_cropped <- project(zoom_2_cropped, campus_crs)
zoom_2_hillshade <- project(zoom_2_cropped, campus_crs)
places <- project(places, campus_crs)
crs(zoom_2_cropped) == campus_crs
crs(zoom_2_hillshade) == campus_crs
crs(places) == campus_crs

# remake dataframes
zoom_2_DEM_df <- as.data.frame(zoom_2_cropped, xy=TRUE)
zoom_2_hillshade_df <- as.data.frame(zoom_2_hillshade, xy=TRUE)
str(zoom_2_hillshade_df)

# try again:
# nope, you are gonna need to crop places
zoom_2_plot <- ggplot() +
  geom_raster(data = zoom_2_DEM_df,
              aes(x=x, y=y, fill=dem90_hf)) +
  scale_fill_viridis_c() +
  geom_raster(data = zoom_2_hillshade_df,
              aes(x=x, y=y, alpha=dem90_hf)) +
  scale_alpha(range = c(0.05, 0.5), guide="none") +
  geom_spatvector(data=places, fill="gray") +
  geom_spatvector(data=zoom_3_extent, color="red", fill=NA) +
  theme(axis.title.x=element_blank(), axis.title.y=element_blank(), legend.position="none") +
  coord_sf() + 
  ggtitle(gg_labelmaker(current_ggplot+1), subtitle = "Bite of California w DEM")
zoom_2_plot

zoom_2_places <- crop(places, zoom_2_cropped)

zoom_2_plot <- ggplot() +
  geom_raster(data = zoom_2_DEM_df,
              aes(x=x, y=y, fill=dem90_hf)) +
  scale_fill_viridis_c() +
  geom_raster(data = zoom_2_hillshade_df,
              aes(x=x, y=y, alpha=dem90_hf)) +
  scale_alpha(range = c(0.05, 0.5), guide="none") +
  geom_spatvector(data=zoom_2_places, fill="NA", color="gray") +
  geom_spatvector(data=zoom_3_extent, color="red", fill=NA) +
  theme(axis.title.x=element_blank(), axis.title.y=element_blank(), legend.position="none") +
  coord_sf() + 
  ggtitle(gg_labelmaker(current_ggplot+1), subtitle = "Bite of California w DEM")
zoom_2_plot




#######################################################################################


ggsave("images/map4.png", width = 3, height = 4, plot=zoom_1_plot)
ggsave("images/map5.png", width = 3, height = 4, plot=zoom_2_plot)
ggsave("images/map6.png", width = 4, height = 3, plot=zoom_3_plot)

