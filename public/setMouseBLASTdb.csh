#!/bin/csh -f
#
#  setMouseBLASTdb.csh
###########################################################################
#
#  Purpose:
#
#      This script is a wrapper for swapping the public MouseBLAST.
#
#  Usage:
#
#      setMouseBLASTdb.csh
#
#  Env Vars:
#
#      - See Configuration file (loadadmin product)
#
#      - See master.config.csh (mgiconfig product)
#
#  Inputs:
#
#      - Process control flags
#
#  Outputs:
#
#      - Log file for the script (${LOG})
#
#      - Process control flags
#
#  Exit Codes:
#
#      0:  Successful completion
#      1:  Fatal error occurred
#
#  Assumes:  Nothing
#
#  Implementation:
#
#      This script will perform following steps:
#
#      1) Source the configuration file to establish the environment.
#      2) Wait for the flag to signal that the public WIs have been swapped.
#      3) Swap MouseBLAST WI configuration file links.
#      4) Update include files for MouseBLAST WI.
#      5) Regenerate templates and GlobalConfig from webshare.
#
#  Notes:  None
#
###########################################################################

cd `dirname $0` && source ./Configuration

setenv SCRIPT_NAME `basename $0`

setenv LOG ${LOGSDIR}/${SCRIPT_NAME}.log
rm -f ${LOG}
touch ${LOG}

echo "$0" | tee -a ${LOG}
env | sort | tee -a ${LOG}

#
# Wait for the "WI Swapped" flag to be set. Stop waiting if the number
# of retries expires or the abort flag is found.
#
date | tee -a ${LOG}
echo 'Wait for the "WI Swapped" flag to be set' | tee -a ${LOG}

setenv RETRY ${PROC_CTRL_RETRIES}
while (${RETRY} > 0)
    setenv READY `${PROC_CTRL_CMD_PUB}/getFlag ${NS_PUB_LOAD} ${FLAG_WI_SWAPPED}`
    setenv ABORT `${PROC_CTRL_CMD_PUB}/getFlag ${NS_PUB_LOAD} ${FLAG_ABORT}`

    if (${READY} == 1 || ${ABORT} == 1) then
        break
    else
        sleep ${PROC_CTRL_WAIT_TIME}
    endif

    setenv RETRY `expr ${RETRY} - 1`
end

#
# Terminate the script if the number of retries expired or the abort flag
# was found.
#
if (${RETRY} == 0) then
   echo "${SCRIPT_NAME} timed out" | tee -a ${LOG}
   date | tee -a ${LOG}
   exit 1
else if (${ABORT} == 1) then
   echo "${SCRIPT_NAME} aborted by process controller" | tee -a ${LOG}
   date | tee -a ${LOG}
   exit 1
endif

#
# Clear the "WI Swapped" flag.
#
date | tee -a ${LOG}
echo 'Clear process control flag: WI Swapped' | tee -a ${LOG}
${PROC_CTRL_CMD_PUB}/clearFlag ${NS_PUB_LOAD} ${FLAG_WI_SWAPPED} ${SCRIPT_NAME}

#
# Swap MouseBLAST WI configuration file links.
#
date | tee -a ${LOG}
echo 'Swap MouseBLAST WI configuration file links' | tee -a ${LOG}
cd ${MGI_LIVE}/mblast_wi
mv Configuration.old saveold
mv Configuration Configuration.old
mv saveold Configuration

#
# Update include files for MouseBLAST WI.
#
date | tee -a ${LOG}
echo 'Update include files for MouseBLAST WI' | tee -a ${LOG}
cd ${MGI_LIVE}/mblast_wi/admin
gen_includes

#
# Regenerate templates and GlobalConfig from webshare.
#
date | tee -a ${LOG}
echo 'Regenerate templates and GlobalConfig from webshare' | tee -a ${LOG}
cd ${MGI_LIVE}/mgiconfig/bin
gen_webshare

#
# Set the "MouseBLAST Swapped" flag.
#
date | tee -a ${LOG}
echo 'Set process control flag: MouseBLAST Swapped' | tee -a ${LOG}
${PROC_CTRL_CMD_PUB}/setFlag ${NS_PUB_LOAD} ${FLAG_MBLAST_SWAPPED} ${SCRIPT_NAME}

echo "${SCRIPT_NAME} completed successfully" | tee -a ${LOG}
date | tee -a ${LOG}
exit 0
