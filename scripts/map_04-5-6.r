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



# ###########################
# Map 6
# Zoom 3: campus

campus_DEM <- rast("source_data/campus_DEM.tif") 

# we are going to reuse this CRS throughout
campus_crs = crs(campus_DEM)
str(campus_crs)
plot(campus_DEM)

# we'll need a polygon that's the extent
# of campus
campus_extent <- ext(campus_DEM)
campus_extent <- vect(campus_extent, crs=campus_crs)
plot(campus_extent)
campus_extent <- project(campus_extent, campus_crs)
plot(campus_extent)


# ############################
# Map 5
# Zoom 2
# Bite of California

# Crop western region DEM to local area defined by 
# socal_aoi.geojson
zoom_2 <- rast("source_data/dem90_hf/dem90_hf.tif")


# this geojson is the extent we want to crop to
# extent geojson came from planet
zoom_2_extent <- geojson_sf("source_data/socal_aoi.geojson")
zoom_2_extent <- vect(zoom_2_extent)

# project it to match west_us
zoom_2_extent <- project(zoom_2_extent, crs(zoom_2))
crs(zoom_2_extent)

# now you can plot them together
# to confirm that's the correct extent
# that you want to crop to
plot(zoom_2)
polys(zoom_2_extent)

# and crop to that extent
# is this slow? --not at all on JJ's mac
zoom_2_cropped <- crop(x=zoom_2, y=zoom_2_extent)
plot(zoom_2_cropped)

# put the extent back into the default projection
zoom_2_extent <- project(zoom_2_extent, campus_crs)

# project --cali_zoom_2-- into my standard crs
# downsample before projecting:
#zoom_2_downsample <- aggregate(zoom_2_cropped, fact=2,
#                                    fun=mean)

# now project and test the overlay:
zoom_3_fake_aoi <- vect("source_data/socal_aoi.geojson")

# need make the projections match
# the above didn't work because the crs's don't match:
crs(zoom_2_cropped) == crs(zoom_3_fake_aoi)

zoom_3_fake_aoi <- project(zoom_3_fake_aoi, crs(campus_crs))
zoom_2_cropped <- project(zoom_2_cropped, campus_crs)

# aesthetically, at this point
# we can start to use the extent of campus
plot(zoom_2_cropped, col=grays)
polys(campus_extent, border="red", lwd=4)


# #####################
# Map 4
# Zoom 1
# overview
# this one arrived as a hillshade.
# maybe this should actually be made from the west_us?


world <- rast("source_data/global_raster/GRAY_HR_SR_OB.tif")
plot(world)

# world <- project(world, campus_crs)
# clip first instead
zoom_1_extent <- geojson_sf("source_data/cali_overview.geojson")
zoom_1_extent <- vect(zoom_1_extent)
zoom_1_extent <- project(zoom_1_extent, crs(world))

plot(world)
polys(zoom_1_extent)

zoom_1 <- crop(x=world, y=zoom_1_extent)

zoom_1_extent <- project(zoom_1_extent, campus_crs)
zoom_1 <- project(zoom_1, campus_crs)

plot(zoom_1)
polys(zoom_3_fake_aoi, border="red", lwd=4)


plot(zoom_1, col=grays)
polys(zoom_3_fake_aoi,  border="red", lwd=4)

plot(zoom_2_cropped, col=grays)
polys(campus_extent,  border="red", lwd=4)

plot(campus_DEM)


plot(zoom_1, col=grays)
polys(zoom_3_fake_aoi, col="red")

plot(zoom_2_cropped, col=grays)
polys(campus_extent, col="red")

plot(campus_DEM, col=grays)


####################################
# we need to make zoom 2 into a hillshade
# zoom 1 came as a hillshade
# zoom 3 hillshade gets made in data_prep.r as hillshade.tiff

# hillshades are made of slopes and aspects
zoom_2_slope <- terrain(zoom_2_cropped, "slope", unit="radians")
plot(zoom_2_slope)
zoom_2_aspect <- terrain(zoom_2_cropped, "aspect", unit="radians")
plot(zoom_2_aspect)
zoom_2_hillshade <- shade(zoom_2_slope, zoom_2_aspect,
                         angle = 15,
                         direction = 270,
                         normalize = TRUE)
plot(zoom_2_hillshade, col=grays)


# Review
# ##########################
# add the AOI polygons
# and output a tryptic of hillshades

# zoom 1: 
plot(zoom_1, col = grays)
polys(zoom_2_extent, border="red",lwd=5)

# zoom 2:# zoom 2:reduce()
plot(zoom_2_hillshade, col = grays)
polys(campus_extent, border="red", lwd=5)

# zoom 3:
zoom_3 <- rast("source_data/campus_hillshade.tif")
plot(zoom_3, col = grays)



plot(zoom_1, col = grays)
polys(zoom_2_extent, border="red",lwd=5)

plot(zoom_2_hillshade, col = grays)
polys(campus_extent, border="red", lwd=5)

zoom_3 <- rast("source_data/campus_hillshade.tif")
plot(zoom_3, col = grays)




# now we do it all again with ggplot:
# via ggplot
#################################################



# zoom 1 as ggplot
str(zoom_1)
zoom_1_df <- as.data.frame(zoom_1, xy=TRUE)
colnames(zoom_1_df)

zoom_1_plot <- ggplot() +
  geom_raster(data = zoom_1_df,
              aes(x=x, y=y, fill=GRAY_HR_SR_OB), show.legend = FALSE) +
  geom_spatvector(data=zoom_2_extent, fill="NA") +
    scale_fill_viridis_c() +
  theme_dark() +
  coord_sf(crs=campus_crs) + 
  ggtitle(gg_labelmaker(current_ggplot+1), subtitle = "California")

zoom_1_plot


# zoom 2 as ggplot

zoom_2_df <- as.data.frame(zoom_2_cropped, xy=TRUE)
colnames(zoom_2_df)

zoom_2_hillshade_df <- as.data.frame(zoom_2_hillshade, xy=TRUE)


# this plot breaks if I try to style the extent box.
# geom_sf(data=campus_extent, aes(stroke=3, fill=NA)) +
# also, the crs throws an error = cannot transform sfc object with missing crs
crs(campus_extent)

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
  geom_spatvector(data=campus_extent) +
  geom_spatvector(data=places, fill=NA) +
  theme(axis.title.x=element_blank(), axis.title.y=element_blank(), legend.position="none") +
  ggtitle(gg_labelmaker(current_ggplot+1), subtitle = "Bite of California")

  
zoom_1_plot
zoom_2_plot
zoom_3_plot

ggsave("images/map4.png", width = 3, height = 4, plot=zoom_1_plot)
ggsave("images/map5.png", width = 3, height = 4, plot=zoom_2_plot)
ggsave("images/map6.png", width = 4, height = 3, plot=zoom_3_plot)

