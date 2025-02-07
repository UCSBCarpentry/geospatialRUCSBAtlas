#episode 13
#create publication quality graphics

# clean the environment and hidden objects
rm(list=ls())

current_episode <- 13


library(terra)
library(ggplot2)
library(dplyr)
library(sf)

#recreate necessary objects for map 1
#possible take the reprojections from map 4-5-6 instead
# - campus_crs,campus_crs (formerly my_crs)

campus_DEM <- rast("source_data/campus_DEM.tif") 
crs(campus_DEM)

campus_DEM_df <- as.data.frame(campus_DEM, xy=TRUE) %>%
  rename(elevation = greatercampusDEM_1_1) # rename to match code later
str(campus_DEM_df)

#load in campus_bath made in map 1
campus_bath <- rast("output_data/campus_bath.tif")

campus_bath_df <- as.data.frame(campus_bath, xy=TRUE) %>%
  rename(bathymetry = SB_bath_2m)
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
iv_buildings <- st_read("source_data/iv_buildings/CA_Structures_ExportFeatures.shp")
bikeways <- st_read("source_data/bike_paths/bikelanescollapsedv8.shp")
habitat <- st_read("source_data/NCOS_bird_observations/NCOS_Shorebird_Foraging_Habitat.shp")

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

# formatted map of same

# theme void 
# turns off a lot of stuff

# another way to suppress x and y labels
# Kristi's map 1 solution goes here:




# back to the narrative:
ggplot() +
  geom_raster(data = "??????????" , aes(x = x, y = y, fill = value)) +
  facet_wrap(~variable) +
  ggtitle("NDVI", subtitle = "blah blah") + 
  theme_void() + 
  theme(plot.title = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust = 0.5))

#facet wrap ndvi thing 
#adjust color ramp? 
#facet wrap? egh 
#julian day thing (not julien)
