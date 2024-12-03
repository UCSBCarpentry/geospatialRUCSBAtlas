#episode 13
#create publication quality graphics

# clean the environment and hidden objects
rm(list=ls())

library(terra)
library(ggplot2)
library(dplyr)

#recreate necessary objects for map 1
#possible take the reprojections from map 4-5-6 instead
# - campus_crs,campus_crs (formerly my_crs)
#map 1: suppressing x and y 
#teachable moment: 
ggplot() +
  geom_raster(data = campus_DEM_df, aes(x=x, y=y, fill = elevation)) +
  geom_raster(data = campus_hillshade_df, aes(x=x, y=y, alpha = campus_hillshade), show.legend = FALSE) +
  geom_raster(data = campus_bath_df, aes(x=x, y=y, fill = bathymetry)) +
  scale_y_continuous(labels = number_format(accuracy = 0.01)) +
  scale_fill_viridis_c(na.value="NA", guide = guide_legend("elevation (US ft)"))+
  labs(title="Map 1", subtitle="Version 3") + theme(axis.title.x=element_blank(),
                                                    axis.title.y=element_blank())+
  geom_sf(data=iv_buildings, color=alpha("light gray", .1), fill=NA) +
  geom_sf(data=buildings, color ="hotpink") +
  geom_sf(data=habitat, color="darkorchid1") +
  geom_sf(data=bikeways, color="yellow") +
  coord_sf()