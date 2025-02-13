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
  # TODO: check that state no null
  
  # for each digest in the version state:
  # - find its manifest entry (content source)
  # - for each local path with the digest:
  # - - download content if needed,
  for (digest in names(state)){
    src_file <- manifest[[digest]][1]
    src_uri <- paste(object_base_url, src_file, sep="/")
    local_copy <- ""
    
    for(name in state[[digest]]) {
      dst_file <- file.path(download_dir, name)
      dst_dir <- dirname(dst_file)
      tryCatch({
        if (!dir.exists(dst_dir)) {
          dir.create(dst_dir, recursive = TRUE)
        }
      }, error = function(e) {
        cat("Failed to create directory:", dst_dir, "\n")
      })
      # download or copy?
      if (local_copy == "") {
        curl_download(src_uri, destfile=dst_file, quiet=FALSE)
        local_copy <- dst_file
      } else {
        write(paste(" using local copy:", name), stderr())
        file.copy(local_copy, dst_file)
      }
    }
  }
}

ocfl_root <- "https://dreamlab-public.s3.us-west-2.amazonaws.com/ocfl"
object_id <- "geospatialRUCSBAtlas-data"
ocfl_download(ocfl_root, object_id, version="v3", download_dir="source_data")
