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

# Before and after
# https://datacarpentry.github.io/r-raster-vector-geospatial/13-plot-time-series-rasters-in-r.html#before-and-after

# create a raster stack of pre-calculated NDVIs of the NCOS AOI:
ndvi_series_path <- list.files("output_data/ndvi", full.names = TRUE)
# build the raster stack
ndvi_series_stack <- rast(ndvi_series_path)
plot(ndvi_series_stack)

### let's crop the stack to the NCOS area to make a 
#   more relevant map for campus.
#   and make plotting faster
ncos_extent <- vect("source_data/planet/planet/ncos_aoi.geojson")
ncos_extent <- project(ncos_extent, ndvi_series_stack)

ndvi_series_stack <- crop(ndvi_series_stack, ncos_extent)
ndvi_series_stack
plot(ndvi_series_stack)


# convert to a data frame
ndvi_series_df <- as.data.frame(ndvi_series_stack, xy=TRUE, na.rm=FALSE) %>% 
  pivot_longer(-(x:y), names_to = "date", values_to= "NDVI")

# plot the NDVI time series
# Adjust the Plot Theme
ggplot() +
  geom_raster(data = ndvi_series_df, aes(x = x, y = y, fill = NDVI)) +
  facet_wrap(~ date) +
  ggtitle("PlanetScope NDVI", subtitle = "UCSB Campus & Environs") + 
  theme_void() +
  coord_sf()

# center the title
ggplot() +
  geom_raster(data = ndvi_series_df, aes(x = x, y = y, fill = NDVI)) +
  facet_wrap(~ date) +
  ggtitle("PlanetScope NDVI", subtitle = "UCSB Campus & Environs") + 
  theme_void() +
  theme(plot.title = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust = 0.5)) +
  coord_sf()

# Challenge: Make the title bold
ggplot() +
  geom_raster(data = ndvi_series_df, aes(x = x, y = y, fill = NDVI)) +
  facet_wrap(~ date) +
  ggtitle("PlanetScope NDVI", subtitle = "UCSB Campus & Environs") + 
  theme_void() +
  theme(plot.title = element_text(hjust = 0.5, face = "bold"),
        plot.subtitle = element_text(hjust = 0.5)) +
  coord_sf()

# Adjust the color ramp
# lesson uses yellow to green like this:
library(RColorBrewer)
brewer.pal(9, "YlGn")
green_colors <- brewer.pal(9, "YlGn") %>%
  colorRampPalette()

ggplot() +
  geom_raster(data = ndvi_series_df, aes(x = x, y = y, fill = NDVI)) +
  facet_wrap(~ date) +
  scale_fill_gradientn(name = "NDVI", colours = green_colors(20)) +
  ggtitle("PlanetScope NDVI", subtitle = "UCSB Campus & Environs") + 
  theme_void() +
  theme(plot.title = element_text(hjust = 0.5, face = "bold"),
        plot.subtitle = element_text(hjust = 0.5)) +
  coord_sf()

# I like Red to Yellow to Green like this:
ggplot() +
  geom_raster(data = ndvi_series_df, aes(x = x, y = y, fill = NDVI)) +
  facet_wrap(~ date) +
  scale_fill_distiller(palette = "RdYlGn", direction = 1) +
  ggtitle("PlanetScope NDVI", subtitle = "UCSB Campus & Environs") + 
  theme_void() +
  theme(plot.title = element_text(hjust = 0.5, face = "bold"),
        plot.subtitle = element_text(hjust = 0.5)) +
  coord_sf()

current_episode <- "episode 13 end"
