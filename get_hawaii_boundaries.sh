#!/bin/bash

# quietly get the hawaii 2010 census boundaries file
# really any boundary file of the main islands will do
wget -q -O data/vector/boundary_main_islands.zip https://opendata.arcgis.com/datasets/cd53906603144267972de936428e340b_19.zip

unzip -d data/vector/boundary_main_islands data/vector/boundary_main_islands.zip

# get north west hawaiian islands
wget -q -O data/vector/boundary_nwhi.zip https://opendata.arcgis.com/datasets/bfd30253224c49358c11f45a97563ea9_0.zip

unzip -d data/vector/boundary_nwhi data/vector/boundary_nwhi.zip
