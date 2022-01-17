#!/bin/bash

##########################################
#
# Paths and routes
#
########################################## 

# paths and conf
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
echo "SOURCE PATH: $SRC" 

# set destination folder
DST=$N08BASE/${1}/$N08APPEND
echo "DESTINATION PATH: $DST"

##########################################
#
# Link
#
##########################################

# create a local link
echo "Moving to $DATAPRODUCTS"
cd ${DATAPRODUCTS}
echo "I'm in ${DATAPRODUCTS}"

echo "Removing link..."
rm ${DATAPRODUCTS}/latestProduction

echo "Creating link..."
ln -sf ${1} latestProduction -v

##########################################
#
# Copy
#
##########################################

if [[ $COPY -ne 0 ]]; then

    # create the destination folder if it does not exist
    ssh $N08ADDR "mkdir -p ${N08BASE}/${1}/AdriaticSea_nu04_inv012_T07/"
    
    # copy files
    scp -r ${SRC} ${DST}

fi
