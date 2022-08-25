# episode 5



# bring in an overview map 

# zoom out
overview_DEM <- raster("source_data/greatercampusDEM/DEMmosaic.tif")

# do the quickplot
plot(overview_DEM)

# ^^^ that works.
# but ggplot craps out because this is multi-spectral
# for some reason?
str(overview_DEM)

