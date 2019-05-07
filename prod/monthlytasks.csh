#!/bin/csh -f
#
#  monthlytasks.csh
###########################################################################
#
#  Purpose:
#
#      This script is a wrapper for the monthly production tasks.
#
#  Usage:
#
#      monthlytasks.csh
#
#  Env Vars:
#
#      - See Configuration file (loadadmin product)
#
#      - See master.config.csh (mgiconfig product)
#
#  Inputs:  None
#
#  Outputs:
#
#      - Log file for the script (${LOG})
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

date | tee -a ${LOG}
echo 'Generate Monthly QC Reports' | tee -a ${LOG}
${QCRPTS}/qcmonthly_reports.csh
set returnStatus=$status
if ( $returnStatus ) then
    echo 'QC Reports: FAILED' | tee -a ${LOG}
else
    echo 'QC Reports: SUCCESSFUL' | tee -a ${LOG}
endif

date | tee -a ${LOG}
echo 'Remove Obsolete PixelDB JPGs' | tee -a ${LOG}
${PG_DBUTILS}/bin/pixidDeleteObsolete.csh

echo "${SCRIPT_NAME} completed successfully" | tee -a ${LOG}
date | tee -a ${LOG}
exit 0
