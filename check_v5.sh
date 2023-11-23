#!/bin/bash
# /work/opa/visir/operational_scripts/check_v5.sh  > /work/opa/visir/operational_scripts/logs/check/check_v4_$(date +"%Y%m%d-%H%M").log &
##########################################
#
# Paths and routes
#
########################################## 

# paths
source $HOME/gutta_JUNO.conf
LOG_PATH=$OP_PATH_LOGS/out
ERR_PATH=$OP_PATH_LOGS/err

##########################################
#
# Telegram configuration file
#
########################################## 
# Notify 0 "Check" "2 message" # error message
# Notify 1 "Check" "3 message" # good message

##########################################
#
# Load utils
#
########################################## 
echo "source ${OP_PATH}/utils.sh"
source ${OP_PATH}/utils.sh



# Find the last run
LASTRUN_LOGFILE=$(ls $LOG_PATH/runVisir*log -tr | tail -1)
LASTRUN=$(basename $LASTRUN_LOGFILE | cut -f 2 -d "_" | cut -f 1 -d ".")
echo " - Last run identified is : $LASTRUN"

##########################################
#
# Checks
#
########################################## 

echo "Check script started now $(date)"
#Notify 2 "Check" "Script started now" 

COMPONENTS=(campi tracce visual csv2shape ) #  copyToN08  GUTTA_n08)
# check if we already notified this job
if [[ -e ${LOG_PATH}/last_job_notified.log ]] ; then 
	LAST_NOTIFIED_JOB=$(cat ${LOG_PATH}/last_job_notified.log)
	if [[ $LAST_NOTIFIED_JOB = $LASTRUN ]] ; then
		echo " -- Job already notified"
		exit    
	fi
fi

# check if all the components stopped running
for COMP in ${COMPONENTS[@]}; do
	echo "Analyzing $COMP ..."
    # log/err file names
	LOG=$(find ${LOG_PATH} -name ${COMP}_${LASTRUN}_\* | head -n 1)
    ERR=$(find ${ERR_PATH} -name ${COMP}_${LASTRUN}_\* | head -n 1)

	echo "LOG file is $LOG"
	echo "ERR file is $ERR"	

	if [[ ! -z "$LOG"  ]] ; then
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
			if [[ $TermSig -eq 1 ]]; then
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
	else 

		echo "LOG file not ready."
		# JOBS=$(bjobs )#| wc -l)


		JOBS=$(bjobs -o "JOB_NAME" -noheader | grep -v grep | wc -l )
		JOBS_RUN=$(bjobs -o "STAT" -noheader | grep RUN | wc -l )
		JOBS_PEND=$(bjobs -o "STAT" -noheader | grep PEND | wc -l ) 
		echo "Running JOBS are $JOBS"
		if [[ "$JOBS_RUN" -ge "1" ]] ; then
			echo " -- Because job still in progress ($JOBS_RUN)"
			exit
		else
			if [[ "$JOBS_PEND" -ge "1" ]]; then 
				echo " -- Because jobs are in PENDING."
				echo "Let's see the components."
			else 
				echo " -- Because there are no jobs to do"			
				exit
			fi  
			
		fi

	fi

done

# check if all the components stopped running
for COMP in ${COMPONENTS[@]}; do

    # log/err file names
    LOG=$(find ${LOG_PATH} -name ${COMP}_${LASTRUN}_\* | head -n 1)
    ERR=$(find ${ERR_PATH} -name ${COMP}_${LASTRUN}_\* | head -n 1)
	
	echo "========"
    echo "Parsing log files:"
    echo $LOG
    echo $ERR
    
	echo "update ${LOG_PATH}/last_job_notified.log with $LASTRUN"
	echo $LASTRUN > ${LOG_PATH}/last_job_notified.log
    
    # do the analysis
    echo " - Analysing component $COMP"    
    ERRORS_LINE=$(grep -ci "error" $ERR)
    #ERRORS_LINE=$(wc -l $ERR | cut -f 1 -d " ")

    echo " - $COMP has $ERRORS_LINE lines in the file $ERR."
    if [[ ! -z $ERRORS_LINE ]]; then
        if [[ $ERRORS_LINE -gt 0 ]]; then
		WARNING_TO_IGNORE=$(grep -i "warning" $ERR | wc -l)
		echo "WARNING_TO_IGNORE=$WARNING_TO_IGNORE"
		ERRORS_UPDATE=$(echo "$ERRORS_LINE - $WARNING_TO_IGNORE" | bc -l )
		echo "ERRORS_UPDATE=$ERRORS_UPDATE"
		if [[ $ERRORS_UPDATE -eq 0 ]] ; then

			echo " -- only warning not errors. ignore them... "
			echo "update ${LOG_PATH}/last_job_notified.log with $LASTRUN"
			echo $LASTRUN > ${LOG_PATH}/last_job_notified.log
		else
			echo " -- errors are real! MUST BE NOTIFIED"
			echo "update ${LOG_PATH}/last_job_notified.log with $LASTRUN"

			echo $LASTRUN > ${LOG_PATH}/last_job_notified.log
            	 	Notify 0 "Check" "${COMP} has ${ERRORS_LINE} error lines [run: $LASTRUN]. Have a look!"

		fi
	fi
    fi

done

echo "Finish check now $(date)"
