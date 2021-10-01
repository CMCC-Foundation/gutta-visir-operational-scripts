#!/bin/bash

##########################################
#
# Paths and routes
#
########################################## 

# paths
OP_PATH=/work/opa/visir-dev/operational_scripts/
LOGS_PATH=/work/opa/visir-dev/operational_scripts/logs

##########################################
#
# Load utils
#
########################################## 

source ${OP_PATH}/utils.sh

##########################################
#
# Find the last run
#
########################################## 

LASTRUN_LOGFILE=$(ls /work/opa/visir-dev/operational_scripts/logs/runVisir*log -1 | tail -1)
LASTRUN=$(basename $LASTRUN_LOGFILE | cut -f 2 -d "_" | cut -f 1 -d ".")
echo " - Last run identified: $LASTRUN"

##########################################
#
# Checks
#
########################################## 

COMPONENTS=(campi tracce visual csv2shape copyToN08 GUTTA_n08)

# check if we already notified this job
LAST_NOTIFIED_JOB=$(cat ${LOGS_PATH}/last_job_notified.log)
if [[ $LAST_NOTIFIED_JOB = $LASTRUN ]] ; then
    echo " -- Job already notified"
    exit    
fi

# check which is the last run
for COMP in ${COMPONENTS[@]}; do

    # check if the run is still in progress
    JOBS=$(bjobs | wc -l)
    if [[ $JOBS -gt 1 ]]; then
        echo " -- Job still in progress"
        exit
    fi
    
    # do the analysis
    echo " - Analysing component $COMP"    
    ERRORS=$(find ${LOGS_PATH} -iname ${COMP}_${LASTRUN}\*err -exec wc -l {} \; | cut -f 1 -d " ")
    if [[ ! -z $ERRORS ]]; then
        if [[ $ERRORS -gt 0 ]]; then
            echo " -- Found $ERRORS errors: MUST BE NOTIFIED!"
            echo $LASTRUN > ${LOGS_PATH}/last_job_notified.log
            Notify 2 "Check" "${COMP} has ${ERRORS} error lines [run: $LASTRUN]"
        fi
    fi

done