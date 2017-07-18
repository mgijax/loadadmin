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
echo 'Create Pre-Sunday Database Backups' | tee -a ${LOG}
${PG_DBUTILS}/bin/dumpDB.csh ${PG_DBSERVER} ${PG_DBNAME} mgd ${DB_BACKUP_DIR}/mgd.presunday.dump
${PG_DBUTILS}/bin/dumpDB.csh ${PG_DBSERVER} ${PG_DBNAME} radar ${DB_BACKUP_DIR}/radar.presunday.dump

date | tee -a ${LOG}
echo 'Perform special character cleanup' | tee -a ${LOG}
${PG_DBUTILS}/bin/cleanSpecChar.csh

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

date | tee -a ${LOG}
echo 'Run OMIM Load' | tee -a ${LOG}
${VOCLOAD}/runSimpleIncLoadNoArchive.sh OMIM.config

date | tee -a ${LOG}
echo 'Run Disease Ontology Load' | tee -a ${LOG}
${VOCLOAD}/runOBOIncLoadNoArchive.sh DO.config

date | tee -a ${LOG}
echo 'Run HPO Vocab Load' | tee -a ${LOG}
${VOCLOAD}/runOBOIncLoad.sh HPO.config

date | tee -a ${LOG}
echo 'Run OMIM/HPO Annotation Load' | tee -a ${LOG}
${OMIMHPOLOAD}/bin/omim_hpoload.sh

date | tee -a ${LOG}
echo 'Run MP/HPO Relationship Load' | tee -a ${LOG}
${MPHPOLOAD}/bin/mp_hpoload.sh

date | tee -a ${LOG}
echo 'Run Non-Mouse EntrezGene Load' | tee -a ${LOG}
${ENTREZGENELOAD}/loadAll.csh

date | tee -a ${LOG}
echo 'Run Gene Summary Load' | tee -a ${LOG}
${GENESUMMARYLOAD}/bin/genesummaryload.sh

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
echo 'Run Marker/DO Cache Load' | tee -a ${LOG}
${MRKCACHELOAD}/mrkdo.csh

date | tee -a ${LOG}
echo 'Run GO Loads' | tee -a ${LOG}
${GOLOAD}/go.sh

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
