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

# make sure output window is 1x1
# because you muck with it a lot
par(mfrow = c(1,1))

# We'll need a grayscale palette later
grays <- colorRampPalette(c("black", "white"))(255)



# ###########################
# Map 6
# Zoom 3: campus
campus_DEM <- rast("source_data/campus_DEM.tif") 

# we are going to reuse this CRS throughout
my_crs = crs(campus_DEM)
str(my_crs)
plot(campus_DEM)

# we'll need a polygon that's the extent
# of campus
campus_extent <- ext(campus_DEM)
campus_extent <- vect(campus_extent, crs=my_crs)
plot(campus_extent)
campus_extent <- project(campus_extent, my_crs)
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
zoom_2_extent <- geojson_sf("scripts/socal_aoi.geojson")
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
zoom_2_extent <- project(zoom_2_extent, my_crs)

# project --cali_zoom_2-- into my standard crs
# downsample before projecting:
#zoom_2_downsample <- aggregate(zoom_2_cropped, fact=2,
#                                    fun=mean)

# now project and test the overlay:
zoom_3_fake_aoi <- vect("scripts/socal_aoi.geojson")

# need make the projections match
# the above didn't work because the crs's don't match:
crs(zoom_2_cropped) == crs(zoom_3_fake_aoi)

zoom_3_fake_aoi <- project(zoom_3_fake_aoi, crs(my_crs))
zoom_2_cropped <- project(zoom_2_cropped, my_crs)

# aesthetically, at this point
# we can start to use the extent of campus
plot(zoom_2_cropped, col=grays)
polys(campus_extent, border="red", lwd=4)

ggsave("images/map5.png", plot=last_plot())

# #####################
# Map 4
# Zoom 1
# overview
# this one arrived as a hillshade.
# maybe this should actually be made from the west_us?
world <- rast("source_data/global_raster/GRAY_HR_SR_OB.tif")
plot(world)

# world <- project(world, my_crs)
# clip first instead
zoom_1_extent <- geojson_sf("scripts/cali_overview.geojson")
zoom_1_extent <- vect(zoom_1_extent)
zoom_1_extent <- project(zoom_1_extent, crs(world))

plot(world)
polys(zoom_1_extent)

zoom_1 <- crop(x=world, y=zoom_1_extent)

zoom_1_extent <- project(zoom_1_extent, my_crs)
zoom_1 <- project(zoom_1, my_crs)

plot(zoom_1)
polys(zoom_3_fake_aoi, border="red", lwd=4)




# page layout start
# ##########################

par(mfrow = c(1,3))

plot(zoom_1, col=grays)
polys(zoom_3_fake_aoi,  border="red", lwd=4)

plot(zoom_2_cropped, col=grays)
polys(campus_extent,  border="red", lwd=4)

plot(campus_DEM)

par(mfrow = c(1,1))

# now save this tryptic to an intermediate file
png("images/map_7_1.png", width=1900)
par(mfrow = c(1,3))

plot(zoom_1, col=grays)
polys(zoom_3_fake_aoi, col="red")

plot(zoom_2_cropped, col=grays)
polys(campus_extent, col="red")

plot(campus_DEM, col=grays)

dev.off()

# reset par when you're done
par(mfrow = c(1,1))


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


# again save tryptic to an intermediate file
png("images/map_7_2.png", width=1900)
par(mfrow = c(1,3))

plot(zoom_1, col = grays)
polys(zoom_2_extent, border="red",lwd=5)

plot(zoom_2_hillshade, col = grays)
polys(campus_extent, border="red", lwd=5)

zoom_3 <- rast("source_data/campus_hillshade.tif")
plot(zoom_3, col = grays)

dev.off()

# reset par when you're done
par(mfrow = c(1,1))





# via ggplot
#################################################
# now we should make them with ggplot with better 
# visualization.
# as is done in the lessons


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
  coord_sf(crs=my_crs) + 
  ggtitle("California", subtitle = "Map 4, Zoom 1")

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
  theme_dark()+
  coord_sf(crs=my_crs)+
  ggtitle("The Bite of California", subtitle = "Map 5, Zoom 2")

zoom_2_plot


# zoom3
# figure out the layer names
zoom_3_df <- as.data.frame(campus_DEM, xy=TRUE)

campus_hillshade <- rast("source_data/campus_hillshade.tif") 
zoom_3_hillshade_df <- as.data.frame(campus_hillshade, xy=TRUE)

colnames(zoom_3_df)

zoom_3_plot <- ggplot()+
  geom_raster(data = zoom_3_df,
              aes(x=x, y=y, fill=greatercampusDEM_1_1), show.legend = FALSE) +
  geom_raster(data=zoom_3_hillshade_df, 
              aes(x=x, y=y, alpha=hillshade))+
  scale_fill_viridis_c() +
  scale_alpha(range = c(0.15, 0.65), guide="none")+
  theme_dark() +
  coord_sf(crs=my_crs) +
  ggtitle("UCSB and vicinity", subtitle="Map 6, Zoom 3")

zoom_3_plot


# ggarrange() for ggplots instead of par()
tryptic <- list(zoom_1_plot, zoom_2_plot, zoom_3_plot)

map_7_3_tryptic <- ggarrange(plotlist = tryptic, 
                             align="h", 
                             ncol=3,
                             labels = "Map 7.3: Zoom")

map_7_3_tryptic

# Save this plot
ggsave(
  "images/map7_3.png",
  plot = map_7_3_tryptic,
  width = 10, height = 7,
  dpi = 500,
  units = 'in'
)


# q: what is this? I don't see it in the localdata drive? 
# a: census data. For labels. data prep under '# california populated places'
# polygons
places <- vect("source_data/cal_pop_places/tl_2023_06_place.shp")
plot(places)

ggplot() + 
  geom_spatvector(data=places)

# overlay 
# geom_raster and geom_spatraster
colnames(zoom_2_hillshade_df)
colnames(places)


ggplot() +
  geom_spatraster(data = zoom_2_hillshade,
                  aes(fill=hillshade)) +
geom_spatvector(data = places, fill=NA) 
  
#######################
# is the alpha doing anything here?
ggplot() +
  geom_spatraster(data = zoom_2_hillshade,
              aes(fill=hillshade)) +
    scale_fill_viridis_c() +
  scale_alpha(range = c(0.15, 0.65), guide="none")+
  geom_spatvector(data=places, fill=NA)


ggplot() +
  geom_spatraster(data = zoom_2_hillshade,
                  aes(fill=hillshade))+
      scale_fill_viridis_c() +
  scale_alpha(range = c(0.15, 0.65), guide="none") +
geom_spatvector(data=places, fill=NA)

zoom_2_plot <- ggplot() +
  geom_raster(data = zoom_2_hillshade,
                  aes(x=x, y=y, fill=hillshade)) +
  scale_fill_viridis_c() +
  scale_alpha(range = c(0.15, 0.65), guide="none") +
  geom_spatvector(data=campus_extent) +
  geom_spatvector(data=places, fill=NA) +
  labs(title = "Bite of California",
       subtitle = "Zoom 2")

  
# this doesn't work anymore. try cowplot
par(mfrow = c(1,3))
zoom_1_plot
zoom_2_plot
zoom_3_plot

# reset par when you're done
par(mfrow = c(1,1))

# cowplot output
aligned_zoom <- align_plots(zoom_1_plot, zoom_2_plot, zoom_3_plot, align = "h")
draw_plot(aligned_zoom)
