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

# set destination folder
DST=$N08BASE/${1}/$N08APPEND


##########################################
#
# Link
#
##########################################

# create a local link
echo "Moving to $SRCLINK"
cd ${SRCLINK}
echo "I'm in ${SRCLINK}"

echo "Removing link..."
rm ${SRCLINK}/latestProduction

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
