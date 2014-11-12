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
#      - Database backup files (in /extra1/sybase)
#          - mgd.presundaybackup1, mgd.presundaybackup2
#          - mgd.postsundaybackup1, mgd.postsundaybackup2
#          - radar.presundaybackup1, radar.presundaybackup2
#          - radar.postsundaybackup1, radar.postsundaybackup2
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

setenv DOTS_NIA_DFCI_LOG ${DATALOADSOUTPUT}/mgi/mgddbutilities/logs/dots_nia_dfci.stdouterr.log

echo "$0" >> ${LOG}
env | sort >> ${LOG}

date | tee -a ${LOG}
echo 'Reset process control flags in data loads namespace' | tee -a ${LOG}
${PROC_CTRL_CMD_PROD}/resetFlags ${NS_DATA_LOADS} ${SCRIPT_NAME}

date | tee -a ${LOG}
echo 'Create Pre-Sunday Database Backup' | tee -a ${LOG}
${MGI_DBUTILS}/bin/mgi_backup_to_disk.csh ${MGD_DBSERVER} "${MGD_DBNAME} ${RADAR_DBNAME}" presunday

date | tee -a ${LOG}
echo 'Set process control flag: MGD PreBackup Ready' | tee -a ${LOG}
${PROC_CTRL_CMD_PROD}/setFlag ${NS_DATA_LOADS} ${FLAG_MGD_PREBACKUP} ${SCRIPT_NAME}

date | tee -a ${LOG}
echo 'Generate Mapping Experiment Stats' | tee -a ${LOG}
${MGD_DBUTILS}/bin/runstatistics

date | tee -a ${LOG}
echo 'EntrezGene Data Provider Load' | tee -a ${LOG}
${ENTREZGENELOAD}/loadFiles.csh

date | tee -a ${LOG}
echo 'Mouse EntrezGene Load' | tee -a ${LOG}
${EGLOAD}/bin/egload.sh

date | tee -a ${LOG}
echo 'UniGene Load' | tee -a ${LOG}
${UNIGENELOAD}/unigeneLoad.sh

date | tee -a ${LOG}
echo 'UniProt Load' | tee -a ${LOG}
${UNIPROTLOAD}/bin/uniprotload.sh

date | tee -a ${LOG}
echo 'PIRSF Load' | tee -a ${LOG}
${PIRSFLOAD}/bin/pirsfload.sh

date | tee -a ${LOG}
echo 'Adult Mouse Anatomy Load' | tee -a ${LOG}
${VOCLOAD}/runOBOIncLoad.sh MA.config

date | tee -a ${LOG}
echo 'CCDS Load' | tee -a ${LOG}
${CCDSLOAD}/bin/ccdsload.sh

#
# OMIM vocabulary load needs to run before the Human EntrezGene load
# so that the lastest OMIM vocabulary is in MGI
#
date | tee -a ${LOG}
echo 'OMIM Load' | tee -a ${LOG}
${VOCLOAD}/runSimpleIncLoadNoArchive.sh OMIM.config

date | tee -a ${LOG}
echo 'Non-Mouse EntrezGene Load' | tee -a ${LOG}
${ENTREZGENELOAD}/loadAll.csh

date | tee -a ${LOG}
echo 'Mapview Load (skip marker/location cache)' | tee -a ${LOG}
${MAPVIEWLOAD}/bin/mapviewload.sh false

date | tee -a ${LOG}
echo 'Delete Dummy Sequences' | tee -a ${LOG}
${MGI_DBUTILS}/bin/runDeleteObsoleteDummy.csh ${MGD_DBSERVER} ${MGD_DBNAME}

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
echo 'Load Sequence/Description Cache Table' | tee -a ${LOG}
${SEQCACHELOAD}/seqdescription.csh

date | tee -a ${LOG}
echo 'Load Marker/Probe Cache Table' | tee -a ${LOG}
${MRKCACHELOAD}/mrkprobe.csh

date | tee -a ${LOG}
echo 'NextProt Load' | tee -a ${LOG}
${NEXTPROTLOAD}/bin/nextprotload.sh

date | tee -a ${LOG}
echo 'Homology Load' | tee -a ${LOG}
${HOMOLOGYLOAD}/bin/homologyload.sh

# run this after orthologyload. Note mrkhomology.csh is run by orthologyload.csh
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
echo 'Load Marker/OMIM Cache Table' | tee -a ${LOG}
${MRKCACHELOAD}/mrkomim.csh

date | tee -a ${LOG}
echo 'GOA Load' | tee -a ${LOG}
${GOALOAD}/bin/goa.csh

date | tee -a ${LOG}
echo 'GO/Rat Load' | tee -a ${LOG}
${GORATLOAD}/bin/gorat.sh

date | tee -a ${LOG}
echo 'GO/RefGenome Load' | tee -a ${LOG}
${GOREFGENLOAD}/bin/gorefgen.sh

date | tee -a ${LOG}
echo 'GOA/Human Load' | tee -a ${LOG}
${GOAHUMANLOAD}/bin/goahuman.sh

date | tee -a ${LOG}
echo 'GO/CFP Load' | tee -a ${LOG}
${GOCFPLOAD}/bin/gocfp.sh

# this must run before the generateGIAAssoc.csh script
# which depends on GIA_???.py reports
date | tee -a ${LOG}
echo 'Weekly QC Reports' | tee -a ${LOG}
${QCRPTS}/qcweekly_reports.csh

date | tee -a ${LOG}
echo 'Sunday QC Reports' | tee -a ${LOG}
${QCRPTS}/qcsunday_reports.csh

# this generates the input files for the association load which runs
# Tuesday AM (mondaytasks.csh). It takes about 4 hours, so run in background
# Must run Mouse EntrezGene Load, SwissProt Load and wkly qc reports first
# the association loads runs Monday night via mondaytasks.csh
date | tee -a ${LOG}
echo 'Generate DoTS/NIA/DFCI Association Files' | tee -a ${LOG}
${MGD_DBUTILS}/bin/generateGIAssoc.csh >& ${DOTS_NIA_DFCI_LOG} &

#
# run after data loads (which create new accids) and before 
# the database backup 
#
date | tee -a ${LOG}
echo 'Update statistics on ACC_Accession' | tee -a ${LOG}
${MGI_DBUTILS}/bin/updateStatistics.csh ${MGD_DBSERVER} ${MGD_DBNAME} ACC_Accession


date | tee -a ${LOG}
echo 'Create Post-Sunday Database Backup' | tee -a ${LOG}
${MGI_DBUTILS}/bin/mgi_backup_to_disk.csh ${MGD_DBSERVER} "${MGD_DBNAME} ${RADAR_DBNAME}" postsunday

date | tee -a ${LOG}
echo 'Generate Frontend Info' | tee -a ${LOG}
${LOADADMIN}/prod/genFrontend.csh

echo "${SCRIPT_NAME} completed successfully" | tee -a ${LOG}
date | tee -a ${LOG}
exit 0
