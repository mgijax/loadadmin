#!/bin/sh

#
# if you want to copy the prod outputs to *.prod for later comparison,
# uncomment the various scp and rsync commands below
#

if [ "${MGICONFIG}" = "" ]
then
    MGICONFIG=/usr/local/mgi/live/mgiconfig
    export MGICONFIG
fi

. ${MGICONFIG}/master.config.sh

# remove lastrun
rm -rf ${DATALOADSOUTPUT}/mgi/nomenload/input/lastrun
rm -rf ${DATALOADSOUTPUT}/mgi/mcvload/input/lastrun
rm -rf ${DATALOADSOUTPUT}/mgi/mrkcoordload/input/lastrun
rm -rf ${DATALOADSOUTPUT}/mgi/rvload/input/lastrun
rm -rf ${DATALOADSOUTPUT}/mgi/emalload/impc/input/lastrun

# refseq seqdeleter
scp bhmgiapp01:/data/downloads/ftp.ncbi.nih.gov/refseq/refseq_deletes/suppressed_* /data/downloads/ftp.ncbi.nih.gov/refseq/refseq_deletes

# gb seqdeleter
scp bhmgiapp01:/data/downloads/ftp.ncbi.nih.gov/genbank/gb_deletes/gbdel.txt.gz /data/downloads/ftp.ncbi.nih.gov/genbank/gb_deletes

# goload
scp bhmgiapp01:/data/downloads/purl.obolibrary.org/obo/pr/pr-dev.gpi /data/downloads/purl.obolibrary.org/obo/pr
scp bhmgiapp01:/data/downloads/purl.obolibrary.org/obo/uberon.obo /data/downloads/purl.obolibrary.org/obo
scp bhmgiapp01:/data/downloads/snapshot.geneontology.org/annotations/mgi.gpad.gz /data/downloads/snapshot.geneontology.org/annotations

# littriageload
#rsync -avz bhmgiapp01:/data/loads/mgi/littriageload/logs ${DATALOADSOUTPUT}/mgi/littriageload/logs.prod
#rsync -avz bhmgiapp01:/data/loads/mgi/littriageload/output ${DATALOADSOUTPUT}/mgi/littriageload/output.prod

# noteload/gotext
scp bhmgiapp01:/data/downloads/fms.alliancegenome.org/download/GENE-DESCRIPTION-TXT_MGI.txt.gz /data/downloads/fms.alliancegenome.org/download/

# vocload/MP
#rsync -avz bhmgiapp01:/data/loads/mgi/vocload/runTimeMP ${DATALOADSOUTPUT}/mgi/vocload/runTimeMP.prod
scp bhmgiapp01:/data/loads/mgi/vocload/runTimeMP/MPheno_OBO.ontology ${DATALOADSOUTPUT}/mgi/vocload/runTimeMP
scp bhmgiapp01:/data/loads/mgi/vocload/runTimeMP/MP.header ${DATALOADSOUTPUT}/mgi/vocload/runTimeMP
scp bhmgiapp01:/data/loads/mgi/vocload/runTimeMP/MP.note ${DATALOADSOUTPUT}/mgi/vocload/runTimeMP
scp bhmgiapp01:/data/loads/mgi/vocload/runTimeMP/MP.synonym ${DATALOADSOUTPUT}/mgi/vocload/runTimeMP
scp bhmgiapp01:/data/loads/mgi/vocload/runTimeMP/mp.json ${DATALOADSOUTPUT}/mgi/vocload/runTimeMP
scp bhmgiapp01:/data/loads/mgi/vocload/runTimeMP/mp.owl ${DATALOADSOUTPUT}/mgi/vocload/runTimeMP

# vocload/GO
scp bhmgiapp01:/data/downloads/purl.obolibrary.org/obo/go/snapshot/go-basic.obo /data/downloads/purl.obolibrary.org/obo/go/snapshot
#rsync -avz bhmgiapp01:/data/loads/mgi/vocload/runTimeGO ${DATALOADSOUTPUT}/mgi/vocload/runTimeGO.prod

# vocload/EMAP
scp bhmgiapp01:/data/loads/mgi/vocload/emap/input/EMAPA.obo ${DATALOADSOUTPUT}/mgi/vocload/emap/input
#rsync -avz bhmgiapp01:/data/loads/mgi/vocload/emap/input ${DATALOADSOUTPUT}/mgi/vocload/emap/input.prod
#rsync -avz bhmgiapp01:/data/loads/mgi/vocload/emap/output ${DATALOADSOUTPUT}/mgi/vocload/emap/output.prod
#rsync -avz bhmgiapp01:/data/loads/mgi/slimtermload/emapslimload bhmgiapp01:${DATALOADSOUTPUT}/mgi/slimtermload/emapslimload.prod

# mcvload
scp bhmgiapp01:/data/loads/mgi/mcvload/input/mcvload.txt ${DATALOADSOUTPUT}/mgi/mcvload/input/mcvload.txt
scp bhmgiapp01:/data/loads/mgi/mcvload/input/MCV_Vocab.obo ${DATALOADSOUTPUT}/mgi/mcvload/input/MCV_Vocab.obo
#rsync -avz bhmgiapp01:/data/loads/mgi/mcvload/input ${DATALOADSOUTPUT}/mgi/mcvload/input.prod
#rsync -avz bhmgiapp01:/data/loads/mgi/mcvload/output ${DATALOADSOUTPUT}/mgi/mcvload/output.prod

# rvload
scp bhmgiapp01:/data/loads/mgi/rvload/input/RelationshipVocab.obo ${DATALOADSOUTPUT}/mgi/rvload/input
#rsync -avz bhmgiapp01:/data/loads/mgi/rvload/input ${DATALOADSOUTPUT}/mgi/rvload/input.prod
#rsync -avz bhmgiapp01:/data/loads/mgi/rvload/output ${DATALOADSOUTPUT}/mgi/rvload/output.prod

# mrkcoordload - mocked up file
scp bhmgiapp01:/data/loads/mgi/mrkcoordload/input/mrkcoordload.txt ${DATALOADSOUTPUT}/mgi/mrkcoordload/input
#rsync -avz bhmgiapp01:/data/loads/mgi/mrkcoordload/input ${DATALOADSOUTPUT}/mgi/mrkcoordload/input.prod
#rsync -avz bhmgiapp01:/data/loads/mgi/mrkcoordload/output ${DATALOADSOUTPUT}/mgi/mrkcoordload/output.prod

# For SEQ_NMs.py
scp bhmgiapp01:/data/loads/entrezgene/egload/reports/bucket_one_to_many.txt ${DATALOADSOUTPUT}/entrezgene/egload/reports
scp bhmgiapp01:/data/loads/entrezgene/egload/reports/bucket_zero_to_one.txt ${DATALOADSOUTPUT}/entrezgene/egload/reports
scp bhmgiapp01:/data/loads/entrezgene/egload/reports/bucket_many_to_one.txt ${DATALOADSOUTPUT}/entrezgene/egload/reports
scp bhmgiapp01:/data/loads/entrezgene/egload/reports/bucket_many_to_many.txt ${DATALOADSOUTPUT}/entrezgene/egload/reports

# mrkcacheload
#rsync -avz bhmgiapp01:/data/loads/mgi/mgicacheload/output ${DATALOADSOUTPUT}/mgi/mgicacheload/output.prod

