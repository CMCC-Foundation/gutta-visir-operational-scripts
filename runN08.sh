#!/bin/bash

##########################################
#
# Paths and routes
#
########################################## 

# paths
OP_PATH=/work/opa/visir-dev/operational_scripts/

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

# Notify 2 "RunN08" "Job starting"

ssh dss@192.168.118.150 "php -d memory_limit=1024M /var/www/html/cache/_VISIR-GUTTA/GetCapabilities/createmaps.php $1"

# Notify 1 "RunN08" "Job completed"
