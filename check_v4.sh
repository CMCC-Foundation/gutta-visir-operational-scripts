#!/bin/bash

##########################################
#
# Paths and routes
#
########################################## 

# paths
source $HOME/gutta.conf
LOG_PATH=$OP_PATH/logs/out
ERR_PATH=$OP_PATH/logs/err

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

LASTRUN_LOGFILE=$(ls $LOG_PATH/runVisir*log -tr | tail -1)
LASTRUN=$(basename $LASTRUN_LOGFILE | cut -f 2 -d "_" | cut -f 1 -d ".")
echo " - Last run identified is : $LASTRUN"

##########################################
#
# Checks
#
########################################## 

COMPONENTS=(campi tracce visual csv2shape copyToN08  GUTTA_n08)

# check if we already notified this job
LAST_NOTIFIED_JOB=$(cat ${LOG_PATH}/last_job_notified.log)
if [[ $LAST_NOTIFIED_JOB = $LASTRUN ]] ; then
    echo " -- Job already notified"
    exit    
fi

# check if all the components stopped running
for COMP in ${COMPONENTS[@]}; do

    # log/err file names
    LOG=$(find ${LOG_PATH} -name ${COMP}_${LASTRUN}_\* | head -n 1)
    ERR=$(find ${ERR_PATH} -name ${COMP}_${LASTRUN}_\* | head -n 1)

    # get termination signals for the component
    TermSig=$(grep "Terminated" $LOG | wc -l)
    
    case $COMP in
	
	"campi")
	    if [[ $TermSig -eq 1 ]]; then
		echo "$COMP terminated"
	    else
		echo "$COMP still to complete! Exiting..."
		exit
	    fi	    
	    ;;
	"tracce")
	    if [[ $TermSig -eq 30 ]]; then
		echo "$COMP terminated"
	    else
		echo "$COMP still to complete! Exiting..."
		exit
	    fi
	    ;;
	"visual")
	    if [[ $TermSig -eq 30 ]]; then
		echo "$COMP terminated"
	    else
		echo "$COMP still to complete! Exiting..."
		exit
	    fi
	    ;;
	"csv2shape")
	    if [[ $TermSig -eq 30 ]]; then
		echo "$COMP terminated"
	    else
		echo "$COMP still to complete! Exiting..."
		exit
	    fi
	    ;;
	"copyToN08")
	    if [[ $TermSig -eq 1 ]]; then
		echo "$COMP terminated"
	    else
		echo "$COMP still to complete! Exiting..."
		exit
	    fi
	    ;;
	"GUTTA_n08")
	    if [[ $TermSig -eq 1 ]]; then
		echo "$COMP terminated"
	    else
		echo "$COMP still to complete! Exiting..."
		exit
	    fi
	    ;;
	*)
	    echo "ELSE"
	    ;;
    esac
done

# check if all the components stopped running
for COMP in ${COMPONENTS[@]}; do

    # log/err file names
    LOG=$(find ${LOG_PATH} -name ${COMP}_${LASTRUN}_\* | head -n 1)
    ERR=$(find ${ERR_PATH} -name ${COMP}_${LASTRUN}_\* | head -n 1)

    echo "Parsing log files:"
    echo $LOG
    echo $ERR
    echo "========"
    
    # do the analysis
    echo " - Analysing component $COMP"    
    ERRORS=$(wc -l $ERR | cut -f 1 -d " ")
    echo " - $COMP has  $ERRORS errors."
    if [[ ! -z $ERRORS ]]; then
        if [[ $ERRORS -gt 0 ]]; then
            echo " -- Found $ERRORS errors: MUST BE NOTIFIED!"
            echo $LASTRUN > ${LOG_PATH}/last_job_notified.log
            Notify 2 "Check" "${COMP} has ${ERRORS} error lines [run: $LASTRUN]"   
	fi
    fi

done
