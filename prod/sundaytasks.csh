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

setenv SNPCACHELOAD_LOG ${DATALOADSOUTPUT}/mgi/snpcacheload/logs/snpmarker_weekly.stdouterr.log
setenv DOTS_NIA_DFCI_LOG ${DATALOADSOUTPUT}/mgi/mgddbutilities/logs/dots_nia_dfci.stdouterr.log

echo "$0" | tee -a ${LOG}
env | sort | tee -a ${LOG}

date | tee -a ${LOG}
echo 'Reset process control flags in production load namespace' | tee -a ${LOG}
${PROC_CTRL_CMD_PROD}/resetFlags ${NS_PROD_LOAD} ${SCRIPT_NAME}

date | tee -a ${LOG}
echo 'Create Pre-Sunday Database Backup' | tee -a ${LOG}
${MGI_DBUTILS}/bin/mgi_backup_to_disk.csh ${MGD_DBSERVER} "${MGD_DBNAME} ${RADAR_DBNAME}" presunday

date | tee -a ${LOG}
echo 'Set process control flag: MGD PreBackup Ready' | tee -a ${LOG}
${PROC_CTRL_CMD_PROD}/setFlag ${NS_PROD_LOAD} ${FLAG_MGD_PREBACKUP} ${SCRIPT_NAME}

date | tee -a ${LOG}
echo 'Generate Mapping Experiment Stats' | tee -a ${LOG}
${MGD_DBUTILS}/bin/runstatistics

date | tee -a ${LOG}
echo 'EntrezGene Data Provider Load' | tee -a ${LOG}
${ENTREZGENELOAD}/loadFiles.csh

date | tee -a ${LOG}
echo 'Mouse EntrezGene Load' | tee -a ${LOG}
${EGLOAD}/bin/egload.sh

#
# Weekly SNP marker cacheload needs to run after the mouse EntrezGene
# load to pick up reload marker/egid associations
# run in background
#
date | tee -a ${LOG}
echo 'Run Weekly SNP Marker Load In The Background' | tee -a ${LOG}
${SNPCACHELOAD}/snpmarker_weekly.sh >& ${SNPCACHELOAD_LOG} &

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
echo 'RPCI Load' | tee -a ${LOG}
${RPCILOAD}/bin/RPCILoad.sh

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
echo 'Human, Rat, etc., EntrezGene Load' | tee -a ${LOG}
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
echo 'Generate Orthologyload Files (Human, Rat, Cattle, Chimp, Dog)' | tee -a ${LOG}
${ORTHOLOGYLOAD}/bin/genInputFiles.csh human.config rat.config cattle.config chimp.config dog.config

date | tee -a ${LOG}
echo 'Generate Orthologyload Files (HCOP)' | tee -a ${LOG}
${MGD_DBUTILS}/bin/generateHCOP.csh

date | tee -a ${LOG}
echo 'Run Orthologyload (Human, Rat, Cattle, Chimp, Dog, HCOP)' | tee -a ${LOG}
${ORTHOLOGYLOAD}/bin/orthologyload.csh ${ORTHOLOGYLOAD}/human.config ${ORTHOLOGYLOAD}/rat.config ${ORTHOLOGYLOAD}/cattle.config ${ORTHOLOGYLOAD}/chimp.config ${ORTHOLOGYLOAD}/dog.config ${ORTHOLOGYLOAD}/hcop.config

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
echo 'Load GOA Annotations' | tee -a ${LOG}
${GOALOAD}/bin/goa.csh

date | tee -a ${LOG}
echo 'GO/Rat Load' | tee -a ${LOG}
${GORATLOAD}/bin/gorat.sh

date | tee -a ${LOG}
echo 'GO/RefGenome Load' | tee -a ${LOG}
${GOREFGENLOAD}/bin/gorefgen.sh

date | tee -a ${LOG}
echo 'Load GOA/Human Annotations' | tee -a ${LOG}
${GOAHUMANLOAD}/bin/goahuman.sh

date | tee -a ${LOG}
echo 'GOCFP Load' | tee -a ${LOG}
${GOCFPLOAD}/bin/gocfp.sh

date | tee -a ${LOG}
echo 'Load Voc/Count Cache Table' | tee -a ${LOG}
${MGICACHELOAD}/voccounts.csh
date | tee -a ${LOG}
echo 'Load Voc/Marker Cache Table' | tee -a ${LOG}
${MGICACHELOAD}/vocmarker.csh
date | tee -a ${LOG}
echo 'Load Voc/Allele Cache Table' | tee -a ${LOG}
${MGICACHELOAD}/vocallele.csh

# this must run before the generateGIAAssoc.csh script
# which depends on GIA_???.py reports
date | tee -a ${LOG}
echo 'QC Reports' | tee -a ${LOG}
${QCRPTS}/qcweekly_reports.csh

# this generates the input files for the association load which runs
# Tuesday AM (mondaytasks.csh). It takes about 4 hours, so run in background
# Must run Mouse EntrezGene Load, SwissProt Load and wkly qc reports first
# the association loads runs Monday night via mondaytasks.csh
date | tee -a ${LOG}
echo 'Generate DoTS/NIA/DFCI Association Files' | tee -a ${LOG}
${MGD_DBUTILS}/bin/generateGIAssoc.csh >& ${DOTS_NIA_DFCI_LOG} &

date | tee -a ${LOG}
echo 'Create Post-Sunday Database Backup' | tee -a ${LOG}
${MGI_DBUTILS}/bin/mgi_backup_to_disk.csh ${MGD_DBSERVER} "${MGD_DBNAME} ${RADAR_DBNAME}" postsunday

#
# Wait for the "SNP DB Loaded" flag to be set. Stop waiting if the number
# of retries expires or the abort flag is found.
#
date | tee -a ${LOG}
echo 'Wait for the "SNP DB Loaded" flag to be set' | tee -a ${LOG}

setenv RETRY ${PROC_CTRL_RETRIES}
while (${RETRY} > 0)
    setenv READY `${PROC_CTRL_CMD_PROD}/getFlag ${NS_PROD_LOAD} ${FLAG_SNP_LOADED}`
    setenv ABORT `${PROC_CTRL_CMD_PROD}/getFlag ${NS_PROD_LOAD} ${FLAG_ABORT}`

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
# Clear the "SNP DB Loaded" flag.
#
date | tee -a ${LOG}
echo 'Clear process control flag: SNP DB Loaded' | tee -a ${LOG}
${PROC_CTRL_CMD_PROD}/clearFlag ${NS_PROD_LOAD} ${FLAG_SNP_LOADED} ${SCRIPT_NAME}

date | tee -a ${LOG}
echo 'Generate Frontend Info' | tee -a ${LOG}
${LOADADMIN}/prod/genFrontend.csh

echo "${SCRIPT_NAME} completed successfully" | tee -a ${LOG}
date | tee -a ${LOG}
exit 0
