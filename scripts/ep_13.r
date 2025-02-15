#episode 13
#create publication quality graphics

# clean the environment and hidden objects
rm(list=ls())

current_episode <- 13


library(terra)
library(ggplot2)
library(dplyr)
library(sf)
library(raster)
library(scales)

#recreate necessary objects from map 1
campus_DEM <- rast("source_data/campus_DEM.tif") 
crs(campus_DEM)

campus_projection <- crs(campus_DEM)

# shouldn't we be making the NDVI graph here first?
# that's how episode 13 starts.


campus_DEM_df <- as.data.frame(campus_DEM, xy=TRUE) %>%
  rename(elevation = greatercampusDEM_1_1) # rename to match code later
str(campus_DEM_df)

# create bathymetry in case episodes
# weren't run yet

bath_rast <- rast("source_data/SB_bath.tif")  
bath_rast 

reprojected_bath <- project(bath_rast, campus_projection)
reprojected_bath
# get a bounding box out of campus DEM to clip the bathymetry.
# later on we will clip to extent, but for now we will leave it at this:

# extent object
campus_border <- ext(campus_DEM)
campus_border

#can be turned into a spatial object
campus_border_poly <- as.polygons(campus_border, crs(campus_DEM))
campus_border_poly

# and written out to a file:
writeVector(campus_border_poly, 'output_data/ep_3_campus_borderline.shp', overwrite=TRUE)

# from ep 11: crop the bathymetry to the extent
# of campus_DEM
bath_clipped <- crop(x=reprojected_bath, y=campus_border_poly)
plot(bath_clipped)

writeRaster(bath_clipped, "output_data/ep_3_campus_bathymetry_crop.tif",
            filetype="GTiff",
            overwrite=TRUE)


campus_bath <- rast("output_data/ep_3_campus_bathymetry_crop.tif")
(campus_bath)

campus_bath_df <- as.data.frame(campus_bath, xy=TRUE) %>%
  rename(bathymetry = Bathymetry_2m_OffshoreCoalOilPoint)

str(campus_bath_df)

crs(campus_DEM) == crs(campus_bath)

#bring back hillshade
campus_hillshade_df <- 
  rast("source_data/campus_hillshade.tif") %>% 
  as.data.frame(xy = TRUE) %>% 
  rename(campus_hillshade = hillshade) # rename to match code later

str(campus_hillshade_df)

#load and reproject vectors

buildings <- st_read("source_data/campus_buildings/Campus_Buildings.shp")
iv_buildings <- st_read("source_data/iv_buildings/iv_buildings/CA_Structures_ExportFeatures.shp")
bikeways <- st_read("source_data/icm_bikes/bike_paths/bikelanescollapsedv8.shp")
habitat <- st_read("source_data/NCOS_Shorebird_Foraging_Habitat/NCOS_Shorebird_Foraging_Habitat.shp")

buildings <- st_transform(buildings, campus_projection)
iv_buildings <- st_transform(iv_buildings, campus_projection)
habitat <- st_transform(habitat, campus_projection)
bikeways <- st_transform(bikeways, campus_projection)

#map 1: suppressing x and y 
#teachable moment: 
ggplot() +
  geom_raster(data = campus_DEM_df, aes(x=x, y=y, fill = elevation)) +
  geom_raster(data = campus_hillshade_df, aes(x=x, y=y, alpha = campus_hillshade), show.legend = FALSE) +
  geom_raster(data = campus_bath_df, aes(x=x, y=y, fill = bathymetry)) +
  scale_y_continuous(labels = number_format(accuracy = 0.01)) +
  scale_fill_viridis_c(na.value="NA", guide = guide_legend("elevation (US ft)"))+
  labs(title="Map 1", subtitle="Episode 13 Start") + theme(axis.title.x=element_blank(),
                                                    axis.title.y=element_blank())+
  geom_sf(data=iv_buildings, color=alpha("light gray", .1), fill=NA) +
  geom_sf(data=buildings, color ="hotpink") +
  geom_sf(data=habitat, color="darkorchid1") +
  geom_sf(data=bikeways, color="yellow") +
  coord_sf()





############Narrative

# facet wrapped NDVIs from ep. 12

# make a list of all your tiffs
# they get made by map 12. 
ndvi_series_names <- list.files("output_data/ndvi")
ndvi_series_path <- paste("output_data/ndvi/", ndvi_series_names, sep="")

# path to files:
# now we can build a raster stack with no errors
ndvi_series_stack <- rast(ndvi_series_path)

summary(ndvi_series_stack[,1])







# formatted map of same

# theme void 
# turns off a lot of stuff

# another way to suppress x and y labels
# Kristi's map 1 solution goes here:




# back to the narrative:
#ggplot() +
#  geom_raster(data = "??????????" , aes(x = x, y = y, fill = value)) +
#  facet_wrap(~variable) +
#  ggtitle("NDVI", subtitle = "blah blah") + 
#  theme_void() + 
#  theme(plot.title = element_text(hjust = 0.5),
#        plot.subtitle = element_text(hjust = 0.5))

#facet wrap ndvi thing 
#adjust color ramp? 
#facet wrap? egh 
#julian day thing (not julien)



current_episode <- "episode 13 end"
