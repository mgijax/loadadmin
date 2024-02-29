#!/bin/csh -f
#
#  sundaytasks1.csh
###########################################################################
#
#  Purpose:
#
#      This script is a wrapper for part 1 of the Sunday production tasks.
#
#  Usage:
#
#      sundaytasks1.csh
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

if ( "`uname -n | cut -d'.' -f1`" == "bhmgiapp01" ) then
    date | tee -a ${LOG}
    echo 'Save a copy of the prior database backups' | tee -a ${LOG}
    if ( -f ${DB_BACKUP_DIR}/mgd.presunday.dump ) then
        cp -p ${DB_BACKUP_DIR}/mgd.presunday.dump ${DB_BACKUP_DIR}/save
    endif
    if ( -f ${DB_BACKUP_DIR}/radar.presunday.dump ) then
        cp -p ${DB_BACKUP_DIR}/radar.presunday.dump ${DB_BACKUP_DIR}/save
    endif
endif

date | tee -a ${LOG}
echo 'Create Pre-Sunday Database Backups' | tee -a ${LOG}
${PG_DBUTILS}/bin/dumpDB.csh ${PG_DBSERVER} ${PG_DBNAME} mgd ${DB_BACKUP_DIR}/mgd.presunday.dump
${PG_DBUTILS}/bin/dumpDB.csh ${PG_DBSERVER} ${PG_DBNAME} radar ${DB_BACKUP_DIR}/radar.presunday.dump

date | tee -a ${LOG}
echo 'Run HPO Vocab Load' | tee -a ${LOG}
${VOCLOAD}/runOBOIncLoad.sh HPO.config

date | tee -a ${LOG}
echo 'Run GEO Load' | tee -a ${LOG}
${GEOLOAD}/bin/geoload.sh

date | tee -a ${LOG}
echo 'Run GXD High Throughput ArrayExpress Load' | tee -a ${LOG}
${GXDHTLOAD}/bin/ae_htload.sh

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
echo 'Run MP HP Mapping Load' | tee -a ${LOG}
${MPHPMAPPINGLOAD}/bin/mp_hpmappingload.sh

date | tee -a ${LOG}
echo 'Run GXD HT Load' | tee -a ${LOG}
${GXDHTLOAD}/bin/geo_htload.sh

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
echo 'Run Ensembl Regulatory Gene Model/Association Load' | tee -a ${LOG}
${GENEMODELLOAD}/bin/genemodelload.sh ensemblreg

date | tee -a ${LOG}
echo 'Run NCBI Gene Model/Association Load' | tee -a ${LOG}
${GENEMODELLOAD}/bin/genemodelload.sh ncbi

date | tee -a ${LOG}
echo 'Run NCBI SEQ_GeneModel Load' | tee -a ${LOG}
${GENEMODELLOAD}/bin/seqgenemodelload.sh ncbi

date | tee -a ${LOG}
echo 'Run EMAL Load' | tee -a ${LOG}
${EMALLOAD}/bin/emalload.sh  ${EMALLOAD}/impc.config

date | tee -a ${LOG}
echo 'Run TSS Gene Load' | tee -a ${LOG}
${TSSGENELOAD}/bin/tssgeneload.sh

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
echo 'Run QTL Candidate Load' | tee -a ${LOG}
${QTLCANDIDATELOAD}/bin/qtlcandidateload.sh

date | tee -a ${LOG}
echo 'Run QTL Interaction Load' | tee -a ${LOG}
${QTLINTERACTIONLOAD}/bin/qtlinteractionload.sh

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
echo 'Run PubMed Review' | tee -a ${LOG}
${LITTRIAGELOAD}/bin/processPubMedReview.sh

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
