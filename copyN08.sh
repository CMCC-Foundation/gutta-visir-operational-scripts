#!/bin/bash

##########################################
#
# Paths and routes
#
########################################## 

# paths
OP_PATH=/work/opa/visir-dev/operational_scripts/

##########################################
#
# Load utils
#
########################################## 

source ${OP_PATH}/utils.sh


##########################################
#
# Start doing things...
#
########################################## 

# Notify 2 "CopyN08" "Job starting"

# set folder for link
SRCLNK=/data/opa/visir-dev/VISIR-2/_products/dynamic/

# set folder to copy
SRC=/data/opa/visir-dev/VISIR-2/_products/dynamic/${1}/AdriaticSea_nu04_inv012_T07/Visualizzazioni/

# set destination folder
DST=dss@192.168.118.150:/data/GUTTA/dynamic/${1}/AdriaticSea_nu04_inv012_T07/

# before starting the copy, also create a local link
echo "Moving to $SRCLNK"
cd ${SRCLNK}
echo "I'm in ${SRCLNK}"

echo "Removing link..."
rm ${SRCLNK}/latestProduction

echo "Creating link..."
ln -sf ${1} latestProduction -v

# create the destination folder if it does not exist
ssh dss@192.168.118.150 "mkdir -p /data/GUTTA/dynamic/${1}/AdriaticSea_nu04_inv012_T07/"

# copy files
scp -r ${SRC} ${DST}

# Notify 1 "CopyN08" "Job completed"
