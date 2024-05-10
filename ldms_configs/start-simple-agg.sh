#!/bin/bash

SCRIPT_PATH=/ldms_configs

source ${SCRIPT_PATH}/ldmsd-paths.sh
ldmsd -x sock:10002 -l ${LOG_PATH}/agg.log -v DEBUG -r $PID_PATH/simple_agg.pid -c ${CONF_PATH}/simple_agg.conf
