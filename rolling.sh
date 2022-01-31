#!/bin/bash
#############################
#
# ROLLING SCRIPT  
#
#############################

# paths
source $HOME/gutta.conf

# load utils
source ${OP_PATH}/utils.sh

# determine today's date
TODAY=$(date +"%Y%m%d")


# path - PROD
BASEPATH=${OP_PATH}
LOGFOLDER=${BASEPATH}/logs
OUT_LOGS_DIR=${LOGFOLDER}/out
ERR_LOGS_DIR=${LOGFOLDER}/err
DYNAMIC_DATA=${DATAPRODUCTS} #/data/products/GUTTA-VISIR/VISIR-2/_products/dynamic   
N08_GUTTA_VISIR_BASE_PATH=/var/www/html/cache/_VISIR-GUTTA/


# debug print
echo "============================================"
echo "Rolling script is starting... Now is $(date)"
echo "============================================"

DAYS_TO_PRESERVE=31

###############################
#
# Logs 
#
###############################
echo "=== Rolling logs file ==="

# init preserve list
CAMIDDLE=""

# Preserve from delete the file last_job_notified.log
PRESERVE_FILE="last_job_notified.log"

# preserve log files
for D in $(seq ${DAYS_TO_PRESERVE} -1 0); do

    # determine PROD date to preserve
    WDATE=$(date -d "${TODAY} -${D}days" +"%Y%m%d")
    echo " - Preserving files with date PRODUCTION DATE=$WDATE"

    # file that contain PRODUCTION_DATE (long version) inside the filename
    CAMIDDLE="${CAMIDDLE} -not -name '*${WDATE}*.*'"
done

LOGS_REM="find ${OUT_LOGS_DIR} ${ERR_LOGS_DIR}  ${CAMIDDLE}  -not -name .keep -not -name ${PRESERVE_FILE} -type f -exec rm  -v {} \; "
echo "Removing files..."
eval $LOGS_REM

###############################################
#
# Rolling mapfiles and logs on N08
#
###############################################
echo -e "\n\n=== Rolling mapfiles and logs on N08 ==="
N08_ADDRESS=${N08ADDR}

echo -e "Connect to ${N08_ADDRESS} via ssh and run rolling_mapfiles script"
ssh ${N08_ADDRESS} "sh  ${N08_GUTTA_VISIR_BASE_PATH}/scripts/rolling_mapfiles.sh $TODAY >> ${N08_GUTTA_VISIR_BASE_PATH}/scripts/logs/rolling_$(date +"%Y%m%d").log  $TODAY"

##############################################################
#
# DATA PRODUCTS on _dynamic
# -- delete /data/products/GUTTA-VISIR/VISIR-2/_products/dynamic/<REF_DATE>_<hh>/AdriaticSea_nu04_inv012_T07/Campi
# -- delete /data/products/GUTTA-VISIR/VISIR-2/_products/dynamic/<REF_DATE>_<hh>/AdriaticSea_nu04_inv012_T07/Visualizzazioni
#  DELETE TRACCE COMPONENT BEFORE 04/11/2021
#
##############################################################

echo -e "\n\n=== Rolling on ${DYNAMIC_DATA} ==="

echo "Find Campi and Visualizzazioni folder in  ${DYNAMIC_DATA} older than ${DAYS_TO_PRESERVE} days"
DATA_DIR_REM="find ${DYNAMIC_DATA}  -maxdepth 3  -mindepth 3  -mtime +${DAYS_TO_PRESERVE} -not -name 'Tracce' -type d -exec rm -rf {} -v \;"
echo "Removing data products directories..."
eval $DATA_DIR_REM


echo "==============================================="
echo "Rolling script is completed at $(date)"
echo "==============================================="
