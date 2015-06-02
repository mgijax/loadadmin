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
#  Inputs:
#
#      - Process control flags
#
#  Outputs:
#
#      - Database backup files (in /extra1/sybase)
#          - mgd.predailybackup1, mgd.predailybackup2
#          - mgd.backup1, mgd.backup2
#          - radar.backup1 radar.backup2
#          - master.backup1, master.backup2
#          - wts.backup1, wts.backup2
#          - sybsystemprocs.backup1, sybsystemprocs.backup2
#          - mgd.postdailybackup1, mgd.postdailybackup2
#
#      - Pixel DB archive file (/extra1/sybase/pixelDBupdate.cpio)
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
#  Notes:  None
#
###########################################################################

cd `dirname $0` && source ./Configuration

setenv SCRIPT_NAME `basename $0`

setenv DATABASES "master sybsystemprocs ${MGD_DBNAME} ${WTS_DBNAME} ${RADAR_DBNAME}"

setenv LOG ${LOGSDIR}/${SCRIPT_NAME}.log
rm -f ${LOG}
touch ${LOG}

echo "$0" >> ${LOG}
env | sort >> ${LOG}

set weekday=`date '+%u'`
set tomorrow=`date -d tomorrow +%m/%d/%Y`

date | tee -a ${LOG}
echo 'Reset process control flags in dev load namespace' | tee -a ${LOG}
${PROC_CTRL_CMD_DEV}/resetFlags ${NS_DEV_LOAD} ${SCRIPT_NAME}
echo 'Reset process control flags in data loads namespace' | tee -a ${LOG}
${PROC_CTRL_CMD_PROD}/resetFlags ${NS_DATA_LOADS} ${SCRIPT_NAME}

#
# Generate the MGI marker feed as early as possible for JAX folks.
#
date | tee -a ${LOG}
echo 'MGI Marker Feed' | tee -a ${LOG}
${PUBRPTS}/mgimarkerfeed/mgimarkerfeed_reports.csh

date | tee -a ${LOG}
echo 'Create Pre-Daily Database Backup' | tee -a ${LOG}
${MGI_DBUTILS}/bin/mgi_backup_to_disk.csh ${MGD_DBSERVER} "${MGD_DBNAME}" predaily

date | tee -a ${LOG}
echo 'Set process control flag: MGD PreBackup Ready' | tee -a ${LOG}
${PROC_CTRL_CMD_PROD}/setFlag ${NS_DATA_LOADS} ${FLAG_MGD_PREBACKUP} ${SCRIPT_NAME}

#date | tee -a ${LOG}
#echo 'Process GenBank Deletes' | tee -a ${LOG}
#${SEQDELETER}/bin/seqdeleter.sh gbseqdeleter.config

#
# Run prior to cacheloads because deleted sequences aren't selected as
# representative for markers. Only runs on Wednesday night.
#
if ( $weekday == 3 ) then
    date | tee -a ${LOG}
    echo 'Process RefSeq Deletes' | tee -a ${LOG}
    ${SEQDELETER}/bin/seqdeleter.sh refseqdeleter.config
    date | tee -a ${LOG}
    echo 'Process GenBank Deletes' | tee -a ${LOG}
    ${SEQDELETER}/bin/seqdeleter.sh gbseqdeleter.config
endif

#
# run after data loads (which create new accids) and before cache loads
# (which do NOT create accids, but query the accession table) and before
# the database backup used to load other databases
date | tee -a ${LOG}
echo 'Update statistics on ACC_Accession' | tee -a ${LOG}
${MGI_DBUTILS}/bin/updateStatistics.csh ${MGD_DBSERVER} ${MGD_DBNAME} ACC_Accession

date | tee -a ${LOG}
echo 'Create Dummy Sequences' | tee -a ${LOG}
${SEQCACHELOAD}/seqdummy.csh

date | tee -a ${LOG}
echo 'Load Sequence/Marker Cache Table' | tee -a ${LOG}
${SEQCACHELOAD}/seqmarker.csh
date | tee -a ${LOG}
echo 'Load Sequence/Probe Cache Table' | tee -a ${LOG}
${SEQCACHELOAD}/seqprobe.csh

date | tee -a ${LOG}
echo 'Load Marker/Label Cache Table' | tee -a ${LOG}
${MRKCACHELOAD}/mrklabel.csh
date | tee -a ${LOG}
echo 'Load Marker/Reference Cache Table' | tee -a ${LOG}
${MRKCACHELOAD}/mrkref.csh
date | tee -a ${LOG}
echo 'Load Marker/Location Cache Table' | tee -a ${LOG}
${MRKCACHELOAD}/mrklocation.csh
date | tee -a ${LOG}
echo 'Load Marker/Probe Cache Table' | tee -a ${LOG}
${MRKCACHELOAD}/mrkprobe.csh
date | tee -a ${LOG}
echo 'Load Marker/MCV Cache Table' | tee -a ${LOG}
${MRKCACHELOAD}/mrkmcv.csh

date | tee -a ${LOG}
echo 'Load Allele/Label Cache Table' | tee -a ${LOG}
${ALLCACHELOAD}/alllabel.csh
date | tee -a ${LOG}
echo 'Load Allele/Combination Cache Table' | tee -a ${LOG}
${ALLCACHELOAD}/allelecombination.csh
date | tee -a ${LOG}
echo 'Load Marker/OMIM Cache Table' | tee -a ${LOG}
# the OMIM cache depends on the allele combination note 3
${MRKCACHELOAD}/mrkomim.csh
date | tee -a ${LOG}
echo 'Load Allele/Strain Cache Table' | tee -a ${LOG}
${ALLCACHELOAD}/allstrain.csh
date | tee -a ${LOG}
echo 'Load Allele/CRE Cache Table' | tee -a ${LOG}
${ALLCACHELOAD}/allelecrecache.csh

date | tee -a ${LOG}
echo 'Re-set AD Topological Sort' | tee -a ${LOG}
${TOPOSORTLOAD}/toposort.csh

date | tee -a ${LOG}
echo 'Update Last Dump Date' | tee -a ${LOG}
${MGI_DBUTILS}/bin/updateLastDumpDate.csh ${MGD_DBSERVER} ${MGD_DBNAME} ${tomorrow}

date | tee -a ${LOG}
echo 'Add New Measurements' | tee -a ${LOG}
${MGI_DBUTILS}/bin/addMeasurements.csh

date | tee -a ${LOG}
echo 'Create Database Backup' | tee -a ${LOG}
${MGI_DBUTILS}/bin/mgi_backup_to_disk.csh ${MGD_DBSERVER} "${DATABASES}"

date | tee -a ${LOG}
echo 'Set process control flag: MGD Backup Ready' | tee -a ${LOG}
${PROC_CTRL_CMD_PROD}/setFlag ${NS_DATA_LOADS} ${FLAG_MGD_BACKUP} ${SCRIPT_NAME}

#date | tee -a ${LOG}
#echo 'Process GenBank Deletes' | tee -a ${LOG}
#${SEQDELETER}/bin/seqdeleter.sh gbseqdeleter.config

date | tee -a ${LOG}
echo 'Mammalian Phenotype Load' | tee -a ${LOG}
${VOCLOAD}/runOBOIncLoad.sh MP.config

date | tee -a ${LOG}
echo 'MCV Vocabulary Load' | tee -a ${LOG}
${MCVLOAD}/bin/run_mcv_vocload.sh

date | tee -a ${LOG}
echo 'Run EMAP Load' | tee -a ${LOG}
${EMAPLOAD}/bin/emapload.sh

date | tee -a ${LOG}
echo 'RV Load' | tee -a ${LOG}
${RVLOAD}/bin/rvload.sh

date | tee -a ${LOG}
echo 'GO Load' | tee -a ${LOG}
${VOCLOAD}/runOBOIncLoad.sh GO.config

date | tee -a ${LOG}
echo 'Nightly QC Reports' | tee -a ${LOG}
${QCRPTS}/qcnightly_reports.csh

date | tee -a ${LOG}
echo 'Daily Public Reports' | tee -a ${LOG}
${PUBRPTS}/run_daily.csh

date | tee -a ${LOG}
echo 'Move JFiles' | tee -a ${LOG}
${JFILESCANNER}/moveJfiles.sh

#
# Only load the GO Text on Monday.
#
if ( $weekday == 1 ) then
    date | tee -a ${LOG}
    echo 'Load GO Text' | tee -a ${LOG}
    ${NOTELOAD}/mginoteload.csh ${NOTELOAD}/gotext.config
endif

date | tee -a ${LOG}
echo 'Create Post-Daily Database Backup' | tee -a ${LOG}
${MGI_DBUTILS}/bin/mgi_backup_to_disk.csh ${MGD_DBSERVER} "${MGD_DBNAME}" postdaily

date | tee -a ${LOG}
echo 'Set process control flag: MGD PostBackup Ready' | tee -a ${LOG}
${PROC_CTRL_CMD_DEV}/setFlag ${NS_DEV_LOAD} ${FLAG_MGD_POSTBACKUP} ${SCRIPT_NAME}
${PROC_CTRL_CMD_PROD}/setFlag ${NS_DATA_LOADS} ${FLAG_MGD_POSTBACKUP} ${SCRIPT_NAME}

#
# We want this report on Tuesday and Friday morning, so it is scheduled
# to run Monday and Thursday night.
#
if ( $weekday == 1 || $weekday == 4 ) then
    date | tee -a ${LOG}
    echo 'Run Load Queue Report' | tee -a ${LOG}
    ${DLA_UTILS}/loadQueueReport.sh
endif

echo "${SCRIPT_NAME} completed successfully" | tee -a ${LOG}
date | tee -a ${LOG}
exit 0
