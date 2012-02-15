#!/bin/csh -f
#
#  mondaytasks.csh
###########################################################################
#
#  Purpose:
#
#      This script is a wrapper for the Monday production tasks.
#
#  Usage:
#
#      mondaytasks.csh
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
echo 'Load GO Text' | tee -a ${LOG}
${NOTELOAD}/mginoteload.csh ${NOTELOAD}/gotext.config >>& ${LOG}
set returnStatus=$status
if ( $returnStatus ) then
    echo 'Load GO Text: FAILED' | tee -a ${LOG}
else
    echo 'Load GO Text: SUCCESSFUL' | tee -a ${LOG}
endif

date | tee -a ${LOG}
echo 'DoTS Association Load' | tee -a ${LOG}
${ASSOCLOAD}/bin/AssocLoadDP.sh ${ASSOCLOAD}/DP.config.dots >>& ${LOG}
set returnStatus=$status
if ( $returnStatus ) then
    echo 'DoTS Association Load: FAILED' | tee -a ${LOG}
else
    echo 'DoTS Association Load: SUCCESSFUL' | tee -a ${LOG}
endif

date | tee -a ${LOG}
echo 'NIA Association Load' | tee -a ${LOG}
${ASSOCLOAD}/bin/AssocLoadDP.sh ${ASSOCLOAD}/DP.config.nia >>& ${LOG}
set returnStatus=$status
if ( $returnStatus ) then
    echo 'NIA Association Load: FAILED' | tee -a ${LOG}
else
    echo 'NIA Association Load: SUCCESSFUL' | tee -a ${LOG}
endif

date | tee -a ${LOG}
echo 'DFCI Association Load' | tee -a ${LOG}
${ASSOCLOAD}/bin/AssocLoadDP.sh ${ASSOCLOAD}/DP.config.dfci >>& ${LOG}
set returnStatus=$status
if ( $returnStatus ) then
    echo 'DFCI Association Load FAILED' | tee -a ${LOG}
else
    echo 'DFCI Association Load SUCCESSFUL' | tee -a ${LOG}
endif

date | tee -a ${LOG}
echo 'Load Sequence/Marker Cache Table' | tee -a ${LOG}
${SEQCACHELOAD}/seqmarker.csh >>& ${LOG}
set returnStatus=$status
if ( $returnStatus ) then
    echo 'Load Sequence/Marker Cache Table: FAILED' | tee -a ${LOG}
else
    echo 'Load Sequence/Marker Cache Table: SUCCESSFUL' | tee -a ${LOG}
endif

date | tee -a ${LOG}
echo 'Load Sequence/Probe Cache Table' | tee -a ${LOG}
${SEQCACHELOAD}/seqprobe.csh >>& ${LOG}
set returnStatus=$status
if ( $returnStatus ) then
    echo 'Load Sequence/Probe Cache Table: FAILED' | tee -a ${LOG}
else
    echo 'Load Sequence/Probe Cache Table: SUCCESSFUL' | tee -a ${LOG}
endif

date | tee -a ${LOG}
echo 'Load Sequence/Description Cache Table' | tee -a ${LOG}
${SEQCACHELOAD}/seqdescription.csh >>& ${LOG}
set returnStatus=$status
if ( $returnStatus ) then
    echo 'Load Sequence/Description Cache Table: FAILED' | tee -a ${LOG}
else
    echo 'Load Sequence/Description Cache Table: SUCCESSFUL' | tee -a ${LOG}
endif

echo "${SCRIPT_NAME} completed successfully" | tee -a ${LOG}
date | tee -a ${LOG}
exit 0
