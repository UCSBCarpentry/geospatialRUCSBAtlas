# map 7
# the zoom to Cali

library(terra)

# full campus extent hillshade made from 
# campus_DEM
campus_DEM <- rast("output_data/campus_DEM.tif") 



# find intermediate data for bite of Cali hillshade
# use extent of campus_DEM as the overlaid locator
campusExtent <- ext(campus_DEM)

# crop this to a generous California 
# and figure out the color scale
world <- rast("downloaded_data/GRAY_50M_SR_OB.tif")
plot(world, col="gray")


