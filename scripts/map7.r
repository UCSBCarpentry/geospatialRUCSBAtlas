# map 7 
# the zoom to Cali locator sheet

# we crop the rasters before reprojecting them.
# because that's faster

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

# We'll need a grayscale palette later
grays <- colorRampPalette(c("black", "white"))(255)



# ###########################
# Zoom 3: campus
# campus_DEM in episode 2
campus_DEM <- rast("output_data/campus_DEM.tif") 

# we are going to reuse this CRS throughout
my_crs = crs(campus_DEM)

plot(campus_DEM, col=grays)

# we'll need a polygon that's the extent
# of campus
campus_extent <- ext(campus_DEM)
campus_extent <- vect(campus_extent)
plot(campus_extent)


# ############################
# Zoom 2
# Bite of California

# Crop western region DEM to local area defined by 
# socal_aoi.geojson
zoom_2 <- rast("downloaded_data/dem90_hf/dem90_hf.tif")


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
plot(zoom_2_cropped, col=grays)

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
polys(campus_extent, col="red")



# #####################
# Zoom 1
# overview
# this one arrived as a hillshade.
# maybe this should actually be made from the west_us?
world <- rast("downloaded_data/GRAY_HR_SR_OB.tif")
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

plot(zoom_1, col=grays)
polys(zoom_3_fake_aoi, border="red", lwd=5)




# page layout start
# ##########################

par(mfrow = c(1,3))

plot(zoom_1, col=grays)
polys(zoom_3_fake_aoi, col="red")

plot(zoom_2_cropped, col=grays)
polys(campus_extent, col="red")

plot(campus_DEM, col=grays)

par(mfrow = c(1,1))

# now save this tryptic to an intermediate file
png("images/zoom_in_first_results.png", width=1900)
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
# zoom 1 came as a hillshade
# zoom 3 hillshade gets made in data_prep.r as hillshade.tiff

# we need to make zoom 2 into a hillshade
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
zoom_3 <- rast("source_data/hillshade.tiff")
plot(zoom_3, col = grays)




# via ggplot
#################################################
# now we should make them with ggplot with better 
# visualization.


# zoom 1 as ggplot
str(zoom_1)
zoom_1_df <- as.data.frame(zoom_1, xy=TRUE)
colnames(zoom_1_df)

zoom_1_plot <- ggplot() +
  geom_raster(data = zoom_1_df,
              aes(x=x, y=y, fill=GRAY_HR_SR_OB), show.legend = FALSE) +
  geom_spatvector(data=zoom_2_extent, fill="NA") +
    scale_fill_viridis_c() +
  theme_dark()

zoom_1_plot


# zoom 2 as ggplot
zoom_2_df <- as.data.frame(zoom_2_cropped, xy=TRUE)
colnames(zoom_2_df)

zoom_2_hillshade_df <- as.data.frame(zoom_2_hillshade, xy=TRUE)

zoom_2_plot <- ggplot()+
  geom_raster(data = zoom_2_df,
              aes(x=x, y=y, fill=dem90_hf), show.legend = FALSE) +
  geom_raster(data=zoom_2_hillshade_df, 
              aes(x=x, y=y, alpha=hillshade))+
  geom_sf(data=campus_extent, fill="NA") +
  scale_fill_viridis_c() +
  scale_alpha(range = c(0.15, 0.65), guide="none") +
  theme_dark()

zoom_2_plot


# zoom3
# figure out the layer names
zoom_3_df <- as.data.frame(campus_DEM, xy=TRUE)

campus_hillshade <- rast("source_data/hillshade.tiff") 
zoom_3_hillshade_df <- as.data.frame(campus_hillshade, xy=TRUE)

colnames(zoom_3_df)

zoom_3_plot <- ggplot()+
  geom_raster(data = zoom_3_df,
              aes(x=x, y=y, fill=greatercampusDEM_1_1), show.legend = FALSE) +
  geom_raster(data=zoom_3_hillshade_df, 
              aes(x=x, y=y, alpha=hillshade))+
  scale_fill_viridis_c() +
  scale_alpha(range = c(0.15, 0.65), guide="none")+
  theme_dark()

zoom_3_plot


# plot_grid() or ggarrange() for ggplots instead of par()
# is supposed to work, but darned if I can
# figure out how
tryptic <- list(zoom_1_plot, zoom_2_plot, zoom_3_plot)

ggarrange(tryptic, align="h", ncol=3)






# polygons
places <- vect("downloaded_data/tl_2023_06_place.shp")
plot(places)

ggplot() + 
  geom_spatvector(data=places)

# how can I get a vector overlay into here?
# geom_raster and geom_spatraster
# produce slightly different results
colnames(zoom_2_hillshade_df)
colnames(places)

# is the alpha doing anything here?
ggplot() +
  geom_spatraster(data = zoom_2_hillshade,
              aes(fill=hillshade)) +
    scale_fill_viridis_c() +
  scale_alpha(range = c(0.15, 0.65), guide="none")

ggplot() +
  geom_raster(data = zoom_2_hillshade,
                  aes(x=x, y=y, fill=hillshade)) +
  scale_fill_viridis_c() +
  scale_alpha(range = c(0.15, 0.65), guide="none")

    
    
ggplot() +
  geom_spatraster(data = cali_zoom_2,
              aes(fill=dem90_hf))
  

par(mfrow = c(1,3))

# reset par when you're done
par(mfrow = c(1,1))
