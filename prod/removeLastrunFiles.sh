#!/bin/sh

if [ "${MGICONFIG}" = "" ]
then
    MGICONFIG=/usr/local/mgi/live/mgiconfig
    export MGICONFIG
fi

. ${MGICONFIG}/master.config.sh

rm -f ${DATALOADSOUTPUT}/go/lastrun
rm -f ${DATALOADSOUTPUT}/mgi/curatoralleleload/input/lastrun
rm -f ${DATALOADSOUTPUT}/mgi/curatorbulkindexload/input/lastrun
rm -f ${DATALOADSOUTPUT}/mgi/curatorstrainload/input/lastruncreate
rm -f ${DATALOADSOUTPUT}/mgi/curatorstrainload/input/lastrunupdate
rm -f ${DATALOADSOUTPUT}/mgi/emalload/impc/input/lastrun
rm -f ${DATALOADSOUTPUT}/mgi/fearload/input/lastrun
rm -f ${DATALOADSOUTPUT}/mgi/htmpload/impcmpload/input/lastrun
rm -f ${DATALOADSOUTPUT}/mgi/mcvload/input/lastrun
rm -f ${DATALOADSOUTPUT}/mgi/mrkcoordload/input/lastrun
rm -f ${DATALOADSOUTPUT}/mgi/partnerofload/input/lastrun
rm -f ${DATALOADSOUTPUT}/mgi/problemseqsetload/input/lastrun
rm -f ${DATALOADSOUTPUT}/mgi/rvload/input/lastrun
rm -f ${DATALOADSOUTPUT}/mgi/slimtermload/emapslimload/input/lastrun
rm -f ${DATALOADSOUTPUT}/mgi/slimtermload/goslimload/input/lastrun
rm -f ${DATALOADSOUTPUT}/mgi/slimtermload/mpslimload/input/lastrun
rm -f ${DATALOADSOUTPUT}/mgi/strainmarkerload/output/lastrun
rm -f ${DATALOADSOUTPUT}/mgi/uniprotmusfilter/input/lastrun
rm -f ${DATALOADSOUTPUT}/mgi/vocload/emap/input/lastrun
rm -f ${DATALOADSOUTPUT}/pro/proload/input/lastrun
#rm -f ${DATALOADSOUTPUT}/arrayexpress/arrayexpload/input/lastrun
#rm -f ${DATALOADSOUTPUT}/mgi/htmpload/impclaczload.alz/input/lastrun
#rm -f ${DATALOADSOUTPUT}/mgi/htmpload/impclaczload/input/lastrun
#rm -f ${DATALOADSOUTPUT}/mgi/nomenload/input/lastrun
#rm -f ${DATALOADSOUTPUT}/mp_hpo/input/lastrun
#rm -f ${DATALOADSOUTPUT}/mgi/qtlarchiveload/input/lastrun
#rm -f ${DATALOADSOUTPUT}/mgi/qtlinteractionload/input/lastrun
#rm -f ${DATALOADSOUTPUT}/swissprot/spseqload/input/lastrun
#rm -f ${DATALOADSOUTPUT}/swissprot/trseqload/input/lastrun
