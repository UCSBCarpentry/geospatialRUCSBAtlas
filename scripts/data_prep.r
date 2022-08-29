# this script

library(tidyverse)
library(rgdal)
library(RColorBrewer)
library(raster)

# downsizing the campus DEM so that it's more usable
# is in ep. 1

# hillshade
aspect <- terrain(campus_DEM_downsampled, 
        opt="aspect", unit="radians", neighbors=8, 
        filename="output_data/aspect.tiff", overwrite = TRUE)
slope <- terrain(campus_DEM_downsampled, 
        opt="slope", neighbors=8, 
        filename="output_data/slope.tiff", overwrite = TRUE)


hillShade(slope, aspect, angle=260, direction=0, 
          filename="output_data/hillshade.tiff", overwrite = TRUE, 
          normalize=FALSE)
