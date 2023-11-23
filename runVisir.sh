#!/bin/bash

##########################################
#
# Help message
#
########################################## 

if [[ $1 == "--help" ]]; then
    echo "The standard way of invoking GUTTA is:"
    echo "   $ sh runVisir.sh <YYYYMMDD_HH>"
    echo
    echo "...but it is possible to execute a single component of the chain:"
    echo "   $ sh runVisir.sh <YYYYMMDD_HH> <component>"
    echo "where component is one of:"
    echo "Campi / Tracce / Visualizzazioni / csv2shape.sh / copyN08.sh / runN08.sh"
    echo
    exit
fi


##########################################
#
# Paths and routes
#
########################################## 

# paths
source $HOME/gutta_JUNO.conf
CAMPI_PATH=${BASE_PATH}/Campi
CAMPI_EXE=${CAMPI_PATH}/MAIN_campi.py
TRACCE_PATH=${BASE_PATH}/Tracce
TRACCE_EXE=${TRACCE_PATH}/MAIN_Tracce.py
VISUAL_PATH=${BASE_PATH}/Visualizzazioni
VISUAL_EXE=${VISUAL_PATH}/netCDF_generator.py
CSV2SHAPE_PATH=${OP_PATH}/
CSV2SHAPE_EXE=${CSV2SHAPE_PATH}/csv2shape.sh
COPYN08_PATH=${OP_PATH}/
COPYN08_EXE=${COPYN08_PATH}/copyN08.sh
RUNN08_PATH=${OP_PATH}/
RUNN08_EXE=${RUNN08_PATH}/runN08.sh

LOGS=${OP_PATH_LOGS}
echo "$LOGS"


echo "_---------------------"
echo $1
echo $2
echo "_---------------------"

# define the routes
ROUTES=('ALDRZ_ITBDS' 'ALDRZ_ITBRI' 'GRGPA_ITBDS' 'GRIGO_ITBDS' 'HRDBV_ITAOI' 'HRDBV_ITBDS' 'HRDBV_ITBRI' 'HRRJK_ITAOI' 'HRSPU_ITAOI' 'HRSPU_ITBRI' 'HRZAD_ITAOI' 'HRZAD_ITBLT' 'HRZAD_ITRAN' 'ITAOI_HRDBV' 'ITAOI_HRRJK' 'ITAOI_HRSPU' 'ITAOI_HRZAD' 'ITBDS_ALDRZ' 'ITBDS_GRGPA' 'ITBDS_GRIGO' 'ITBDS_HRDBV' 'ITBDS_MEBAR' 'ITBLT_HRZAD' 'ITBRI_ALDRZ' 'ITBRI_HRDBV' 'ITBRI_HRSPU' 'ITBRI_MEBAR' 'ITRAN_HRZAD' 'MEBAR_ITBDS' 'MEBAR_ITBRI')



##########################################
#
# Load utils
#
########################################## 

source ${OP_PATH}/utils.sh


##########################################
#
# bsub command re-definition
#
########################################## 

# redefining bsub
bsub () {
    echo bsub $* >&2
    command bsub $* | head -n1 | cut -d'<' -f2 | cut -d'>' -f1
}   


##########################################
#
# Initialisation
#
########################################## 

# source profile
source ~/.bash_profile

# module load
source ~/.bash_anaconda_3.7 

# activate conda environment
conda activate visir-venv



# set the python path
export PYTHONPATH="$BASE_PATH"

# read args
RUNDATE=$1
COMP=$2


##########################################
#
# Campi
#
########################################## 

if [[ $COMP == "" ]] || [[ $COMP == "Campi" ]]; then

    echo "===== Campi [requested on $(date)] ====="
    
    DATE=$(LANG=en_gb date +"%d%b%y")
    
    # define params
    SCRIPT_PAR=AdriaticSea_${DATE}    

    # invoke the job
    cd $CAMPI_PATH

    CAMPI_JOBID=$(bsub -ptl 720 -R "rusage[mem=1G]" -q s_medium -P R000 -J Campi -o ${OP_PATH_LOGS}/out/campi_$(date +%Y%m%d-%H%M)_%J.log -e ${OP_PATH_LOGS}/err/campi_$(date +%Y%m%d-%H%M)_%J.err "python $CAMPI_EXE $RUNDATE $GUTTA_PATHS")	


    #CAMPI_JOBID=$(bsub -ptl 720 -R "rusage[mem=1G]" -q s_medium -P R000 -J GUT_Campi -o ${LOGS}/logs/out/campi_$(date +%Y%m%d-%H%M)_%J.log -e ${LOGS}/logs/err/campi_$(date +%Y%m%d-%H%M)_%J.err "python $CAMPI_EXE $RUNDATE $GUTTA_PATHS")
    
fi


##########################################
#
# Tracce
#
##########################################

if [[ $COMP == "" ]] || [[ $COMP == "Tracce" ]]; then

    echo "===== Tracce [requested on $(date)] ====="
    cd $TRACCE_PATH
    
    if [[ $COMP == "Tracce" ]]; then
	   
	# Submit Tracce job array, without job dependency
	# from Campi, since we only want Tracce. Then exit
	# Submit Tracce job array, without job dependency
	# from Campi, since we only want Tracce. Then exit
	TRACCE_JOBID=$(bsub -ptl 720   -R "rusage[mem=4G]"  -q s_long -P R000 -J "GUTTA_Tracce[1-30]" -o ${OP_PATH_LOGS}/out/tracce_$(date +%Y%m%d-%H%M)_%J.log -e ${OP_PATH_LOGS}/err/tracce_$(date +%Y%m%d-%H%M)_%J.err  "python $TRACCE_EXE $RUNDATE $GUTTA_PATHS ${LSB_JOBINDEX}" &)
	
    else

	# Submit Tracce job array
	TRACCE_JOBID=$(bsub -ptl 720 -R "rusage[mem=4G]"   -q s_long -P R000 -w "done(${CAMPI_JOBID})" -J "GUTTA_Tracce[1-30]" -o ${OP_PATH_LOGS}/out/tracce_$(date +%Y%m%d-%H%M)_%J.log -e ${OP_PATH_LOGS}/err/tracce_$(date +%Y%m%d-%H%M)_%J.err  "python $TRACCE_EXE $RUNDATE $GUTTA_PATHS ${LSB_JOBINDEX}" &)

    fi    
    
fi


##########################################
#
# Visualizzazioni
#
##########################################

if [[ $COMP == "" ]] || [[ $COMP == "Visualizzazioni" ]]; then

    echo "===== Visualizzazioni [requested on $(date)] ====="   
    cd $VISUAL_PATH

    if [[ $COMP == "Visualizzazioni" ]]; then
    
	# Submit Visualizzazzioni job array without dependency
	# from Tracce, since we only want Visualizzazioni
	VISUAL_JOBID=$(bsub -ptl 720 -R "rusage[mem=4G]"  -q s_long -P R000 -J "GUTTA_Visual[1-30]" -o ${OP_PATH_LOGS}/out/visual_$(date +%Y%m%d-%H%M)_%J.log -e ${OP_PATH_LOGS}/err/visual_$(date +%Y%m%d-%H%M)_%J.err  "python $VISUAL_EXE $RUNDATE $GUTTA_PATHS ${LSB_JOBINDEX}" &)

    else

	# Submit Visualizzazzioni job array
      	VISUAL_JOBID=$(bsub -ptl 720  -R "rusage[mem=4G]"    -q s_long -P R000 -w "done(${TRACCE_JOBID})" -J "GUTTA_Visual[1-30]" -o ${OP_PATH_LOGS}/out/visual_$(date +%Y%m%d-%H%M)_%J.log -e ${OP_PATH_LOGS}/err/visual_$(date +%Y%m%d-%H%M)_%J.err  "python $VISUAL_EXE $RUNDATE $GUTTA_PATHS ${LSB_JOBINDEX}" &)
	
    fi
    
fi
    

##########################################
#
# Csv 2 shape
#
##########################################

if [[ $COMP == "" ]] || [[ $COMP == "csv2shape.sh" ]]; then

    echo "===== csv2shape [requested on $(date)] ====="
    cd $CSV2SHAPE_PATH/

    if [[ $COMP == "csv2shape.sh" ]]; then
    
	# Submit csv2shape job array without job dependencies
	# since we only want csv2shape 
	CSV_JOBID=$(bsub -ptl 720 -R "rusage[mem=2G]"  -q s_long -P R000 -J 'GUTTA_csv2shape' -o ${OP_PATH_LOGS}/out/csv2shape_$(date +%Y%m%d-%H%M)_%J.log -e ${OP_PATH_LOGS}/err/csv2shape_$(date +%Y%m%d-%H%M)_%J.err "sh ${CSV2SHAPE_EXE} $RUNDATE" &)

	
    else

	# Submit csv2shape job array
	CSV_JOBID=$(bsub -ptl 720 -R "rusage[mem=2G]"  -q s_long -P R000 -w "done($VISUAL_JOBID)" -J 'GUTTA_csv2shape' -o ${OP_PATH_LOGS}/out/csv2shape_$(date +%Y%m%d-%H%M)_%J.log -e ${OP_PATH_LOGS}/err/csv2shape_$(date +%Y%m%d-%H%M)_%J.err "sh ${CSV2SHAPE_EXE} $RUNDATE" &)

    fi
fi


##########################################
#
# Copy to N08
#
##########################################

#if [[ $COMP == "" ]] || [[ $COMP == "copyN08.sh" ]]; then
    
#    echo "===== copyN08 [requested on $(date)] ====="
#    cd $COPYN08_PATH/
    
#    # Copy files to n08
#    if [[ $COMP == "copyN08.sh" ]]; then
#	
#	# submit the job without job dependency since
#	# we only want to run copyN08.sh
#	COPYN08_JOBID=$(bsub -ptl 720  -R "rusage[mem=1G]"   -q s_medium -P R000 -o ${OP_PATH_LOGS}/out/copyToN08_$(date +%Y%m%d-%H%M)_%J.out -e ${OP_PATH_LOGS}/err/copyToN08_$(date +%Y%m%d-%H%M)_%J.err -J 'GUTTA_copyToN08' "sh ${COPYN08_EXE} ${RUNDATE}" &)	
	
#    else
	
#	# invoke the job
#	COPYN08_JOBID=$(bsub -ptl 720  -R "rusage[mem=1G]"  -q s_medium -P R000 -w "done($CSV_JOBID)" -o ${OP_PATH_LOGS}/out/copyToN08_$(date +%Y%m%d-%H%M)_%J.out -e ${OP_PATH_LOGS}/err/copyToN08_$(date +%Y%m%d-%H%M)_%J.err -J 'GUTTA_copyToN08' "sh ${COPYN08_EXE} ${RUNDATE}" &)	
	
#    fi
#fi


##########################################
#
# Execute a command on N08
#
#if [[ $COMP == "" ]] || [[ $COMP == "runN08.sh" ]]; then

#    echo "===== runN08 [requested on $(date)] ====="
#    cd $RUNN08_PATH/
#
#    if [[ $COMP == "runN08.sh" ]]; then
#
#	# sumbit the job without job dependency since
#	# we only want to run this script
#	N08_JOBID=$(bsub -ptl 720  -R "rusage[mem=1G]"  -q s_medium -P R000 -o ${OP_PATH_LOGS}/out/GUTTA_n08_$(date +%Y%m%d-%H%M)_%J.out -e ${OP_PATH_LOGS}/err/GUTTA_n08_$(date +%Y%m%d-%H%M)_%J.err -J 'GUTTA_n08' "sh ${RUNN08_EXE} ${RUNDATE}" &)

#    else

#	# invoke the job
#	N08_JOBID=$(bsub -ptl 720 -R "rusage[mem=1G]" -q s_medium -P R000 -w "done($COPYN08_JOBID)" -o ${OP_PATH_LOGS}/out/GUTTA_n08_$(date +%Y%m%d-%H%M)_%J.out -e ${OP_PATH_LOGS}/err/GUTTA_n08_$(date +%Y%m%d-%H%M)_%J.err -J 'GUTTA_n08' "sh ${RUNN08_EXE} ${RUNDATE}" &)
	
#    fi
#fi
