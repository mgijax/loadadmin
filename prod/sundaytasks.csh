#!/bin/csh -f
#
#  sundaytasks.csh
###########################################################################
#
#  Purpose:
#
#      This script is a wrapper for the Sunday production tasks.
#
#  Usage:
#
#      sundaytasks.csh
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
#          - mgd.presunday.dump
#          - radar.presunday.dump
#          - mgd.postsunday.dump
#          - radar.postsunday.dump
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

setenv LOG ${LOGSDIR}/${SCRIPT_NAME}.log
rm -f ${LOG}
touch ${LOG}

echo "$0" >> ${LOG}
env | sort >> ${LOG}

date | tee -a ${LOG}
echo 'Reset process control flags in data loads namespace' | tee -a ${LOG}
${PROC_CTRL_CMD_PROD}/resetFlags ${NS_DATA_LOADS} ${SCRIPT_NAME}

date | tee -a ${LOG}
echo 'Create Pre-Sunday Database Backups' | tee -a ${LOG}
${PG_DBUTILS}/bin/dumpDB.csh ${PG_DBSERVER} ${PG_DBNAME} mgd ${DB_BACKUP_DIR}/mgd.presunday.dump
${PG_DBUTILS}/bin/dumpDB.csh ${PG_DBSERVER} ${PG_DBNAME} radar ${DB_BACKUP_DIR}/radar.presunday.dump

date | tee -a ${LOG}
echo 'Set process control flag: MGD PreBackup Ready' | tee -a ${LOG}
${PROC_CTRL_CMD_PROD}/setFlag ${NS_DATA_LOADS} ${FLAG_MGD_PREBACKUP} ${SCRIPT_NAME}

date | tee -a ${LOG}
echo 'Run EntrezGene Data Provider Load' | tee -a ${LOG}
${ENTREZGENELOAD}/loadFiles.csh

date | tee -a ${LOG}
echo 'Run Mouse EntrezGene Load' | tee -a ${LOG}
${EGLOAD}/bin/egload.sh

date | tee -a ${LOG}
echo 'Run UniProt Load' | tee -a ${LOG}
${UNIPROTLOAD}/bin/uniprotload.sh

date | tee -a ${LOG}
echo 'Run PIRSF Load' | tee -a ${LOG}
${PIRSFLOAD}/bin/pirsfload.sh

date | tee -a ${LOG}
echo 'Run Adult Mouse Anatomy Load' | tee -a ${LOG}
${VOCLOAD}/runOBOIncLoad.sh MA.config

date | tee -a ${LOG}
echo 'Run Cell Ontology Load' | tee -a ${LOG}
${VOCLOAD}/runOBOFullLoad.sh CL.config

date | tee -a ${LOG}
echo 'Run CCDS Load' | tee -a ${LOG}
${CCDSLOAD}/bin/ccdsload.sh

#
# OMIM vocabulary load needs to run before the Human EntrezGene load
# so that the lastest OMIM vocabulary is in MGI
#
date | tee -a ${LOG}
echo 'Run OMIM Load' | tee -a ${LOG}
${VOCLOAD}/runSimpleIncLoadNoArchive.sh OMIM.config

date | tee -a ${LOG}
echo 'Run Non-Mouse EntrezGene Load' | tee -a ${LOG}
${ENTREZGENELOAD}/loadAll.csh

date | tee -a ${LOG}
echo 'Run Mapview Load (skip marker/location cache)' | tee -a ${LOG}
${MAPVIEWLOAD}/bin/mapviewload.sh false

date | tee -a ${LOG}
echo 'Delete Dummy Sequences' | tee -a ${LOG}
${PG_DBUTILS}/bin/runDeleteObsoleteDummy.csh ${PG_DBSERVER} ${PG_DBNAME}

date | tee -a ${LOG}
echo 'Create Dummy Sequences' | tee -a ${LOG}
${SEQCACHELOAD}/seqdummy.csh

date | tee -a ${LOG}
echo 'Run Load Sequence/Marker Cache Load' | tee -a ${LOG}
${SEQCACHELOAD}/seqmarker.csh

date | tee -a ${LOG}
echo 'Run Load Sequence/Probe Cache Load' | tee -a ${LOG}
${SEQCACHELOAD}/seqprobe.csh

date | tee -a ${LOG}
echo 'Run Load Marker/Probe Cache Load' | tee -a ${LOG}
${MRKCACHELOAD}/mrkprobe.csh

date | tee -a ${LOG}
echo 'Run NextProt Load' | tee -a ${LOG}
${NEXTPROTLOAD}/bin/nextprotload.sh

date | tee -a ${LOG}
echo 'Run Homology Loads' | tee -a ${LOG}
${HOMOLOGYLOAD}/bin/homologyload.sh homologeneload.config
${HOMOLOGYLOAD}/bin/homologyload.sh hgncload.config
${HOMOLOGYLOAD}/bin/homologyload.sh hybridload.config
${HOMOLOGYLOAD}/bin/homologyload.sh zfinload.config
${HOMOLOGYLOAD}/bin/homologyload.sh geishaload.config
${HOMOLOGYLOAD}/bin/homologyload.sh xenbaseload.config

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
echo 'Run Marker/OMIM Cache Load' | tee -a ${LOG}
${MRKCACHELOAD}/mrkomim.csh

date | tee -a ${LOG}
echo 'Run GOA Load' | tee -a ${LOG}
${GOALOAD}/bin/goa.csh

date | tee -a ${LOG}
echo 'Run GO/Rat Load' | tee -a ${LOG}
${GORATLOAD}/bin/gorat.sh

date | tee -a ${LOG}
echo 'Run GO/PAINT Load' | tee -a ${LOG}
${GOREFGENLOAD}/bin/gorefgen.sh

date | tee -a ${LOG}
echo 'Run GOA/Human Load' | tee -a ${LOG}
${GOAHUMANLOAD}/bin/goahuman.sh

date | tee -a ${LOG}
echo 'Run GO/CFP Load' | tee -a ${LOG}
${GOCFPLOAD}/bin/gocfp.sh

date | tee -a ${LOG}
echo 'Generate Weekly QC Reports' | tee -a ${LOG}
${QCRPTS}/qcweekly_reports.csh

date | tee -a ${LOG}
echo 'Generate Sunday QC Reports' | tee -a ${LOG}
${QCRPTS}/qcsunday_reports.csh

date | tee -a ${LOG}
echo 'Create Post-Sunday Database Backups' | tee -a ${LOG}
${PG_DBUTILS}/bin/dumpDB.csh ${PG_DBSERVER} ${PG_DBNAME} mgd ${DB_BACKUP_DIR}/mgd.postsunday.dump
${PG_DBUTILS}/bin/dumpDB.csh ${PG_DBSERVER} ${PG_DBNAME} radar ${DB_BACKUP_DIR}/radar.postsunday.dump

echo "${SCRIPT_NAME} completed successfully" | tee -a ${LOG}
date | tee -a ${LOG}
exit 0
