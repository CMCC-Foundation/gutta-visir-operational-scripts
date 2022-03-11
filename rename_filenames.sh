#!/bin/bash
# The goal of the scripts is to rename old filenames from  XXXX_YYY_cwx_voyageplan.json to XXXX_cwx_voyageplan.json
# dove XXXX=CO2t, dist e time

##########################################
#
# Paths and routes
#
########################################## 

APPNAME="Rename filename voyageplan"

echo "[$APPNAME] Start"

# define paths
DIR=/data/products/GUTTA-VISIR/VISIR-2/_products/dynamic/

#find /data/products/GUTTA-VISIR/VISIR-2/_products/dynamic/ -iname '*_*_cwx_voyageplan.json'
#LIST=$(find ${DIR} -iname '*_*_cwx_voyageplan.json') 
#echo -e "i file da cambiare sono:\n$LIST\n"


last="_cwx_voyageplan.json"
for i in $(find ${DIR} -iname '*_*_cwx_voyageplan.json'); do
        
    #get the path of the file  XXXX_YYY_cwx_voyageplan.json
    pathfile=${i%/*}
    #get the name of the file : XXXX_YYY_cwx_voyageplan.json
    fileN="$(basename ${i})"

    #from the filename get the first part XXXX
    first=${fileN%%_*}  
    
    #new name is :XXXX_cwx_voyageplan.json
    new_i="$first""$last"
    
    echo "mv from ${i}  to $pathfile/$new_i"
    mv ${i} $pathfile/$new_i
done

echo "[$APPNAME] Finish"
