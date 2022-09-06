# ep3.r

# set up objects from previous episodes

# read the campus DEM
campus_DEM_df <- raster("output_data/campus_DEM.tif") %>% 
  as.data.frame(xy=TRUE) %>% 
  rename(elevation = campus_DEM)

# add the custom bins to the dataframe
custom_bins <- c(-3, -.01, .01, 2, 3, 4, 5, 10, 40, 200)
campus_DEM_df <- campus_DEM_df %>% 
  mutate(binned_DEM = cut(elevation, breaks = custom_bins))



# ep3 is reprojections. We need a raster in a different projection.
# how about bathymetry?
# SB_bath came out of data_prep.r
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

# as in lesson 1
ggplot() +
  geom_raster(data = bath_df) +
  aes(x=x, y=y, fill=depth) +
  scale_fill_viridis_c() +
  coord_quickmap()

# we can also make some custom bins:
custom_bath_bins <- c(1, -5, -15, -35, -45, -55, -65, -100, -105, -125, -180)

bath_df <- bath_df %>% 
  mutate(binned_bath = cut(depth, breaks=custom_bath_bins))

summary(bath_df)

ggplot() + 
  geom_raster(data = bath_df, aes(x=x, y=y, fill = binned_bath)) +
  scale_fill_manual(values = terrain.colors(10)) +
coord_quickmap()


# so now I am ready to overlay the two files
# this reproduces the '2 rasters with mismatched projections'
# part of the lesson
ggplot() +
  geom_raster(data = bath_df, aes(x=x, y=y, fill = binned_bath)) +
  geom_raster(data = campus_DEM_df, aes(x=x, y=y, alpha = elevation)) +
  scale_alpha(range = c(0.15, 0.65), guide = "none") +
  coord_quickmap()


# let's remake bath_df with a re-projected raster
bath <- raster("output_data/SB_bath.tif", xy=TRUE)
projection(bath)

# I didn't make that initial raster object, so 
# I need to get projection and reolution objects somewhere.
my_projection <- raster("output_data/campus_DEM.tif") %>%
  crs() 
my_res <- res(raster("output_data/campus_DEM.tif") )


reprojected_bath <- projectRaster(bath, 
                      crs = my_projection, 
                      res = my_res)

plot(reprojected_bath)

# remake bath_df
bath_df <- as.data.frame(reprojected_bath, xy=TRUE) 
str(bath_df)

# add the binned column
bath_df <- bath_df %>% 
  mutate(binned_bath = cut(SB_bath, breaks = custom_bath_bins))

campus_DEM_df <- campus_DEM_df %>% 
  mutate(binned_DEM = cut(elevation, breaks = custom_bins))


# so now they are in the same crs, and overlay!
ggplot() +
  geom_raster(data = bath_df, aes(x=x, y=y, fill = binned_bath)) +
  geom_raster(data = campus_DEM_df, aes(x=x, y=y, alpha = elevation)) +
  scale_alpha(range = c(0.15, 0.65), guide = "none") +
  coord_quickmap()

# hide the NA's again
# scale_alpha doesn't seem to like na.value
# plot 2 custom binned maps for the sake of the overlay
ggplot() +
  geom_raster(data = bath_df, aes(x=x, y=y, fill = binned_bath)) +
  geom_raster(data = campus_DEM_df, aes(x=x, y=y, fill = elevation)) +
  coord_quickmap()

# after that, you will want to jump to the part of the lesson that
# covers clipping. get a bounding box out of campus DEM to clip
# the bathymetry.
