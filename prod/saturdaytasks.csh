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
#      - Database backups
#          - mgd.presaturday.dump
#          - radar.presaturday.dump
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
echo 'Make sure the database is available before starting' | tee -a ${LOG}
${PG_DBUTILS}/bin/testConnection.csh ${PG_DBSERVER} ${PG_DBNAME}
if ( $status != 0 ) then
    echo "Cannot connect to database ${PG_DBSERVER}.${PG_DBNAME}. Abort load schedule." | tee -a ${LOG}
    exit 1
endif

date | tee -a ${LOG}
echo 'Create Pre-Saturday Database Backups' | tee -a ${LOG}
${PG_DBUTILS}/bin/dumpDB.csh ${PG_DBSERVER} ${PG_DBNAME} mgd ${DB_BACKUP_DIR}/mgd.presaturday.dump
${PG_DBUTILS}/bin/dumpDB.csh ${PG_DBSERVER} ${PG_DBNAME} radar ${DB_BACKUP_DIR}/radar.presaturday.dump

date | tee -a ${LOG}
echo 'Perform special character cleanup' | tee -a ${LOG}
${PG_DBUTILS}/bin/cleanSpecChar.csh

date | tee -a ${LOG}
echo 'Run GEO Load' | tee -a ${LOG}
${GEOLOAD}/bin/geoload.sh

#date | tee -a ${LOG}
#echo 'Run GENSAT Load' | tee -a ${LOG}
#${GENSATLOAD}/bin/gensatload.sh

#date | tee -a ${LOG}
#echo 'Run Array Express Load' | tee -a ${LOG}
#${ARRAYEXPLOAD}/bin/arrayexpload.sh

date | tee -a ${LOG}
echo 'Run Protein Ontology Load' | tee -a ${LOG}
${PROLOAD}/bin/proload.sh

date | tee -a ${LOG}
echo 'Run RV Load' | tee -a ${LOG}
${RVLOAD}/bin/rvload.sh

date | tee -a ${LOG}
echo 'Run FeaR Load' | tee -a ${LOG}
${FEARLOAD}/bin/fearload.sh

date | tee -a ${LOG}
echo 'Run EMAP Slim Load' | tee -a ${LOG}
${SLIMTERMLOAD}/bin/slimtermload.sh emapslimload.config

date | tee -a ${LOG}
echo 'Run GO Slim Load' | tee -a ${LOG}
${SLIMTERMLOAD}/bin/slimtermload.sh goslimload.config

date | tee -a ${LOG}
echo 'Run MP Slim Load' | tee -a ${LOG}
${SLIMTERMLOAD}/bin/slimtermload.sh mpslimload.config

date | tee -a ${LOG}
echo 'Run Targeted Allele Loads' | tee -a ${LOG}
${TARGETEDALLELELOAD}/bin/targetedalleleload.sh tal_csd_mbp.config
${TARGETEDALLELELOAD}/bin/targetedalleleload.sh tal_csd_wtsi.config
${TARGETEDALLELELOAD}/bin/targetedalleleload.sh tal_eucomm_hmgu.config
${TARGETEDALLELELOAD}/bin/targetedalleleload.sh tal_eucomm_wtsi.config

date | tee -a ${LOG}
echo 'Run Allele Load' | tee -a ${LOG}
${ALLELELOAD}/bin/makeIKMC.sh ikmc.config

date | tee -a ${LOG}
echo 'Update IMSR Germline' | tee -a ${LOG}
${PG_DBUTILS}/bin/updateIMSRgermline.csh

date | tee -a ${LOG}
echo 'Run MP Annotation Loads' | tee -a ${LOG}
${HTMPLOAD}/bin/runMpLoads.sh

date | tee -a ${LOG}
echo 'Run MP EMAPA Load' | tee -a ${LOG}
${MPEMAPALOAD}/bin/mp_emapaload.sh

date | tee -a ${LOG}
echo 'Run GXD HT Load' | tee -a ${LOG}
${GXDHTLOAD}/bin/gxdhtload.sh

date | tee -a ${LOG}
echo 'Run SwissPROT Sequence Load' | tee -a ${LOG}
${SPSEQLOAD}/bin/spseqload.sh spseqload.config

date | tee -a ${LOG}
echo 'Run TrEMBL Sequence Load' | tee -a ${LOG}
${SPSEQLOAD}/bin/spseqload.sh trseqload.config

date | tee -a ${LOG}
echo 'Run RefSeq Sequence Load' | tee -a ${LOG}
${REFSEQLOAD}/bin/refseqload.sh

date | tee -a ${LOG}
echo 'Run GenBank Sequence Load' | tee -a ${LOG}
${GBSEQLOAD}/bin/gbseqload.sh

date | tee -a ${LOG}
echo 'Run Ensembl Gene Model/Association Load' | tee -a ${LOG}
${GENEMODELLOAD}/bin/genemodelload.sh ensembl

date | tee -a ${LOG}
echo 'Run NCBI Gene Model/Association Load' | tee -a ${LOG}
${GENEMODELLOAD}/bin/genemodelload.sh ncbi

#
# This is to update biotypes weekly since NCBI gene model load above
# rarely runs.
#
date | tee -a ${LOG}
echo 'Run NCBI SEQ_GeneModel Load' | tee -a ${LOG}
${GENEMODELLOAD}/bin/seqgenemodelload.sh ncbi

date | tee -a ${LOG}
echo 'Run EMAL Load' | tee -a ${LOG}
${EMALLOAD}/bin/emalload.sh  ${EMALLOAD}/impc.config

date | tee -a ${LOG}
echo 'Run Strain Gene Model Load' | tee -a ${LOG}
${STRAINGENEMODELLOAD}/bin/straingenemodelload.sh

date | tee -a ${LOG}
echo 'Run RNA Sequence Load' | tee -a ${LOG}
${RNASEQLOAD}/bin/rnaseqload.sh

date | tee -a ${LOG}
echo 'Run Rollup Load' | tee -a ${LOG}
${ROLLUPLOAD}/bin/rollupload.sh

date | tee -a ${LOG}
echo 'Run QTL Archive Load' | tee -a ${LOG}
${QTLARCHIVELOAD}/bin/qtlarchiveload.sh ${QTLARCHIVELOAD}/qtlarchiveload.config

date | tee -a ${LOG}
echo 'Create Dummy Sequences' | tee -a ${LOG}
${SEQCACHELOAD}/seqdummy.csh

date | tee -a ${LOG}
echo 'Run Sequence/Coordinate Cache Load' | tee -a ${LOG}
${SEQCACHELOAD}/seqcoord.csh

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
echo 'Run ALO/Marker Load' | tee -a ${LOG}
${ALOMRKLOAD}/bin/alomrkload.sh

#date | tee -a ${LOG}
#echo 'Run Genetic Map Load' | tee -a ${LOG}
#${GENMAPLOAD}/bin/genmapload.sh

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
echo 'Run Bib Citation Cache Load' | tee -a ${LOG}
${MGICACHELOAD}/bibcitation.csh

date | tee -a ${LOG}
echo 'Update Reference Workflow Status' | tee -a ${LOG}
${PG_DBUTILS}/sp/run_BIB_updateWFStatus.csh

echo "${SCRIPT_NAME} completed successfully" | tee -a ${LOG}
date | tee -a ${LOG}
exit 0
