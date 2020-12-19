#!/bin/bash

# quietly get the etopo data to the raster folder
wget -q -P data/raster https://www.ngdc.noaa.gov/mgg/global/relief/ETOPO1/data/bedrock/cell_registered/georeferenced_tiff/ETOPO1_Bed_c_geotiff.zip

# unzip in the same folder
unzip data/raster/*.zip -d data/raster/
