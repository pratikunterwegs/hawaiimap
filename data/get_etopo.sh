#!/bin/bash

# quietly get the etopo data to the raster folder
wget -q -P raster https://www.ngdc.noaa.gov/mgg/global/relief/ETOPO1/data/bedrock/cell_registered/georeferenced_tiff/ETOPO1_Bed_c_geotiff.zip

# unzip in the same folder
unzip raster/*.zip -d raster/
