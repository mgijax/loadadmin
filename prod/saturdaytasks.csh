#!/bin/csh -f
#
#  saturdaytasks.csh
###########################################################################
#
#  Purpose:
#
#      This script is a wrapper for the Saturday production tasks.
#
#  Usage:
#
#      saturdaytasks.csh
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
#          - mgd.presaturdaybackup1, mgd.presaturdaybackup2
#          - radar.presaturdaybackup1, radar.presaturdaybackup2
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

setenv EI_MAIL_LIST mgi

setenv LOG ${LOGSDIR}/${SCRIPT_NAME}.log
rm -f ${LOG}
touch ${LOG}

echo "$0" >> ${LOG}
env | sort >> ${LOG}

date | tee -a ${LOG}
echo 'Reset process control flags in production load namespace' | tee -a ${LOG}
${PROC_CTRL_CMD_PROD}/resetFlags ${NS_PROD_LOAD} ${SCRIPT_NAME}

date | tee -a ${LOG}
echo 'Create Pre-Saturday Database Backup' | tee -a ${LOG}
${MGI_DBUTILS}/bin/mgi_backup_to_disk.csh ${MGD_DBSERVER} "${MGD_DBNAME} ${RADAR_DBNAME}" presaturday

date | tee -a ${LOG}
echo 'Set process control flag: MGD PreBackup Ready' | tee -a ${LOG}
${PROC_CTRL_CMD_PROD}/setFlag ${NS_PROD_LOAD} ${FLAG_MGD_PREBACKUP} ${SCRIPT_NAME}

date | tee -a ${LOG}
echo 'EMAGE Load' | tee -a ${LOG}
${EMAGELOAD}/bin/emageload.sh

date | tee -a ${LOG}
echo 'GEO Load' | tee -a ${LOG}
${GEOLOAD}/bin/geoload.sh

date | tee -a ${LOG}
echo 'GENSAT Load' | tee -a ${LOG}
${GENSATLOAD}/bin/gensatload.sh

date | tee -a ${LOG}
echo 'Array Express Load' | tee -a ${LOG}
${ARRAYEXPLOAD}/bin/arrayexpload.sh

date | tee -a ${LOG}
echo 'Microarray Chip Loads' | tee -a ${LOG}
${MACHIPLOAD}/bin/machiploadall.sh

date | tee -a ${LOG}
echo 'FuncBase Load' | tee -a ${LOG}
${MOUSEFUNCLOAD}/bin/mousefuncload.sh

date | tee -a ${LOG}
echo 'MouseCyc Load' | tee -a ${LOG}
${MOUSECYCLOAD}/mousecycload.sh

date | tee -a ${LOG}
echo 'Protein Ontology Load' | tee -a ${LOG}
${PROLOAD}/bin/proload.sh

date | tee -a ${LOG}
echo 'MCV Vocabulary Load' | tee -a ${LOG}
${MCVLOAD}/bin/run_mcv_vocload.sh

date | tee -a ${LOG}
echo 'MCV Annotation Load' | tee -a ${LOG}
${MCVLOAD}/bin/mcvload.sh

date | tee -a ${LOG}
echo 'Targeted Allele Loads' | tee -a ${LOG}
${TARGETEDALLELELOAD}/bin/targetedalleleload.sh tal_csd_mbp.config
${TARGETEDALLELELOAD}/bin/targetedalleleload.sh tal_csd_wtsi.config
${TARGETEDALLELELOAD}/bin/targetedalleleload.sh tal_eucomm_hmgu.config
${TARGETEDALLELELOAD}/bin/targetedalleleload.sh tal_eucomm_wtsi.config

date | tee -a ${LOG}
echo 'Process cDNA Load Incrementals' | tee -a ${LOG}
${GBCDNALOAD}/bin/GBcDNALoad.sh

date | tee -a ${LOG}
echo 'Process MGC Associations' | tee -a ${LOG}
${MGCLOAD}/bin/MGCLoad.sh

date | tee -a ${LOG}
echo 'Sanger MP Load' | tee -a ${LOG}
${HTMPLOAD}/bin/htmpload.sh ${HTMPLOAD}/sangermpload.config ${HTMPLOAD}/annotload.config

date | tee -a ${LOG}
echo 'Europhenome MP Load' | tee -a ${LOG}
${HTMPLOAD}/bin/htmpload.sh ${HTMPLOAD}/europhenompload.config ${HTMPLOAD}/annotload.config

date | tee -a ${LOG}
echo 'Process SwissPROT/TrEMBL' | tee -a ${LOG}
${SPSEQLOAD}/bin/spseqload.sh spseqload.config
${SPSEQLOAD}/bin/spseqload.sh trseqload.config

date | tee -a ${LOG}
echo 'Process RefSeq Incrementals' | tee -a ${LOG}
${REFSEQLOAD}/bin/refseqload.sh

date | tee -a ${LOG}
echo 'Process GenBank Incrementals' | tee -a ${LOG}
${GBSEQLOAD}/bin/gbseqload.sh

date | tee -a ${LOG}
echo 'Set process control flag: GB Seqload Done' | tee -a ${LOG}
${PROC_CTRL_CMD_PROD}/setFlag ${NS_PROD_LOAD} ${FLAG_GBSEQLOAD} ${SCRIPT_NAME}

#
# Wait for the "GT Filter Done" flag to be set. Stop waiting if the number
# of retries expires or the abort flag is found.
#
date | tee -a ${LOG}
echo 'Wait for the "GT Filter Done" flag to be set' | tee -a ${LOG}

setenv RETRY ${PROC_CTRL_RETRIES}
while (${RETRY} > 0)
    setenv READY `${PROC_CTRL_CMD_PROD}/getFlag ${NS_PROD_LOAD} ${FLAG_GTFILTER}`
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

date | tee -a ${LOG}
echo 'Run Ensembl Gene Model/Association Load' | tee -a ${LOG}
${GENEMODELLOAD}/bin/genemodelload.sh ensembl

date | tee -a ${LOG}
echo 'Run NCBI Gene Model/Association Load' | tee -a ${LOG}
${GENEMODELLOAD}/bin/genemodelload.sh ncbi

date | tee -a ${LOG}
echo 'Run VEGA Gene Model/Association Load' | tee -a ${LOG}
${GENEMODELLOAD}/bin/genemodelload.sh vega

#
# This is to update biotypes weekly since NCBI gene model load above
# rarely runs.
#
date | tee -a ${LOG}
echo 'Run NCBI SEQ_GeneModel Load' | tee -a ${LOG}
${GENEMODELLOAD}/bin/seqgenemodelload.sh ncbi

#
# Wait for the "GT Blat Done" flag to be set. Stop waiting if the number
# of retries expires or the abort flag is found.
#
date | tee -a ${LOG}
echo 'Wait for the "GT Blat Done" flag to be set' | tee -a ${LOG}

setenv RETRY ${PROC_CTRL_RETRIES}
while (${RETRY} > 0)
    setenv READY `${PROC_CTRL_CMD_PROD}/getFlag ${NS_PROD_LOAD} ${FLAG_GTBLAT}`
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

date | tee -a ${LOG}
echo 'Run Gene Trap Load' | tee -a ${LOG}
${GENETRAPLOAD}/bin/genetrapload.sh

date | tee -a ${LOG}
echo 'Create Dummy Sequences' | tee -a ${LOG}
${SEQCACHELOAD}/seqdummy.csh

date | tee -a ${LOG}
echo 'Load Sequence/Coordinate Cache Table' | tee -a ${LOG}
${SEQCACHELOAD}/seqcoord.csh
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
echo 'Load Marker/Label Cache Table' | tee -a ${LOG}
${MRKCACHELOAD}/mrklabel.csh
date | tee -a ${LOG}
echo 'Load Marker/Reference Cache Table' | tee -a ${LOG}
${MRKCACHELOAD}/mrkref.csh
date | tee -a ${LOG}
echo 'Load Marker/Homology Cache Table' | tee -a ${LOG}
${MRKCACHELOAD}/mrkhomology.csh
date | tee -a ${LOG}
echo 'Load Marker/Location Cache Table' | tee -a ${LOG}
${MRKCACHELOAD}/mrklocation.csh
date | tee -a ${LOG}
echo 'Load Marker/Probe Cache Table' | tee -a ${LOG}
${MRKCACHELOAD}/mrkprobe.csh
date | tee -a ${LOG}
echo 'Load Marker/MCV Cache Table' | tee -a ${LOG}
${MRKCACHELOAD}/mrkmcv.csh

# removed this call for Build 38 release as we don't yet have
# data to update cM for Build 38
#date | tee -a ${LOG}
#echo 'Load Genetic Map Tables' | tee -a ${LOG}
#${GENMAPLOAD}/bin/genmapload.sh

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
echo 'Load Bib Citation Cache Table' | tee -a ${LOG}
${MGICACHELOAD}/bibcitation.csh
date | tee -a ${LOG}
echo 'Load Image Cache Table' | tee -a ${LOG}
${MGICACHELOAD}/imgcache.csh

date | tee -a ${LOG}
echo 'Load Voc/Count Cache Table' | tee -a ${LOG}
${MGICACHELOAD}/voccounts.csh
date | tee -a ${LOG}
echo 'Load Voc/Marker Cache Table' | tee -a ${LOG}
${MGICACHELOAD}/vocmarker.csh
date | tee -a ${LOG}
echo 'Load Voc/Allele Cache Table' | tee -a ${LOG}
${MGICACHELOAD}/vocallele.csh

#
# Uncomment this when an extra backup is needed.
#
#date | tee -a ${LOG}
#echo 'Create Post-Saturday Database Backup' | tee -a ${LOG}
#${MGI_DBUTILS}/bin/mgi_backup_to_disk.csh ${MGD_DBSERVER} "${MGD_DBNAME} ${RADAR_DBNAME}" postsaturday

date | tee -a ${LOG}
echo 'Generate Frontend Info' | tee -a ${LOG}
${LOADADMIN}/prod/genFrontend.csh

if ( -e ${MGI_LIVE}/ei.disable ) then
    date | tee -a ${LOG}
    echo 'Enable the EI' | tee -a ${LOG}
    cd ${MGI_LIVE}
    mv ei.disable ei
    set dayname=`date '+%A'`
    echo "The nightly loads have completed and the production EI is now available." | mailx -s "Production EI is now available ($dayname)" ${EI_MAIL_LIST}
endif

echo "${SCRIPT_NAME} completed successfully" | tee -a ${LOG}
date | tee -a ${LOG}
exit 0
