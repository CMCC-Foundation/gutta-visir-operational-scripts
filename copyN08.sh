#!/bin/bash

##########################################
#
# Paths and routes
#
########################################## 

# paths
source $HOME/gutta.conf

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

# set folder for copy
SRC=$SRCLINK/${1}/$SRCAPPEND

# Notify 2 "CopyN08" "Job starting"

# set destination folder
DST=$N08BASE/${1}/$N08APPEND

# before starting the copy, also create a local link
echo "Moving to $SRCLINK"
cd ${SRCLINK}
echo "I'm in ${SRCLINK}"

echo "Removing link..."
rm ${SRCLINK}/latestProduction

echo "Creating link..."
ln -sf ${1} latestProduction -v

# create the destination folder if it does not exist
ssh $N08ADDR "mkdir -p ${N08BASE}/${1}/AdriaticSea_nu04_inv012_T07/"

# copy files
scp -r ${SRC} ${DST}

# Notify 1 "CopyN08" "Job completed"
