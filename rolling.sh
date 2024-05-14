#!/bin/bash
#############################
#
# ROLLING SCRIPT  
#
#############################

#HOW TO RUN : 
# /users_home/cmcc/guttavisir-dev/gutta-visir-operational-scripts/rolling.sh > /work/cmcc/guttavisir-dev/gutta-visir-operational-scripts-logs/out/rolling_$(date +"%Y%m%d_%H%M").log 2> /work/cmcc/guttavisir-dev/gutta-visir-operational-scripts-logs/err/rolling_$(date +"%Y%m%d_%H%M").err  &

# Rolling Gutta-visir crontab 
# 00 00 * * * /users_home/cmcc/guttavisir-dev/gutta-visir-operational-scripts/rolling.sh > /work/cmcc/guttavisir-dev/gutta-visir-operational-scripts-logs/out/rolling_$(date +"\%Y\%m\%d").log 2> /work/cmcc/guttavisir-dev/gutta-visir-operational-scripts-logs/err/rolling_$(date +"\%Y\%m\%d").err  &

# paths
source $HOME/gutta_JUNO.conf

# load utils
source ${OP_PATH}/utils.sh

# determine today's date
TODAY=$(date +"%Y%m%d")


# path - PROD

#BASEPATH=${OP_PATH}
LOGFOLDER=${OP_PATH_LOGS}/
OUT_LOGS_DIR=${LOGFOLDER}/out
ERR_LOGS_DIR=${LOGFOLDER}/err
CHECK_LOGS_DIR=${LOGFOLDER}/check


DYNAMIC_DATA=${DATAPRODUCTS} #/data/products/GUTTA-VISIR/VISIR-2/_products/dynamic   
N08_GUTTA_VISIR_BASE_PATH=/var/www/html/cache/_VISIR-GUTTA/


# debug print
echo "============================================"
echo "Rolling script is starting... Now is $(date)"
echo "============================================"

DAYS_TO_PRESERVE=30

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
    CAMIDDLE="${CAMIDDLE} -not -name '*_${WDATE}*.*'"
    echo "file to preserve will be : $CAMIDDLE "
done

if [[ ! -z ${OUT_LOGS_DIR} ]] && [[ ! -z ${ERR_LOGS_DIR} ]] ; then 
    # if the paths  exist and are all defined rolling logs 
    echo "OUT_LOGS_DIR=${OUT_LOGS_DIR}, ERR_LOGS_DIR=${ERR_LOGS_DIR} are defined."
    LOGS_READ="find ${OUT_LOGS_DIR} ${ERR_LOGS_DIR}  ${CAMIDDLE} -not -name .keep  -not -name ${PRESERVE_FILE} -type f -exec echo -v {} \; "  # rm -rf or echo -v
    echo "READING files..."
    eval $LOGS_READ
    LOGS_REM="find ${OUT_LOGS_DIR} ${ERR_LOGS_DIR}  ${CAMIDDLE} -not -name .keep  -not -name ${PRESERVE_FILE} -type f -exec rm -rf {} \; "  # rm -rf or echo -v
    echo "REMOVING these files..."
    eval $LOGS_REM

else 
    echo "OUT_LOGS_DIR, ERR_LOGS_DIR and CHECK_LOGS_DIR is not defined. Exiting... "
fi


# check 
# if [[ ! -z ${CHECK_LOGS_DIR} ]] ; then 
#     # if the paths  exist and are all defined rolling logs 
#     echo "CHECK_LOGS_DIR=${CHECK_LOGS_DIR} defined."
#     LOGS_REM="find ${CHECK_LOGS_DIR}  -not -name .keep  -mtime +1 -type f -exec echo -v {} \; "  # rm -rf or echo -v
#     echo "READING files..."
#     eval $LOGS_REM

# else 
#     echo "CHECK_LOGS_DIR is not defined. Exiting... "
# fi


# and later remove 
# ...
###############################################
#
# Rolling mapfiles and logs on N08
#
###############################################
# echo -e "\n\n=== Rolling mapfiles and logs on N08 ==="
# N08_ADDRESS=${N08ADDR}

# echo -e "Connect to ${N08_ADDRESS} via ssh and run rolling_mapfiles script"
# look if reachble from JUNO 
#ssh ${N08_ADDRESS} "sh  ${N08_GUTTA_VISIR_BASE_PATH}/scripts/rolling_mapfiles.sh $TODAY >> ${N08_GUTTA_VISIR_BASE_PATH}/scripts/logs/rolling_$(date +"%Y%m%d").log  $TODAY"

# echo "Results of the rolling in N08 can be find in the file ${N08_GUTTA_VISIR_BASE_PATH}/scripts/logs. "


##############################################################
#
# DATA PRODUCTS on _dynamic
# -- delete /data/products/GUTTA-VISIR_DEV/_products/dynamic/<REF_DATE>_<hh>/AdriaticSea_nu04_inv012_T07/Campi
# -- delete /data/products/GUTTA-VISIR_DEV/_products/dynamic/<REF_DATE>_<hh>/AdriaticSea_nu04_inv012_T07/Visualizzazioni
#  DELETE TRACCE COMPONENT BEFORE 04/11/2021

##############################################################
echo "=== Rolling ${DYNAMIC_DATA} ==="

echo "Find Campi and Visualizzazioni folder in  ${DYNAMIC_DATA} older than ${DAYS_TO_PRESERVE} days"
DATA_DIR_READ="find ${DYNAMIC_DATA}  -maxdepth 3  -mindepth 3  -not -name 'Tracce'  -mtime +${DAYS_TO_PRESERVE} -type d -exec echo -v {} \; "  # rm -rf or echo -v
eval $DATA_DIR_READ
DATA_DIR_REM="find ${DYNAMIC_DATA}  -maxdepth 3  -mindepth 3  -not -name 'Tracce'  -mtime +${DAYS_TO_PRESERVE} -type d -exec rm -rf {} \; "  # rm -rf or echo -v
#DATA_DIR_REM="find ${DYNAMIC_DATA} -maxdepth 3  -mindepth 3  -not -name 'Tracce' -mtime +31 -type d  | xargs rm -r"
echo "and delete ..."
eval $DATA_DIR_REM


echo "==============================================="
echo "Rolling script is completed at $(date)"
echo "==============================================="
