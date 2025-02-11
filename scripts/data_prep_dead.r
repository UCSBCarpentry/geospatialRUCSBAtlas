# this is the remains of the old data_prep.r

library(terra)
library(curl)
library(googledrive)
library(tidyverse)
library(sf)

# to connect to AGO data
library(arcgisutils)

dir.create("downloaded_data", showWarnings = FALSE)
dir.create("source_data", showWarnings = FALSE)


# this is Julien's(?) batch process that Jon wanted to mimic:

building_dir_url = "https://drive.google.com/drive/folders/1SwcCrBoa0a7I_kmBNCa3_zNQ6Aw9P-8H"
building_dir = drive_get(building_dir_url)

# create local dir
dir_local <- file.path("source_data",  tolower(building_dir$name))
dir.create(dir_local, showWarnings = FALSE)

# find files in folder on GD
files = drive_ls(building_dir)
files_bind <- bind_rows(files)

# Batch download the files
map2(files_bind$id, files_bind$name, ~drive_download(as_id(.x), path = file.path(dir_local, .y), overwrite = TRUE))







