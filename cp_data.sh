#!/bin/bash
# The goal of the scripts is to copy from SRC_DIR to DST_DIR the folder of datas.
#

##########################################
#
# Paths and routes
#
########################################## 

APPNAME="COPY products data"

echo "[$APPNAME] Start"

# define paths
SRC_DIR=/data/opa/visir-dev/VISIR-2/_products/dynamic/
DST_DIR=/data/products/GUTTA-VISIR/VISIR-2/_products/dynamic/

#tranche dec 2021 pt2
DATES=('20211227_04' '20211227_20' '20211228_04' '20211228_20' '20211229_04' '20211229_20' '20211230_04' '20211230_20' '20211231_04' '20211231_20')

# create function
CP() {
    mkdir -p $(dirname "$2") && cp -r "$1" "$2"
}


for DATE in ${DATES[*]}; do
    echo "cicle over $DATE"
    
    if [[ -e ${SRC_DIR}/$DATE ]] ; then 
        echo -e "Dir ${SRC_DIR}/$DATE exist.\n I can copy on ${DST_DIR}"
        #echo "COMMAND to launch is : CP ${SRC_DIR}/$DATE ${DST_DIR}"
        CP ${SRC_DIR}/$DATE ${DST_DIR}
    else 
        echo "Dir ${SRC_DIR}/$DATE not exist."
    fi

done

echo "[$APPNAME] Finish"



