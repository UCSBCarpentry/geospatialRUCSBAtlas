# rAtlas data download and prep

library(terra)
library(curl)
library(googledrive)
library(tidyverse)
library(sf)
library(ff)

dir.create("downloaded_data", showWarnings = FALSE)


# 1 establish a connection to our public google drive 
#   later on from S3


# 2 download and extract the most recent zip wad geo.zip
# ----------------------------------------------
# there should be a more graceful way to open the connection
drive_download("https://drive.google.com/file/d/1Nsflxin9ce8mFpDK_1uvgsC12mRitRDK/view?usp=sharing", 
               "downloaded_data/data.zip", overwrite = TRUE)

unzip("downloaded_data/data.zip", exdir = "source_data", overwrite = TRUE)


# 3 do any actual data preparation
# ----------------------------------------------

# 3a downsample large files 
# ----------------------------






# 3b derive data from downloads
# ----------------------------



# we should delete slope and aspect. They will not be needed anymore



# 4 rename and move files over to source_data
# --------------------------------------------




# 5 remove any files that are not needed
