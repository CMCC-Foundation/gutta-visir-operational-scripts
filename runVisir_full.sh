#!/bin/bash

##########################################
#
# Paths and routes
#
########################################## 

# paths
BASE_PATH=/work/opa/visir-dev/VISIR-2/
OP_PATH=/work/opa/visir-dev/operational_scripts/
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
conda activate visir

# set the python path
export PYTHONPATH='/work/opa/visir-dev/VISIR-2'

# determine rundate
RUNDATE=$1
echo "+++++++++++++++++++++++++++++++++++++++++++"
echo $RUNDATE
echo "+++++++++++++++++++++++++++++++++++++++++++"

##########################################
#
# Campi
#
########################################## 

echo "===== Campi [requested on $(date)] ====="

DATE=$(LANG=en_gb date +"%d%b%y")

# define params
SCRIPT_PAR=AdriaticSea_${DATE}

# invoke the job
cd $CAMPI_PATH
CAMPI_JOBID=$(bsub -ptl 720 -R "span[ptile=1]" -q s_medium -P 0338 -J VISIR2_Campi -o /work/opa/visir-dev/operational_scripts/logs/campi_$(date +%Y%m%d-%H%M)_%J.log -e /work/opa/visir-dev/operational_scripts/logs/campi_$(date +%Y%m%d-%H%M)_%J.err "python $CAMPI_EXE $RUNDATE")

# Notify 2 "Campi" "Job submitted with id ${CAMPI_JOBID}"


##########################################
#
# Tracce
#
##########################################

echo "===== Tracce [requested on $(date)] ====="

# Submit Tracce job array
cd $TRACCE_PATH
# TRACCE_JOBID=$(bsub -ptl 720 -R "span[ptile=1]" -q s_long -P 0338 -w "done(${CAMPI_JOBID})" -J "GUTTA_Tracce[1-30]" -o /work/opa/visir-dev/operational_scripts/logs/tracce_$(date +%Y%m%d-%H%M)_%J.log -e /work/opa/visir-dev/operational_scripts/logs/tracce_$(date +%Y%m%d-%H%M)_%J.err  "python $TRACCE_EXE ${LSB_JOBINDEX}" &)
TRACCE_JOBID=$(bsub -ptl 720 -q s_long -P 0338 -w "done(${CAMPI_JOBID})" -J "GUTTA_Tracce[1-30]" -o /work/opa/visir-dev/operational_scripts/logs/tracce_$(date +%Y%m%d-%H%M)_%J.log -e /work/opa/visir-dev/operational_scripts/logs/tracce_$(date +%Y%m%d-%H%M)_%J.err  "python $TRACCE_EXE $RUNDATE ${LSB_JOBINDEX}" &)

# Notify 2 "Tracce" "Job submitted with id ${TRACCE_JOBID}"


##########################################
#
# Visualizzazioni
#
##########################################

echo "===== Visualizzazioni [requested on $(date)] ====="

# Submit Visualizzazzioni job array
cd $VISUAL_PATH
VISUAL_JOBID=$(bsub -ptl 720 -R "span[ptile=1]" -q s_long -P 0338 -w "done(${TRACCE_JOBID})" -J "GUTTA_Visual[1-30]" -o /work/opa/visir-dev/operational_scripts/logs/visual_$(date +%Y%m%d-%H%M)_%J.log -e /work/opa/visir-dev/operational_scripts/logs/visual_$(date +%Y%m%d-%H%M)_%J.err  "python $VISUAL_EXE ${LSB_JOBINDEX}" &)

# Notify 2 "Visual" "Job submitted with id ${VISUAL_JOBID}"


##########################################
#
# Csv 2 shape
#
##########################################

echo "===== csv2shape [requested on $(date)] ====="

# Submit csv2shape job array
cd $CSV2SHAPE_PATH/
CSV_JOBID=$(bsub -ptl 720 -R "span[ptile=1]" -q s_long -P 0338 -w "done($VISUAL_JOBID)" -J 'GUTTA_csv2shape[1-30]' -o /work/opa/visir-dev/operational_scripts/logs/csv2shape_$(date +%Y%m%d-%H%M)_%J.log -e /work/opa/visir-dev/operational_scripts/logs/csv2shape_$(date +%Y%m%d-%H%M)_%J.err "sh ${CSV2SHAPE_EXE} $RUNDATE ${LSB_JOBINDEX}" &)

# Notify 2 "Csv2shape" "Job submitted with id ${CSV_JOBID}"


##########################################
#
# Copy to N08
#
##########################################

echo "===== copyN08 [requested on $(date)] ====="

# Copy files to n08
cd $COPYN08_PATH/
COPYN08_JOBID=$(bsub -ptl 720 -R "span[ptile=1]" -q s_medium -P 0338 -w "done($CSV_JOBID)" -o /work/opa/visir-dev/operational_scripts/logs/copyToN08_$(date +%Y%m%d-%H%M)_%J.out -e /work/opa/visir-dev/operational_scripts/logs/copyToN08_$(date +%Y%m%d-%H%M)_%J.err -J 'GUTTA_copyToN08' "sh ${COPYN08_EXE} ${RUNDATE}" &)

# Notify 2 "CopyN08" "Job submitted with id ${COPYN08_JOBID}"


##########################################
#
# Execute a command on N08
#
##########################################

echo "===== runN08 [requested on $(date)] ====="

# Submit final request to n08
cd $RUNN08_PATH/
N08_JOBID=$(bsub -ptl 720 -R "span[ptile=1]" -q s_medium -P 0338 -w "done($COPYN08_JOBID)" -o /work/opa/visir-dev/operational_scripts/logs/GUTTA_n08_$(date +%Y%m%d-%H%M)_%J.out -e /work/opa/visir-dev/operational_scripts/logs/GUTTA_n08_$(date +%Y%m%d-%H%M)_%J.err -J 'GUTTA_n08' "sh ${RUNN08_EXE} ${RUNDATE}" &)

# Notify 2 "RunN08" "Job submitted with id ${N08_JOBID}"
