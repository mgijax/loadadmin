#!/bin/csh -f
#
#  dailytasks.csh
###########################################################################
#
#  Purpose:
#
#      This script is a wrapper for the daily production tasks.
#
#  Usage:
#
#      dailytasks.csh
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
#      - Database backups
#          - mgd.predaily.dump
#          - radar.predaily.dump
#          - mgd.postdaily.dump
#          - radar.postdaily.dump
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

set weekday=`date '+%u'`
set tomorrow=`date -d tomorrow +%m/%d/%Y`

date | tee -a ${LOG}
echo 'Make sure the database is available before starting' | tee -a ${LOG}
${PG_DBUTILS}/bin/testConnection.csh ${PG_DBSERVER} ${PG_DBNAME}
if ( $status != 0 ) then
    echo "Cannot connect to database ${PG_DBSERVER}.${PG_DBNAME}. Abort load schedule." | tee -a ${LOG}
    exit 1
endif

date | tee -a ${LOG}
echo 'Run MCV Vocabulary Load' | tee -a ${LOG}
${MCVLOAD}/bin/run_mcv_vocload.sh

date | tee -a ${LOG}
echo 'Run MCV Annotation Load' | tee -a ${LOG}
${MCVLOAD}/bin/mcvload.sh

date | tee -a ${LOG}
echo 'Run Marker/Coordinate Load' | tee -a ${LOG}
${MRKCOORDLOAD}/bin/mrkcoordload.sh
${MRKCOORDLOAD}/bin/mrkcoordDelete.sh

date | tee -a ${LOG}
echo 'Run Rollup Load' | tee -a ${LOG}
${ROLLUPLOAD}/bin/rollupload.sh

date | tee -a ${LOG}
echo 'Create Dummy Sequences' | tee -a ${LOG}
${SEQCACHELOAD}/seqdummy.csh

date | tee -a ${LOG}
echo 'Run Sequence/Marker Cache Load' | tee -a ${LOG}
${SEQCACHELOAD}/seqmarker.csh

date | tee -a ${LOG}
echo 'Run Sequence/Probe Cache Load' | tee -a ${LOG}
${SEQCACHELOAD}/seqprobe.csh

date | tee -a ${LOG}
echo 'Run Marker/Label Cache Load' | tee -a ${LOG}
${MRKCACHELOAD}/mrklabel.csh

date | tee -a ${LOG}
echo 'Run Marker/Reference Cache Load' | tee -a ${LOG}
${MRKCACHELOAD}/mrkref.csh

date | tee -a ${LOG}
echo 'Run Marker/Location Cache Load' | tee -a ${LOG}
${MRKCACHELOAD}/mrklocation.csh

date | tee -a ${LOG}
echo 'Run Marker/Probe Cache Load' | tee -a ${LOG}
${MRKCACHELOAD}/mrkprobe.csh

date | tee -a ${LOG}
echo 'Run Marker/MCV Cache Load' | tee -a ${LOG}
${MRKCACHELOAD}/mrkmcv.csh

date | tee -a ${LOG}
echo 'Run Allele/Label Cache Load' | tee -a ${LOG}
${ALLCACHELOAD}/alllabel.csh

date | tee -a ${LOG}
echo 'Run Allele/Combination Cache Load' | tee -a ${LOG}
${ALLCACHELOAD}/allelecombination.csh

date | tee -a ${LOG}
echo 'Run Marker/DO Cache Load' | tee -a ${LOG}
${MRKCACHELOAD}/mrkdo.csh

date | tee -a ${LOG}
echo 'Run Allele/Strain Cache Load' | tee -a ${LOG}
${ALLCACHELOAD}/allstrain.csh

date | tee -a ${LOG}
echo 'Run Allele/CRE Cache Load' | tee -a ${LOG}
${ALLCACHELOAD}/allelecrecache.csh

date | tee -a ${LOG}
echo 'Run Mammalian Phenotype Load' | tee -a ${LOG}
${VOCLOAD}/runOBOIncLoad.sh MP.config

date | tee -a ${LOG}
echo 'Run EMAP Load' | tee -a ${LOG}
${VOCLOAD}/emap/emapload.sh

date | tee -a ${LOG}
echo 'Run RV Load' | tee -a ${LOG}
${RVLOAD}/bin/rvload.sh

#date | tee -a ${LOG}
#echo 'Run Curator Allele Load' | tee -a ${LOG}
#${CURATORALLELELOAD}/bin/curatoralleleload.sh

#date | tee -a ${LOG}
#echo 'Run Curator Bulk Index Load' | tee -a ${LOG}
#${CURATORBULKINDEXLOAD}/bin/curatorbulkindexload.sh

#date | tee -a ${LOG}
#echo 'Run Curator Strain Load' | tee -a ${LOG}
#${CURATORSTRAINLOAD}/bin/curatorstrainload.sh

date | tee -a ${LOG}
echo 'Run GXD Expression Cache Load' | tee -a ${LOG}
${MGICACHELOAD}/gxdexpression.csh

date | tee -a ${LOG}
echo 'Update Reference Workflow Status' | tee -a ${LOG}
${PG_DBUTILS}/sp/run_BIB_updateWFStatus.csh

date | tee -a ${LOG}
echo 'Delete Duplicate Notes' | tee -a ${LOG}
${PG_DBUTILS}/bin/deleteDuplicateNotes.csh

date | tee -a ${LOG}
echo 'Generate Nightly QC Reports' | tee -a ${LOG}
${QCRPTS}/qcnightly_reports.csh

date | tee -a ${LOG}
echo 'Generate Daily Public Reports' | tee -a ${LOG}
${PUBRPTS}/run_daily.csh

date | tee -a ${LOG}
echo 'Update Last Dump Date' | tee -a ${LOG}
${PG_DBUTILS}/bin/updateLastDumpDate.csh ${PG_DBSERVER} ${PG_DBNAME} ${tomorrow}

if ( "`uname -n | cut -d'.' -f1`" == "bhmgiapp01" ) then
    date | tee -a ${LOG}
    echo 'Create Post-Daily Database Backups' | tee -a ${LOG}
    ${PG_DBUTILS}/bin/dumpDB.csh ${PG_DBSERVER} ${PG_DBNAME} mgd ${DB_BACKUP_DIR}/mgd.postdaily.dump
    ${PG_DBUTILS}/bin/dumpDB.csh ${PG_DBSERVER} ${PG_DBNAME} radar ${DB_BACKUP_DIR}/radar.postdaily.dump
endif

echo "${SCRIPT_NAME} completed successfully" | tee -a ${LOG}
date | tee -a ${LOG}
exit 0
