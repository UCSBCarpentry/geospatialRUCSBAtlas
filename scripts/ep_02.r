#############################################
# ep. 2

# overlays

# ggtitle starts in this lesson, 
# so we will start labeling our plots
# automagically when we overlay 
# elevation with hillshade


# clean the environment and hidden objects
rm(list=ls())

# set up objects

current_episode <- 2

campus_DEM <- rast("source_data/campus_DEM.tif")
campus_DEM_df <- as.data.frame(campus_DEM, xy = TRUE, na.rm=FALSE)

# make the name logical:
names(campus_DEM_df)[names(campus_DEM_df) == 'greatercampusDEM_1_1'] <- 'elevation'

campus_bath <- rast("source_data/SB_bath.tif")
campus_bath_df <- as.data.frame(campus_bath, xy = TRUE, na.rm=FALSE)
names(campus_bath_df)[names(campus_bath_df) == 'Bathymetry_2m_OffshoreCoalOilPoint'] <- 'depth'




#################################
# lesson example bins / highlights Harvard Forest pixels > 400m.
# for us, let's highlight our holes.
summary(campus_DEM_df)



#############################
custom_bins <- c(-3, -.01, .01, 2, 3, 4, 5, 10, 40, 200)

campus_DEM_df <- campus_DEM_df %>% 
  mutate(binned_DEM = cut(elevation, breaks = custom_bins))

unique(campus_DEM_df$binned_DEM)

# there's sooooo few negative values that you can't see them.



ggplot() +
  geom_bar(data = campus_DEM_df, aes(binned_DEM)) +
  ggtitle("Histogram")


# but think about landscapes. elevation tends to be
# a log. (I know this because I am a geographer)
# log scale works better
# this shows that there's nothing at zero.
# and a little bit of negative


ggplot() +
  geom_bar(data = campus_DEM_df, aes(binned_DEM)) +
  scale_y_continuous(trans='log10') +
  ggtitle("log10")



ggplot() + 
  geom_raster(data = campus_DEM_df, aes(x=x, y=y, fill = binned_DEM)) +
  ggtitle("I dunno")



# let's go again with what we've learned
custom_bins <- c(-3, 0, 2, 5, 10, 25, 40, 70, 100, 150, 200)

campus_DEM_df <- campus_DEM_df %>% 
  mutate(binned_DEM = cut(elevation, breaks = custom_bins))

# this shows sea level at 2-5 ft


ggplot() + 
  geom_raster(data = campus_DEM_df, aes(x=x, y=y, fill = binned_DEM)) +
  coord_quickmap() +
  ggtitle("Map")



# challenge
# use custom bins to figure out a good place to put sea level
custom_bins <- c(-3, 4, 4.8, 5, 10, 25, 40, 70, 100, 150, 200)
custom_bins <- c(-3, 4.9, 5.1, 7.5, 10, 25, 40, 70, 100, 150, 200)

campus_DEM_df <- campus_DEM_df %>% 
  mutate(binned_DEM = cut(elevation, breaks = custom_bins))

ggplot() + 
  geom_raster(data = campus_DEM_df, aes(x=x, y=y, fill = binned_DEM)) +
  ggtitle("Map ?")




# this isn't so nice


ggplot() + 
  geom_raster(data = campus_DEM_df, aes(x=x, y=y, fill = binned_DEM)) +
  scale_fill_manual(values = terrain.colors(10)) +
  ggtitle("Pretty ugly", subtitle = "boo")

#coord_quickmap()

# let's seize control of our bins
coast_palette <- terrain.colors(10)

# set 4.9-5 ft a nice sea blue
coast_palette[2] <- "#1d95b3"
coast_palette[3] <- "#1c9aed"
coast_palette

# where's my nice blue?


ggplot() + 
  geom_raster(data = campus_DEM_df, aes(x=x, y=y, fill = binned_DEM)) +
  scale_fill_manual(values = coast_palette)+
  ggtitle("Last manual title?")+
  coord_quickmap()





# hillshade layer
#ok we have to do something here to make a hillshade
#since one doesn't exist

# insert script from map 7 here.

describe("source_data/campus_hillshade.tif")


campus_hillshade_df <- 
  rast("source_data/campus_hillshade.tif") %>% 
  as.data.frame(xy = TRUE)

campus_hillshade_df
str(campus_hillshade_df)

# plot the hillshade


ggplot() + 
  geom_raster(data = campus_hillshade_df, 
              aes(x=x, y=y, fill = hillshade)) +
  ggtitle("Hillshade")+
  coord_quickmap()

# overlay
# not sure if this is displaying as desired




# here is the first time the lesson uses
# a ggtitle. So here is the first time we will insert our function:

# make our ggtitles automagically #######
# set ggplot counter
current_ggplot <- 0

gg_labelmaker <- function(plot_num){
  gg_title <- c("Episode:", current_episode, " ggplot:", plot_num)
  plot_text <- paste(gg_title, collapse=" " )
  print(plot_text)
  current_ggplot <<- plot_num
  return(plot_text)
}
# every ggtitle should be:
# ggtitle(gg_labelmaker(current_ggplot+1))
# end automagic ggtitle           #######




ggplot() + 
  geom_raster(data=campus_DEM_df, aes(x=x, y=y, fill = elevation)) +
  geom_raster(data = campus_hillshade_df, 
              aes(x=x, y=y, alpha = hillshade)) +
  scale_fill_viridis_c() + 
  ggtitle(gg_labelmaker(current_ggplot+1)) +
  coord_quickmap()

# I'm not sure this graph does anything for us anymore
# it would if it displayed the red. 

ggplot() +
  geom_raster(data = campus_DEM_df, aes(x=x, y=y, fill = elevation)) +
  scale_fill_gradient2(na.value = "lightgray", 
                       low="red", 
                       mid="white", 
                       high="cornsilk3",
                       guide = "colourbar",
                       midpoint = 3.12, aesthetics = "fill") +
  ggtitle(gg_labelmaker(current_ggplot+1)) +
  coord_quickmap()

# we can't see them, because there are too few.
# how few?
summary(campus_DEM_df)

# this attempts to find only negative elevations,
# but it doesn't work.
# has.neg <- apply(campus_DEM_df, 1, function(campus_DEM_df) any(campus_DEM_df$elevation < 0))

# challenge:
# how many pixels are below 3.1 feet (1 m)?
below_3 <- apply(campus_DEM_df, 1, function(campus_DEM_df) any(campus_DEM_df < 3.12))

pixel_count <- nrow(campus_DEM_df) 
pixel_count

length(which(below_3))

# that's the same number. we must have done something wrong. 
#
#negative_only <- filter()
# we still need to count the negatives.



# look at the values in the DEM
str(campus_DEM_df)
unique(campus_DEM_df$elevation)

# that's too many. let's count them up tidily
campus_DEM_df %>% 
  group_by(elevation) %>% 
  count()

# that's still too many? It's very few on Feb 4. this is part
# of why bins are handy
plot(campus_DEM_df$binned_DEM)



# Challenge: Make a 2-layer overlay for a 2nd set of rasters