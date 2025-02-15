# episode 9
# dealing with CRSs

rm(list=ls())

library(sf)
library(terra)
library(ggplot2)
library(dplyr)

aoi_boundary_HARV <- st_read(
  "data/NEON-DS-Site-Layout-Files/HARV/HarClip_UTMZ18.shp")

CHM_HARV <- rast("data/NEON-DS-Airborne-Remote-Sensing/HARV/CHM/HARV_chmCrop.tif")
CHM_HARV_df <- as.data.frame(CHM_HARV, xy=TRUE)

ggplot() +
  geom_raster(data = CHM_HARV_df, aes(x = x, y = y, fill = HARV_chmCrop)) +
  scale_fill_gradientn(name = "Canopy Height", colors = terrain.colors(10)) +
  geom_sf(data = aoi_boundary_HARV, color = "blue", fill = NA) +
  coord_sf()

CHM_HARV_Cropped <- crop(x = CHM_HARV, y = aoi_boundary_HARV)

CHM_HARV_Cropped_df <- as.data.frame(CHM_HARV_Cropped, xy = TRUE)

ggplot() +
  geom_sf(data = st_as_sfc(st_bbox(CHM_HARV)), fill = "green",
          color = "green", alpha = .2) +
  geom_raster(data = CHM_HARV_Cropped_df,
              aes(x = x, y = y, fill = HARV_chmCrop)) +
  scale_fill_gradientn(name = "Canopy Height", colors = terrain.colors(10)) +
  coord_sf()

ggplot() +
  geom_raster(data = CHM_HARV_Cropped_df,
              aes(x = x, y = y, fill = HARV_chmCrop)) +
  geom_sf(data = aoi_boundary_HARV, color = "blue", fill = NA) +
  scale_fill_gradientn(name = "Canopy Height", colors = terrain.colors(10)) +
  coord_sf()

st_bbox(CHM_HARV)
st_bbox(CHM_HARV_Cropped)

# challenge ###########

PlotLocations <- st_read("data/NEON-DS-Site-Layout-Files/HARV/PlotLocations_HARV.shp")

aoi <- st_bbox(PlotLocations)
CHM_HARV_Cropped_2_Plots <- crop(CHM_HARV, aoi)
plot(CHM_HARV_Cropped_2_Plots)

CHM_HARV_Cropped_2_Plots_df <- as.data.frame(CHM_HARV_Cropped_2_Plots, xy=TRUE)

# plots and heights
ggplot() +
  geom_raster(data = CHM_HARV_Cropped_2_Plots_df,
              aes(x = x, y = y, fill = HARV_chmCrop)) +
  geom_sf(data = PlotLocations, color = "blue", fill = NA) +
  scale_fill_gradientn(name = "Canopy Height", colors = terrain.colors(10)) +
  coord_sf()


ggplot() +
  geom_raster(data = CHM_HARV_Cropped_2_Plots_df,
              aes(x = x, y = y, fill = HARV_chmCrop)) +
  scale_fill_gradientn(name = "Canopy Height", colors = terrain.colors(10)) +
  geom_sf(data = PlotLocations, color = "blue", fill = NA) +
  coord_sf()

# 1 lonely dot lives outside the extent. 

new_extent <- ext(732161.2, 732238.7, 4713249, 4713333)
CHM_HARV_manual_crop <- crop(CHM_HARV, new_extent)

CHM_HARV_manual_crop_df <- as.data.frame(CHM_HARV_manual_crop, xy=TRUE)


ggplot() +
  geom_raster(data = CHM_HARV_manual_crop_df,
              aes(x = x, y = y, fill = HARV_chmCrop)) +
  scale_fill_gradientn(name = "Canopy Height", colors = terrain.colors(10)) +
  geom_sf(data = PlotLocations, color = "blue", fill = NA) +
  coord_sf()

ggplot() +
  geom_raster(data = CHM_HARV_manual_crop_df,
              aes(x = x, y = y, fill = HARV_chmCrop)) +
  scale_fill_gradientn(name = "Canopy Height", colors = terrain.colors(10)) +
  geom_sf(data = aoi_boundary_HARV, color = "blue", fill = NA) +
  coord_sf()


# buffers with extract()
# challenge:
# do it for all the plot location points.
# is this the first time we use this data?
# points were created in ep. 10 OR can be found:
plot_locations_sp_HARV <- st_read("data/NEON-DS-Site-Layout-Files/HARV/PlotLocations_HARV.shp")
