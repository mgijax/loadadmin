#!/bin/csh -f

cd `dirname $0` && source ./Configuration

setenv SCRIPT_NAME `basename $0`

setenv LOG ${LOGSDIR}/${SCRIPT_NAME}.log
rm -f ${LOG}
touch ${LOG}

echo "$0" >> ${LOG}
env | sort >> ${LOG}

date | tee -a ${LOG}
echo 'Run RefSeq Sequence Deleter' | tee -a ${LOG}
${SEQDELETER}/bin/seqdeleter.sh refseqdeleter.config

date | tee -a ${LOG}
echo 'Run GenBank Sequence Deleter' | tee -a ${LOG}
${SEQDELETER}/bin/seqdeleter.sh gbseqdeleter.config

date | tee -a ${LOG}
echo 'Run Marker/Coordinate Load' | tee -a ${LOG}
${MRKCOORDLOAD}/bin/mrkcoordload.sh
${MRKCOORDLOAD}/bin/mrkcoordDelete.sh

date | tee -a ${LOG}
echo 'Run SwissPROT Sequence Load' | tee -a ${LOG}
${SPSEQLOAD}/bin/spseqload.sh spseqload.config

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
echo 'Run Mouse EntrezGene Load' | tee -a ${LOG}
${EGLOAD}/bin/egload.sh

date | tee -a ${LOG}
echo 'Run PIRSF Load' | tee -a ${LOG}
${PIRSFLOAD}/bin/pirsfload.sh

date | tee -a ${LOG}
echo 'Run Human Coordinate Load' | tee -a ${LOG}
${HUMANCOORDLOAD}/bin/humancoordload.sh

echo "${SCRIPT_NAME} completed successfully" | tee -a ${LOG}
date | tee -a ${LOG}
exit 0
