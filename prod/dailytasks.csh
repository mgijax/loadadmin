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

#
# Generate the MGI marker feed as early as possible for JAX folks.
#
date | tee -a ${LOG}
echo 'Generate MGI Marker Feed Reports' | tee -a ${LOG}
${PUBRPTS}/mgimarkerfeed/mgimarkerfeed_reports.csh

if ( "`uname -n | cut -d'.' -f1`" == "bhmgiapp01" ) then
    date | tee -a ${LOG}
    echo 'Save a copy of the prior database backups' | tee -a ${LOG}
    if ( -f ${DB_BACKUP_DIR}/mgd.predaily.dump ) then
        cp -p ${DB_BACKUP_DIR}/mgd.predaily.dump ${DB_BACKUP_DIR}/mgd.predaily.dump.save
    endif
    if ( -f ${DB_BACKUP_DIR}/radar.predaily.dump ) then
        cp -p ${DB_BACKUP_DIR}/radar.predaily.dump ${DB_BACKUP_DIR}/radar.predaily.dump.save
    endif

    date | tee -a ${LOG}
    echo 'Create Pre-Daily Database Backups' | tee -a ${LOG}
    ${PG_DBUTILS}/bin/dumpDB.csh ${PG_DBSERVER} ${PG_DBNAME} mgd ${DB_BACKUP_DIR}/mgd.predaily.dump
    ${PG_DBUTILS}/bin/dumpDB.csh ${PG_DBSERVER} ${PG_DBNAME} radar ${DB_BACKUP_DIR}/radar.predaily.dump
endif

#
# Run prior to cache loads because deleted sequences aren't selected as
# representative for markers. Only runs on Wednesday night.
#
if ( $weekday == 3 ) then
    date | tee -a ${LOG}
    echo 'Run RefSeq Sequence Deleter' | tee -a ${LOG}
    ${SEQDELETER}/bin/seqdeleter.sh refseqdeleter.config

    date | tee -a ${LOG}
    echo 'Run GenBank Sequence Deleter' | tee -a ${LOG}
    ${SEQDELETER}/bin/seqdeleter.sh gbseqdeleter.config
endif

# 
# Do not run on Monday
# nomenclature loads require additional MCV associations 
# and that will not happen until the next day
#
if ( $weekday != 1 ) then
    date | tee -a ${LOG}
    echo 'Run Nomen/Mapping load' | tee -a ${LOG}
    ${NOMENLOAD}/bin/nomenload.sh ${NOMENLOAD}/nomenload.config

    date | tee -a ${LOG}
    echo 'Run Nomen/Batch Rename load' | tee -a ${LOG}
    ${NOMENLOAD}/bin/batchrename.sh ${NOMENLOAD}/nomenload.config

    date | tee -a ${LOG}
    echo 'Run Nomen/Batch Delete load' | tee -a ${LOG}
    ${NOMENLOAD}/bin/batchdelete.sh ${NOMENLOAD}/nomenload.config
endif

date | tee -a ${LOG}
echo 'Run Lit Triage Load' | tee -a ${LOG}
${LITTRIAGELOAD}/bin/littriageload.sh

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

#
# only run on Monday
#
if ( $weekday == 1 ) then
	date | tee -a ${LOG}
	echo 'Run Rollup Load' | tee -a ${LOG}
	${ROLLUPLOAD}/bin/rollupload.sh
endif

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
echo 'Update Last Dump Date' | tee -a ${LOG}
${PG_DBUTILS}/bin/updateLastDumpDate.csh ${PG_DBSERVER} ${PG_DBNAME} ${tomorrow}

date | tee -a ${LOG}
echo 'Run Mammalian Phenotype Load' | tee -a ${LOG}
${VOCLOAD}/runOBOIncLoad.sh MP.config

date | tee -a ${LOG}
echo 'Run EMAP Load' | tee -a ${LOG}
${VOCLOAD}/emap/emapload.sh

date | tee -a ${LOG}
echo 'Run RV Load' | tee -a ${LOG}
${RVLOAD}/bin/rvload.sh

date | tee -a ${LOG}
echo 'Run Curator Allele Load' | tee -a ${LOG}
${CURATORALLELELOAD}/bin/curatoralleleload.sh

date | tee -a ${LOG}
echo 'Run Curator Bulk Index Load' | tee -a ${LOG}
${CURATORBULKINDEXLOAD}/bin/curatorbulkindexload.sh

date | tee -a ${LOG}
echo 'Run Curator Strain Load' | tee -a ${LOG}
${CURATORSTRAINLOAD}/bin/curatorstrainload.sh

date | tee -a ${LOG}
echo 'Run GXD Expression Cache Load' | tee -a ${LOG}
${MGICACHELOAD}/gxdexpression.csh

date | tee -a ${LOG}
echo 'Update Reference Workflow Status' | tee -a ${LOG}
${PG_DBUTILS}/sp/run_BIB_updateWFStatus.csh

date | tee -a ${LOG}
echo 'Generate Nightly QC Reports' | tee -a ${LOG}
${QCRPTS}/qcnightly_reports.csh

date | tee -a ${LOG}
echo 'Generate Daily Public Reports' | tee -a ${LOG}
${PUBRPTS}/run_daily.csh

if ( "`uname -n | cut -d'.' -f1`" == "bhmgiapp01" ) then
    date | tee -a ${LOG}
    echo 'Create Post-Daily Database Backups' | tee -a ${LOG}
    ${PG_DBUTILS}/bin/dumpDB.csh ${PG_DBSERVER} ${PG_DBNAME} mgd ${DB_BACKUP_DIR}/mgd.postdaily.dump
    ${PG_DBUTILS}/bin/dumpDB.csh ${PG_DBSERVER} ${PG_DBNAME} radar ${DB_BACKUP_DIR}/radar.postdaily.dump
endif

echo "${SCRIPT_NAME} completed successfully" | tee -a ${LOG}
date | tee -a ${LOG}
exit 0
