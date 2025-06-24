#!/bin/bash
#############################
#
# CHECK SCRIPT  
#
#############################

# HOW TO LAUNCH :
# /users_home/cmcc/guttavisir-dev/gutta-visir-operational-scripts/check_v5.sh  > /work/cmcc/guttavisir-dev/gutta-visir-operational-scripts-logs/check/check_v5_$(date +"%Y%m%d-%H%M").log &

# Rolling Gutta-visir crontab
# 00 01 * * * /users_home/opa/guttavisir-dev/gutta-visir-operational-scripts/rolling.sh $(date +"\%Y\%m\%d") > /work/opa/guttavisir-dev/gutta-visir-operational-scripts-logs/logs/out/rolling_$(date +"\%Y\%m\%d").log &

##########################################
#
# Paths and routes
#
########################################## 
echo "source ~/.bashrc"
source ~/.bashrc

# paths
source $HOME/gutta_JUNO.conf

# logs
LOG_PATH=$OP_PATH_LOGS/out
ERR_PATH=$OP_PATH_LOGS/err

##########################################
#
# Telegram configuration file
#
########################################## 
# Notify 0 "Check" " message" # error message
# Notify 1 "Check" " message" # good message
# Notify 2 "Check" " message" # engine message
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

echo "Check production ${LASTRUN} started now $(date)"
# Notify 2 "Check" "Check production ${LASTRUN} started now $(date)" 


COMPONENTS=(campi tracce visual csv2shape copyToN08) #  copyToN08  GUTTA_n08)
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

		echo "LOG file not ready. Let's understand why... "
		

		# check the number of running jobs and pending jobs. 
		JOBS=$(bjobs -o "JOB_NAME" -noheader | grep -v grep | wc -l )
		JOBS_RUN=$(bjobs -o "STAT" -noheader | grep RUN | wc -l )
		JOBS_PEND=$(bjobs -o "STAT" -noheader | grep PEND | wc -l ) 
		echo "Running JOBS are $JOBS_RUN"
		echo "Pending jobs are $JOBS_PEND"

		if [[ "$JOBS_RUN" -ge "1" ]] ; then
			echo " -- Because there jobs running ($JOBS_RUN)"
			exit
		else
			# if there are pending jobs, see the previous job if end SUCCESFULLY or NOT.
				# IF PREV JOB ENDED with status SUCCESS -> wait
				# IF PREV JOB END WITH EXIT -> send notify
			if [[ "$JOBS_PEND" -ge "1" ]]; then
				PREV_JOB=$(bjobs -a | tail -n 1 | grep "DONE" | wc -l)
				if [[ "$PREV_JOB" -ge "1"   ]] ; then
						echo " -- Because there are pending jobs. The previous job ended succesfully, waiting the end of the pending jobs ($JOBS_PEND)."
						exit
				else
						echo " -- Because there are pending jobs, but previous job ended with an error. So they will never finish, send the notification."
						echo "Let's see the components."
				fi

			else
				echo " -- There are no running jobs, no pending jobs. But the run failed. We have to notify."
				Notify 0 "Check" "The run $LASTRUN failed. Have a look!"
				echo "update ${LOG_PATH}/last_job_notified.log with $LASTRUN"
				echo $LASTRUN > ${LOG_PATH}/last_job_notified.log
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
# Notify 1 "Check" "No error present" # good message
