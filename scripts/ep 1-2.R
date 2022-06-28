# graphics for local examples for 
# R geospatial

# when you finish developing this, you should output all the figs
# to named files.

#############################################
# setup for each episode

library(tidyverse)
library(raster)
library(rgdal)
library(RColorBrewer)

setwd("C:/users/your_file_path")

#############################################
# ep. 1

# get your first raster dataset
GDALinfo("source_data/greatercampusDEM/greatercampusDEM_1_1.tif")

campus_DEM <- raster("source_data/greatercampusDEM/greatercampusDEM_1_1.tif")

# run the object, units are in feet
campus_DEM

# get summary of object, min and max make sense for UCSB
summary(campus_DEM)

# can force it to calculate on all
summary(campus_DEM, maxsamp = ncell(campus_DEM))

# or do that the tidy way with pipes
campus_DEM %>% 
  ncell() %>% 
  summary()

# summary plots require a dataframe
campus_DEM_df <- as.data.frame(campus_DEM, xy = TRUE)
str(campus_DEM_df)


# the "greatercampusDEM_1_1" column name is an artifact
# of Jon's poor file naming scheme when creating the data.

ggplot() +
  geom_raster(data = campus_DEM_df, aes(x=x, y=y, fill = greatercampusDEM_1_1)) +
  scale_fill_viridis_c() +
  coord_quickmap()

# faster base R plot
plot(campus_DEM_df)


# deal with no data
ggplot() +
  geom_raster(data = campus_DEM_df, aes(x=x, y=y, fill = greatercampusDEM_1_1)) +
  scale_fill_viridis_c(na.value = "deeppink") +
  coord_quickmap()

# lesson example hightlights Harvard Forest pixels > 400m.
# for us, let's highlight below sea level.

ggplot() +
  geom_raster(data = campus_DEM_df, aes(x=x, y=y, fill = greatercampusDEM_1_1)) +
  scale_fill_gradient2(na.value = "lightgrey", 
                       low="black", 
                       mid="azure1", 
                       high="cornsilk3",
                       midpoint=0) +
  coord_quickmap()

# looking at overview of values again
summary(campus_DEM_df)
test <- sum(campus_DEM_df$greatercampusDEM_1_1 <= 0)

# I want to find negative numbers in the column.
# there's only 215 of them, so I won't be able to see them.
has.neg <- apply(campus_DEM_df, 1, function(campus_DEM_df) any(campus_DEM_df < 0))
length(which(has.neg))



#############################################
# ep. 2

# look at the values in the DEM
unique(campus_DEM_df$greatercampusDEM_1_1)

# that's too many. let's count them up tidily
campus_DEM_df %>% 
  group_by(greatercampusDEM_1_1) %>% 
  count()
