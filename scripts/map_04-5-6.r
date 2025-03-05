# map 4-5-6 is a tryptic,
# zooming in to campus
# the zoom to Cali locator sheet

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
# needed to lay out multiple baseplots with par()?
library(cowplot)
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

# set up a local CRD to use throughout
campus_DEM <- rast("source_data/campus_DEM.tif") 
campus_crs = crs(campus_DEM)
str(campus_crs)



# #####################
# Map 4
# Zoom 1: west US overview
# this one arrived as a hillshade.
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

# Crop western region DEM to local area defined by 
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

# we can start to use the extent of the campus_DEM
zoom_3_extent <- ext(campus_DEM)
zoom_3_extent <- vect(zoom_3_extent)
crs(zoom_3_extent)

set.crs(zoom_3_extent, crs(campus_DEM))
plot(zoom_3_extent)

crs(zoom_3_extent) == crs(zoom_2_cropped)

zoom_3_extent <- project(zoom_3_extent, crs(zoom_2_cropped))

plot(zoom_2_cropped)
polys(zoom_3_extent, border="red", lwd=4)


# ###########################
# Map 6
# Zoom 3: UCSB & Environs

plot(campus_DEM)




####################################
# hillshades
# # zoom 1 came as a hillshade
plot(zoom_1)

# # make zoom 2 into a hillshade
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


# zoom 3 hillshade gets made in data_prep.r as hillshade.tiff ???


# ##########################
# add the AOI polygons
# to the hillshades

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
zoom_3 <- rast("source_data/campus_hillshade.tif")
plot(zoom_3, col = grays)



# now we do it all again with ggplot:
# via ggplot
#################################################
# zoom 1 as ggplot
str(zoom_1)
plot(zoom_1)
polys(zoom_2_crop_extent, border="red",lwd=5)

zoom_1_df <- as.data.frame(zoom_1, xy=TRUE)
colnames(zoom_1_df)

# just the hillshade
zoom_1_plot <- ggplot() +
  geom_raster(data = zoom_1_df,
              aes(x=x, y=y, fill=GRAY_HR_SR_OB)) +
  theme_dark() +
  coord_sf(crs=campus_crs) + 
  ggtitle(gg_labelmaker(current_ggplot+1), subtitle = "California")

zoom_1_plot

zoom_1_plot <- ggplot() +
  geom_raster(data = zoom_1_df,
              aes(x=x, y=y, fill=GRAY_HR_SR_OB)) +
  geom_spatvector(data=zoom_2_crop_extent, color="red", fill=NA) +
  theme(axis.title.x=element_blank(), axis.title.y=element_blank(), legend.position="none") +
  coord_sf(crs=campus_crs) + 
  ggtitle(gg_labelmaker(current_ggplot+1), subtitle = "California")
  
zoom_1_plot



# zoom 2 as ggplot
plot(zoom_2_hillshade)
polys(zoom_3_extent, border="red", lwd=5)

zoom_2_df <- as.data.frame(zoom_2_cropped, xy=TRUE)
colnames(zoom_2_df)

zoom_2_plot <- ggplot() +
  geom_raster(data = zoom_2_df,
              aes(x=x, y=y, fill=dem90_hf)) +
  geom_spatvector(data=zoom_3_extent, color="red", fill=NA) +
  theme(axis.title.x=element_blank(), axis.title.y=element_blank(), legend.position="none") +
  coord_sf() + 
  ggtitle(gg_labelmaker(current_ggplot+1), subtitle = "California")

zoom_2_plot



# this plot breaks if I try to style the extent box.
# geom_sf(data=campus_extent, aes(stroke=3, fill=NA)) +
# also, the crs throws an error = cannot transform sfc object with missing crs
crs(zoom3_extent)

zoom_2_plot <- ggplot() +
    geom_raster(data = zoom_2_df,
              aes(x=x, y=y, fill=dem90_hf), show.legend = FALSE) +
  geom_raster(data=zoom_2_hillshade_df, 
              aes(x=x, y=y, alpha=hillshade)) +
    scale_fill_viridis_c() +
  scale_alpha(range = c(0.05, 0.5), guide="none") +
#  geom_spatvector(data=campus_extent) +
  coord_sf(crs=campus_crs)+
  theme(axis.title.x=element_blank(), axis.title.y=element_blank(), legend.position="none") +
  ggtitle(gg_labelmaker(current_ggplot+1), subtitle = "Zoom 2: Bite of California")

zoom_2_plot

# later on we will want to use the zoom_2 as an extent
zoom_2_extent <- ext(zoom_2) %>% as.polygons()
writeVector(zoom_2_extent, "output_data/zoom_2_extent.shp", overwrite=TRUE)

# zoom3
# figure out the layer names
zoom_3_df <- as.data.frame(campus_DEM, xy=TRUE)



campus_hillshade <- rast("source_data/campus_hillshade.tif") 
zoom_3_hillshade_df <- as.data.frame(campus_hillshade, xy=TRUE)

colnames(zoom_3_df)

zoom_3_plot <- ggplot()+
  geom_raster(data = zoom_3_df,
              aes(x=x, y=y, fill=greatercampusDEM_1_1)) +
  geom_raster(data=zoom_3_hillshade_df, 
              aes(x=x, y=y, alpha=hillshade))+
  scale_fill_viridis_c() +
  scale_alpha(range = c(0.15, 0.65))+
  coord_sf(crs=campus_crs) +
  theme(axis.title.x=element_blank(), axis.title.y=element_blank(), legend.position="none") +
  ggtitle(gg_labelmaker(current_ggplot+1), subtitle="Zoom 3: UCSB and vicinity")

zoom_3_plot



# now load 
# 'california populated places'
# which is census data. Use these for some placename labels and
# visual polygons styled similar to the IV building outlines
# on map 1.
places <- vect("source_data/tl_2023_06_place/tl_2023_06_place.shp")
plot(places)

ggplot() + 
  geom_spatvector(data=places) +
  ggtitle(gg_labelmaker(current_ggplot+1))

# overlay 
# geom_raster and geom_spatraster
colnames(zoom_2_hillshade_df)
colnames(places)


ggplot() +
  geom_spatraster(data = zoom_2_hillshade,
                  aes(fill=hillshade)) +
geom_spatvector(data = places, fill=NA)+ 
ggtitle(gg_labelmaker(current_ggplot+1))
  
#######################
# is the alpha doing anything here?
ggplot() +
  geom_spatraster(data = zoom_2_hillshade,
              aes(fill=hillshade)) +
    scale_fill_viridis_c() +
  scale_alpha(range = c(0.15, 0.65), guide="none")+
  geom_spatvector(data=places, fill=NA) +
  ggtitle(gg_labelmaker(current_ggplot+1), subtitle = "What is alpha doing?")


ggplot() +
  geom_spatraster(data = zoom_2_hillshade,
                  aes(fill=hillshade))+
      scale_fill_viridis_c() +
  scale_alpha(range = c(0.15, 0.65), guide="none") +
geom_spatvector(data=places, fill=NA) +
  ggtitle(gg_labelmaker(current_ggplot+1))

zoom_2_plot <- ggplot() +
  geom_raster(data = zoom_2_hillshade,
                  aes(x=x, y=y, fill=hillshade)) +
  scale_fill_viridis_c() +
  scale_alpha(range = c(0.15, 0.65), guide="none") +
  geom_spatvector(data=zoom3_extent, color="red") +
  geom_spatvector(data=places, fill=NA) +
  theme(axis.title.x=element_blank(), axis.title.y=element_blank(), legend.position="none") +
  ggtitle(gg_labelmaker(current_ggplot+1), subtitle = "Bite of California")

  
zoom_1_plot
zoom_2_plot
zoom_3_plot

ggsave("images/map4.png", width = 3, height = 4, plot=zoom_1_plot)
ggsave("images/map5.png", width = 3, height = 4, plot=zoom_2_plot)
ggsave("images/map6.png", width = 4, height = 3, plot=zoom_3_plot)

