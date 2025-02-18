# Load required libraries
library(jsonlite)
library(curl)


#' Download files for an object in an OCFL storage root over https.
#' This assumes the storage root uses a flat-direct layout. 
#' 
#' @param ocfl_base_url URL for the OCFL storage root
#' @param object_id The Object ID
#' @param version the object's version to download (defaults to most recent version)
#' @param download_dir local folder where files are downloaded
#' @examples
#' ocfl_download("https://dreamlab-public.s3.us-west-2.amazonaws.com/ocfl", "geospatialRUCSBAtlas-data", "v2", "data")
ocfl_download <- function(ocfl_base_url, object_id, version="", download_dir="."){
  
  # base url for the object (assumes the OCFL root uses flat-direct layout).
  object_base_url <-paste(ocfl_base_url, object_id, sep="/")
  
  # url to object's root inventory.json
  inventory_url <- paste(object_base_url, "inventory.json", sep="/")
  
  # Download and parse the object inventory
  inventory <- fromJSON(inventory_url)
  manifest <- inventory$manifest
  if (version == "") {
    version <- inventory$head
  }
  state <- inventory$versions[[version]]$state
  # TODO: check that state is not null
  
  
  # the idea two sets of vectors: download source and dest, copy source and dets
  download_sources <- c()
  download_dests <- c()
  copy_sources <- c()
  copy_dests <- list()
  
  # build vectors
  for (digest in names(state)){
    remote_name <- manifest[[digest]][1]
    src_uri <- paste(object_base_url, remote_name, sep="/")
    local_file <- file.path(download_dir, state[[digest]][1])
    local_dir <- dirname(local_file)
    download_sources <- c(download_sources, src_uri)
    download_dests <- c(download_dests, local_file)
    if (!dir.exists(local_dir)) {
      dir.create(local_dir, recursive = TRUE)
    }
    
    if(length(state[[digest]]) > 1) {
      copy_sources <- c(copy_sources, local_file)  
      copy_dests <- c(copy_dests, state[[digest]][2:length(state[[digest]])])
    }
  }
  
  # download all files
  multi_download(download_sources, destfiles = download_dests, progress=TRUE)
  
  # do copies
  i <- 1
  for(local_source in copy_sources) {
    for(local_dest in copy_dests[[i]]){
      local_source <- file.path(download_dir, local_source)
      local_dir <- dirname(local_source)
      if (!dir.exists(local_dir)) {
        dir.create(local_dir, recursive = TRUE)
      }
      write(paste("using local copy for", local_dest), stderr())
      file.copy(local_source, local_dest)
    }
    i <- i+1
  } # copy loop
  
}

ocfl_root <- "https://dreamlab-public.s3.us-west-2.amazonaws.com/ocfl"
object_id <- "geospatialRUCSBAtlas-data"
ocfl_download(ocfl_root, object_id, version="v3", download_dir="source_data")
