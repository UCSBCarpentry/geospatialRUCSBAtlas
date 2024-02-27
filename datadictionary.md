# Data Files needed
Before we can integrate the files into the lesson scripts,
we need to know where we are going. Therefore, we need to build
the finished maps. 

This is a list of all the data required for the 7 maps 
described on the [Read Me](https://github.com/UCSBCarpentry/geospatialRUCSBAtlas/blob/main/README.md), as well as where they come into the episode flow.

Items from the Carpentry Google Drive are at 
`\\Carpentry\Workshop Development\Local Data for Workshops\geo`

* Hillshades at 3 scales and extents:
Which episodes do each of these come in?
What is their original source and format/CRS?
  * [The Bite of California](https://www.sciencebase.gov/catalog/item/542aebf9e4b057766eed286a)
    Elevation in the Western United States, 90 meter DEM, subsetted to CA
  * [Campus context: campus_topo_bath](https://pubs.usgs.gov/ds/781/)
    California State Waters Map Series, Offshore of Coal Oil Point, Block ID 63 
  * Henley Gate to Ellwood Beach: campus_topo_bath
  * we will need 3 tiffs out of data_prep.r for these
* Shapefiles
  * Walkways
  * Buildings
    * [Carpentry Google Drive](https://drive.google.com/drive/folders/1SwcCrBoa0a7I_kmBNCa3_zNQ6Aw9P-8H)
    Metadata says this came from the ICM on AGO circa 2017'ish.
  * Trees
  * Bike paths: 
     * original filename: bikelanescollapsedv8.shp
     * source_data/bike_paths/bike_paths.shp
     * DREAM Lab data drive collection
* Vernal pools
  * will be created by analysis in a script.
