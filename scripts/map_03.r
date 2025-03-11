# Map 3
# this is the  layout page with 4 maps on it
# maps 4 - 5 - 6 zoom in tryptic
# and map 7, which is a version of map 1
# 

# Load magick package, which allows to make a montage of images
library(magick)

# Load maps 4, 5, 6, and 7 using the magick::image_read function
map4 <- image_read("images/map4.png")
map5 <- image_read("images/map5.png")
map6 <- image_read("images/map6.png")
map7 <- image_read("images/map7.0.png")

# make a vector of the maps, and then make the montage of map 3
input <- c(map4, map5, map6, map7)
map3 <- image_montage(image = input,
              tile = "3x2",
              geometry = 'x700')

#save map3
image_write(map3, "images/map3.png", format = "png")
