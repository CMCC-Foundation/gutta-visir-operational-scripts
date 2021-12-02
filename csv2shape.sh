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

# SENT=1
# while [[ ! $SENT -eq 0 ]]; do
#     Notify 2 "Csv2shape" "Job starting -- [$LSB_JOBINDEX]"
#     SENT=$?
#     if [[ $SENT -eq 0 ]]; then        
#         break
#     fi
#     sleep 6
# done


RUNDATE=$1

# load anaconda conf
source ~/.bash_anaconda_3.7

# activate environment
conda activate csv2shape

# define routes
ROUTES=('ALDRZ_ITBDS' 'ALDRZ_ITBRI' 'GRGPA_ITBDS' 'GRIGO_ITBDS' 'HRDBV_ITBDS' 'HRDBV_ITBRI' 'HRRJK_ITAOI' 'HRSPU_ITAOI' 'HRSPU_ITBRI' 'HRZAD_ITAOI' 'HRZAD_ITBLT' 'HRZAD_ITRAN' 'ITAOI_HRDBV' 'ITAOI_HRRJK' 'ITAOI_HRSPU' 'ITAOI_HRZAD' 'ITBDS_ALDRZ' 'ITBDS_GRGPA' 'ITBDS_GRIGO' 'ITBDS_HRDBV' 'ITBDS_MEBAR' 'ITBLT_HRZAD' 'ITBRI_ALDRZ' 'ITBRI_HRDBV' 'ITBRI_HRSPU' 'ITBRI_MEBAR' 'ITRAN_HRZAD' 'MEBAR_ITBDS' 'MEBAR_ITBRI' 'HRDBV_ITAOI')
ROUTE=${ROUTES[$LSB_JOBINDEX]}


# process csv files
 echo "find /data/opa/visir-dev/VISIR-2/_products/dynamic/${RUNDATE}/AdriaticSea_nu04_inv012_T07/Visualizzazioni/${ROUTE} -iname \*csv -exec python csv2shape.py -i {} \;"
 find ${SRCLINK}/${RUNDATE}/${SRCAPPEND}/${ROUTE} -iname \*csv -exec python csv2shape.py -i {} \;

# deactivate environment
conda deactivate


# SENT=1
# while [[ ! $SENT -eq 0 ]]; do
#     Notify 1 "Csv2shape" "Job completed -- [$LSB_JOBINDEX]"
#     SENT=$?
#     if [[ $SENT -eq 0 ]]; then        
#         break
#     fi
#     sleep 6
# done
