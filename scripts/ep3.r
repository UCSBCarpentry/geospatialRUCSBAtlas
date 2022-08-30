# ep3.r

# set up objects from previous episodes

# read the campus DEM
campus_DEM_df <- raster("output_data/campus_DEM.tiff") %>% 
  as.data.frame(xy=TRUE) %>% 
  rename(elevation = campus_DEM)

# add the custom bins to the dataframe
custom_bins <- c(-3, -.01, .01, 2, 3, 4, 5, 10, 40, 200)
campus_DEM_df <- campus_DEM_df %>% 
  mutate(binned_DEM = cut(elevation, breaks = custom_bins))






# ep3 is reprojections. We need a raster in a different projection.
# how about bathymetry?

# make it the tidy way, so that there's not an extra object
bath_df <- raster("output_data/SB_bath.tif", xy=TRUE) %>% 
  as.data.frame(xy=TRUE) %>% 
  rename(depth = SB_bath)

summary(bath_df)  
# ^^ remember, those are negative numbers  
# summary also tells us we need to emphasize 180 range

# the summary view shows the pixel coordinates are different--
# so that's a clear indication these won't overlay.
summary(campus_DEM_df)

# as in the lesson
# again, the initial plot makes no sense because of all the values around 180
ggplot() +
  geom_raster(data = bath_df) +
  aes(x=x, y=y, fill=depth) +
  scale_fill_viridis_c() +
  coord_quickmap()

# the solution is similar to ep. 1. Make some custom bins:
# the 179-180 bin shows us a cable.
custom_bath_bins <- c(0, 150, 170, 175, 177.5, 179, 180, 225, 250)

bath_df <- bath_df %>% 
  mutate(binned_bath = cut(depth, breaks=custom_bath_bins))

ggplot() + 
  geom_raster(data = bath_df, aes(x=x, y=y, fill = binned_bath)) +
  scale_fill_manual(values = terrain.colors(10)) +
coord_quickmap()





