# map 1
# Wide overview of campus

# clean the environment and hidden objects
rm(list=ls())

library(tidyverse)
library(raster)
# library(rgdal)
library(terra)
library(sf)
library(scales)

# set up objects

#vector layers

buildings <- st_read("source_data/campus_buildings/Campus_Buildings.shp")
iv_buildings <- st_read("source_data/iv_buildings/iv_buildings/CA_Structures_ExportFeatures.shp")
# walkways <- 
bikeways <- st_read("source_data/icm_bikes/bike_paths/bikelanescollapsedv8.shp")
habitat <- st_read("source_data/NCOS_Shorebird_Foraging_Habitat/NCOS_Shorebird_Foraging_Habitat.shp")



# basic terra plots
plot(buildings)
plot(iv_buildings)
plot(bikeways)
plot(habitat)


# overlays as in episode 8
ggplot() +
  geom_sf(data=habitat) +
  geom_sf(data=buildings) +
  geom_sf(data=iv_buildings) +
  geom_sf(data=bikeways) +
  coord_sf()

ggsave("images/map1.1.png", plot=last_plot())

#which buildings are on top?
# the last ones added
ggplot() +
  geom_sf(data=habitat, color="yellow") +
  geom_sf(data=buildings) +
  geom_sf(data=iv_buildings, color="light gray") +
  geom_sf(data=bikeways, color="blue") +
  coord_sf()

# so visually let's put the non-campus gray
# buildings below our campus buildings
ggplot() +
  geom_sf(data=habitat, color="yellow") +
  geom_sf(data=iv_buildings, color="light gray") +
  geom_sf(data=buildings) +
  geom_sf(data=bikeways, color="blue") +
  coord_sf() + 
  ggtitle("Map 1.2")

ggsave("images/map1.2.png", plot=last_plot())



# the background setup is bathymetry and topography
# mashed together

# We'll need some bins
# best coast line bins from ep 2
# from ep 2, these are best sea level bins:
custom_bins <- c(-3, 4.9, 5, 7.5, 10, 25, 40, 70, 100, 150, 200)



campus_DEM <- rast("source_data/campus_DEM.tif") 
crs(campus_DEM)

# does bathymetry still needs to be re-projected in order to overlay?
bath <- rast("source_data/SB_bath.tif") 
crs(campus_DEM) == crs(bath)

# can't overlay them because they are different CRS's
# that's part of the narrative of the lesson.
plot(campus_DEM)
plot(bath)


campus_projection <- crs(campus_DEM)

bath <- project(bath, campus_projection)
plot(campus_DEM)
plot(bath)

crs(campus_DEM) == crs(bath)

#################################

# Julien solved this in ep_4
# for these files, CRS, extent, and resolution all match:


# do they have the same projections?
crs(campus_DEM) == crs(bath)

# do they have the same extents?
ext(campus_DEM) == ext(bath)


campus_bath <- crop(x=bath, y=campus_DEM)
plot(campus_bath)

# save campus bathymetry here
writeRaster(campus_bath, "output_data/campus_bath.tif", filetype="GTiff", overwrite=TRUE)

# make dataframes
campus_DEM_df <- as.data.frame(campus_DEM, xy=TRUE) %>%
  rename(elevation = greatercampusDEM_1_1) # rename to match code later
str(campus_DEM_df)


campus_bath_df <- as.data.frame(campus_bath, xy=TRUE) %>%
  rename(bathymetry = Bathymetry_2m_OffshoreCoalOilPoint)
str(campus_bath_df)

sea_level <- campus_DEM - 5

# Set values below or equal to 0 to NA
sea_level_0 <- app(sea_level, function(x) ifelse(x <=0, NA, x))

# Note: this remove some values in the marsh that are below 0
# we are going to want those back later as our 'vernal pools'

# Make it a data frame and rebinned
sea_level_df <- as.data.frame(sea_level_0, xy=TRUE) %>% 
  rename(elevation = lyr.1) %>%
  mutate(binned = cut(elevation, breaks=custom_bins))

# to make our scale make sense, we can do 
# raster math 
# how would I do this with overlay?
ggplot() + 
  geom_raster(data = sea_level_df, aes(x=x, y=y, fill = binned)) + 
  coord_sf() # to keep map's proportions

summary(sea_level_df)
custom_sea_bins <- c(-8, -.1, .1, 3, 5, 7.5, 10, 25, 40, 70, 100, 150, 200)

sea_level_df <- sea_level_df %>% 
  mutate(binned = cut(elevation, breaks=custom_sea_bins))


length(custom_sea_bins)

# now sea level is zero.
ggplot() + 
  geom_raster(data = sea_level_df, aes(x=x, y=y, fill = binned)) +
  coord_sf()

# if we overlay, we should get the same result as at the 
# end of the previous episode:
ggplot() +
  geom_raster(data = campus_DEM_df, aes(x=x, y=y, fill = elevation)) +
  geom_raster(data = campus_bath_df, aes(x=x, y=y, fill = bathymetry)) +
  scale_fill_viridis_c(na.value="NA") +
  coord_sf()



# add custom bins to each.
# these were based on experimentation
custom_DEM_bins <- c(-3, -.01, .01, 2, 3, 4, 5, 10, 40, 200)
campus_DEM_df <- campus_DEM_df %>% 
  mutate(binned_DEM = cut(elevation, breaks = custom_DEM_bins))

str(campus_DEM_df)

custom_bath_bins <- c(1, -5, -15, -35, -45, -55, -60, -65, -75, -100, -125)
str(custom_bath_bins)

str(campus_bath_df)

campus_bath_df <- campus_bath_df %>% 
  mutate(binned_bath = cut(bathymetry, breaks =custom_bath_bins))

str(campus_bath_df)
str(campus_DEM_df)

# overlays works!!!!!
ggplot() + 
  geom_raster(data = campus_bath_df, aes(x=x, y=y, fill = binned_bath)) +
  scale_fill_manual(values = terrain.colors(10)) +
  geom_raster(data=campus_DEM_df, aes(x=x, y=y, fill = binned_DEM)) +
  scale_fill_manual(values = terrain.colors(19)) +
  coord_quickmap()

# switch the order
# Not sure how it gets on both layers
# not sure why it's so so ugly
ggplot() +
    geom_raster(data = campus_DEM_df, aes(x=x, y=y, fill = binned_DEM)) +
    geom_raster(data = campus_bath_df, aes(x=x, y=y, fill = binned_bath)) +
    scale_fill_manual(values = terrain.colors(19)) +
    coord_quickmap()
  
ggplot() +
  geom_raster(data = campus_DEM_df, aes(x=x, y=y, fill = elevation)) +
  geom_raster(data = campus_bath_df, aes(x=x, y=y, fill = bathymetry)) +
        scale_fill_viridis_c(na.value="NA") +
    coord_quickmap()
  
  
# overlay the vectors

names(campus_DEM)
names(campus_bath)

# they won't overlay because
# you need to re-project
ggplot() +
  geom_sf(data=habitat, color="yellow") +
  geom_sf(data=buildings) +
  geom_sf(data=bikeways, color="blue") +
  geom_raster(data = campus_DEM_df, aes(x=x, y=y, fill = elevation)) +
  geom_raster(data = campus_bath_df, aes(x=x, y=y, fill = bathymetry)) +
  scale_fill_viridis_c(na.value="NA") +
    coord_sf()

# reproject the vectors
buildings <- st_transform(buildings, campus_projection)
iv_buildings <- st_transform(iv_buildings, campus_projection)
habitat <- st_transform(habitat, campus_projection)
bikeways <- st_transform(bikeways, campus_projection)



#bring back the hillshade
#open file from ep1-2

campus_hillshade_df <- 
  rast("source_data/campus_hillshade.tif") %>% 
  as.data.frame(xy = TRUE) %>% 
  rename(campus_hillshade = hillshade) # rename to match code later

str(campus_hillshade_df)


#update color scheme for contrast 
# +hillshade
# trying with the scales library to shorten the x, y to 2 decimals
ggplot() +
  geom_raster(data = campus_DEM_df, aes(x=x, y=y, fill = elevation)) +
  geom_raster(data = campus_hillshade_df, aes(x=x, y=y, alpha = campus_hillshade), show.legend = FALSE) +
  geom_raster(data = campus_bath_df, aes(x=x, y=y, fill = bathymetry)) +
  scale_fill_viridis_c(na.value="NA")+ 
  labs(title="Map 1", subtitle="Version 3",
       labels =label_number(scale = 1/1000)) +
  geom_sf(data=iv_buildings, color=alpha("light gray", .1), fill=NA) +
  geom_sf(data=buildings, color ="hotpink") +
  geom_sf(data=habitat, color="darkorchid1") +
  geom_sf(data=bikeways, color="yellow") +
  coord_sf()

ggsave("images/map1.3.png", plot=last_plot())

# next we need to refine the plot and labels
# Not a publication ready graphic (yet) ~episode 13
# customize the x and y graticule to be xx.xx and smaller -> number_format()
# remove the x and y axis labels -> axis.title.x/y = element_blank()
# customize the legend title to include units of elevation -> guide_legend()

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

