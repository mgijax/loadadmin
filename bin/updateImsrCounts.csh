#!/bin/csh -f
#
#  updateImsrCounts.csh
###########################################################################
#
#  Purpose:
#
#      This script is a wrapper for updating the IMSR counts in a front-end
#      database.
#
#  Usage:
#
#      updateImsrCounts.csh
#
#  Env Vars:
#
#      - See Configuration file (loadadmin product)
#
#      - See master.config.csh (mgiconfig product)
#
#  Inputs:
#
#      - Reads from IMSR via HTTP
#      - Reads from front-end database
#
#  Outputs:
#
#      - Log file for the script (${LOG})
#      - Updates allele_imsr_counts table in the database
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
#      This script will perform the following steps:
#
#      1) Source the configuration file to establish the environment
#      2) Read current IMSR counts from the front-end database
#      3) Read new IMSR counts from the IMSR web site
#      4) Compute a diff between current and new counts
#      5) Apply the diff to bring the database up to the new counts
#
#  Notes:  None
#
###########################################################################

cd `dirname $0` && source ./Configuration

setenv SCRIPT_NAME `basename $0`

setenv LOG ${LOGSDIR}/${SCRIPT_NAME}.log
rm -f ${LOG}
touch ${LOG}

echo "$0" >> ${LOG}
env | sort >> ${LOG}

#
# Update include files for MouseBLAST WI.
#
date | tee -a ${LOG}
echo 'Update IMSR counts in front-end database' | tee -a ${LOG}
${MGI_LIVE}/loadadmin/bin/updateImsrCounts.py

if ($status != 0) then
	echo "${SCRIPT_NAME} failed" | tee -a ${LOG}
	date | tee -a ${LOG}
	exit 0
endif

echo "${SCRIPT_NAME} completed successfully" | tee -a ${LOG}
date | tee -a ${LOG}
exit 0
