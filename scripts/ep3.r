# ep3.r

# read output_data/campus_DEM.tiff



campus_DEM_df <- as.data.frame(campus_DEM_downsampled, xy=TRUE) %>% 
  rename(elevation = greatercampusDEM_1_1)