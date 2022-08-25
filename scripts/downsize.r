# this script
# downsizes the campus DEM so that it's more usable
# on laptops

library(tidyverse)
library(rgdal)
library(RColorBrewer)
library(raster)

campus_DEM <- raster("source_data/greatercampusDEM/greatercampusDEM_1_1.tif")

summary(campus_DEM)
input_resolution <- res(campus_DEM)
(input_resolution)

campus_DEM_downsampled <- aggregate(campus_DEM, fact = 4)

# now 20 x 20. Good!
res(campus_DEM_downsampled)

# seems reasonable. fewer NA pixels
summary(campus_DEM_downsampled)

# gotta make that dataframe
campus_DEM_20_df <- as.data.frame(campus_DEM_downsampled, xy=TRUE)

ggplot() +
  geom_raster(data = campus_DEM_20_df, 
              aes(x=x, y=y, fill = greatercampusDEM_1_1)) +
  scale_fill_gradient2(na.value = "lightgrey", 
                       low="black", 
                       mid="azure1", 
                       high="cornsilk3",
                       midpoint=0,
  ) +
  coord_sf()

summary(campus_DEM_20_df)


# write out our new raster
writeRaster(campus_DEM_downsampled, "output_data/campus_DEM.tiff", format = "GTiff")
