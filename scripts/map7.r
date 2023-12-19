# map 7
# the zoom to Cali

library(terra)
library(geojsonsf)
library(sf)

# full campus extent hillshade made from 
# campus_DEM
campus_DEM <- rast("output_data/campus_DEM.tif") 


# find intermediate data for bite of Cali hillshade
# use extent of campus_DEM as the overlaid locator
campusExtent <- ext(campus_DEM)

# crop this to a generous California 
# and figure out the color scale
world <- rast("downloaded_data/GRAY_HR_SR_OB.tif")
plot(world)
caliExtent <- geojson_sf("downloaded_data/cali.geojson")
world_cropped <- crop(x=world, y=caliExtent)
plot(world_cropped)

#Crop the western region DEM to local area 
#dem90_hf
#Extent <- ext() should this also be campus_DEM?


#crop to SLO/SB/VEN/LA/OC/SD region
socal <- rast("downloaded_data/dem90_hf/dem90_hf.tif")
plot(socal)

socalExtent <- geojson_sf("downloaded_data/SoCal.geojson")
socal_cropped <- crop(x=socal, y=socalExtent)
