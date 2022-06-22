# graphics for local examples for 
# R geospatial

# when you finish developing this, you should output all the figs
# to named files.

library(tidyverse)
library(raster)
library(rgdal)
library(RColorBrewer)

# get your first raster dataset
# GDALinfo("source_data/greatercampusDEM/greatercampusDEM_1_1.tif")

# this version of the file uses a different source raster than we are going 
# to use in the workshop

GDALinfo("source_data/USGS_one_meter_x23y382_CA_SoCal_Wildfires_B4_2018.tif")
campus_DEM <- raster("source_data/USGS_one_meter_x23y382_CA_SoCal_Wildfires_B4_2018.tif")

# units in feet. Because America.
campus_DEM

# min and max make sense for UCSB. 
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


# this plot takes about 30 seconds on Jon's workstation
# the "greatercampusDEM_1_1" column name is an artifact
# of Jon's poor file naming scheme when creating the data.

ggplot() +
  geom_raster(data = campus_DEM_df, aes(x=x, y=y, fill = USGS_one_meter_x23y382_CA_SoCal_Wildfires_B4_2018)) +
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
  scale_fill_gradient2(na.value = "deeppink", 
                       low="black", 
                       mid="azure1", 
                       high="cornsilk3",
                       midpoint=0) +
  coord_quickmap()

# huh. summary says my min value is -3:
summary(campus_DEM_df)
# BUT, sum tells me there are none < 0
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

# that's too many to keep track of. let's make custom bins
break_points <- c(0, 3, 10, 30, 50, 90, 120, 175)

#THIS IS NOT WORKING!!!!!!
# and mutate my dataset into those bins
# i didn't set up my bins correctly.
campus_DEM_binned <- campus_DEM_df %>% 
  mutate(campus_DEM_df$greatercampusDEM_1_1 = 
           cut(campus_DEM, breaks = break_points))

str(campus_DEM)
