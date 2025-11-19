#!/bin/csh -f
#
#  sundaytasks2.csh
###########################################################################
#
#  Purpose:
#
#      This script is a wrapper for part 2 of the Sunday production tasks.
#
#  Usage:
#
#      sundaytasks2.csh
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
#          - mgd.midsunday.dump
#          - radar.midsunday.dump
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
echo 'Run Pubmed To Gene Load' | tee -a ${LOG}
${PUBMED2GENELOAD}/bin/pubmed2geneload.sh

date | tee -a ${LOG}
echo 'Run Problem Alignment Sequence Set Load' | tee -a ${LOG}
${PROBLEMSEQSETLOAD}/bin/problemseqsetload.sh

date | tee -a ${LOG}
echo 'Run PARtner Of Relationship Load' | tee -a ${LOG}
${PARTNEROFLOAD}/bin/partnerofload.sh

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
${VOCLOAD}/runOBOIncLoad.sh CL.config

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
echo 'Run Sequence Ontology Vocab Load' | tee -a ${LOG}
${VOCLOAD}/runOBOIncLoad.sh SO.config

date | tee -a ${LOG}
echo 'Run OMIM/HPO Annotation Load' | tee -a ${LOG}
${OMIMHPOLOAD}/bin/omim_hpoload.sh

date | tee -a ${LOG}
echo 'Run Non-Mouse EntrezGene Load' | tee -a ${LOG}
${ENTREZGENELOAD}/loadAll.csh

date | tee -a ${LOG}
echo 'Run Human Coordinate Load' | tee -a ${LOG}
${HUMANCOORDLOAD}/bin/humancoordload.sh

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
echo 'Run Homology Loads' | tee -a ${LOG}
${HOMOLOGYLOAD}/bin/homologyload.sh alliance_directload.config
${HOMOLOGYLOAD}/bin/homologyload.sh alliance_clusteredload.config
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
echo 'Update Reference Workflow Status' | tee -a ${LOG}
${PG_DBUTILS}/sp/run_BIB_updateWFStatus.csh

echo "${SCRIPT_NAME} completed successfully" | tee -a ${LOG}
date | tee -a ${LOG}
exit 0
