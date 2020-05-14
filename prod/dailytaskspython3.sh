#!/bin/sh

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

# goload
scp bhmgiapp01:/data/downloads/snapshot.geneontology.org/products/annotations/mgi-prediction.gaf /data/downloads/go_noctua
scp bhmgiapp01:/data/downloads/snapshot.geneontology.org/products/annotations/noctua_mgi.gpad.gz /data/downloads/go_noctua
scp bhmgiapp01:/data/downloads/snapshot.geneontology.org/products/annotations/noctua_pr.gpad.gz /data/downloads/go_noctua
scp bhmgiapp01:/data/downloads/purl.obolibrary.org/obo/uberon.obo data/downloads/purl.obolibrary.org/obo
scp bhmgiapp01:/data/downloads/purl.obolibrary.org/obo/pr/pr-dev.gpi /data/downloads/purl.obolibrary.org/obo/pr
scp bhmgiapp01:/data/downloads/ftp.ebi.ac.uk/pub/databases/GO/goa/MOUSE/goa_mouse.gaf.gz /data/downloads/ftp.ebi.ac.uk/pub/databases/GO/goa/MOUSE
scp bhmgiapp01:/data/downloads/ftp.ebi.ac.uk/pub/databases/GO/goa/MOUSE/goa_mouse.gpi.gz /data/downloads/ftp.ebi.ac.uk/pub/databases/GO/goa/MOUSE
scp bhmgiapp01:/data/downloads/ftp.ebi.ac.uk/pub/databases/GO/goa/MOUSE/goa_mouse_isoform.gaf.gz /data/downloads/ftp.ebi.ac.uk/pub/databases/GO/goa/MOUSE
scp bhmgiapp01:/data/reports/reports_db/output/mgi.gpa ${PUBREPORTDIR}/output/mgi.gpa.prod
scp bhmgiapp01:/data/reports/reports_db/output/mgi.gpi ${PUBREPORTDIR}/output/mgi.gpi.prod
scp bhmgiapp01:/data/reports/reports_db/output/gene_association.mgi ${PUBREPORTDIR}/output/gene_association.mgi.prod
scp bhmgiapp01:/data/reports/reports_db/output/gene_association_pro.mgi ${PUBREPORTDIR}/output/gene_association_pro.mgi.prod
rsync -avz bhmgiapp01:/data/loads/go/gomousenoctua/input ${DATALOADSOUTPUT}/go/gomousenoctua/input.prod
rsync -avz bhmgiapp01:/data/loads/go/gomousenoctua/output ${DATALOADSOUTPUT}/go/gomousenoctua/output.prod

# littriageload
rsync -avz bhmgiapp01:/data/loads/mgi/littriageload/logs ${DATALOADSOUTPUT}/mgi/littriageload/logs.prod
rsync -avz bhmgiapp01:/data/loads/mgi/littriageload/output ${DATALOADSOUTPUT}/mgi/littriageload/output.prod

# noteload/gotext
scp bhmgiapp01:/data/loads/go/gotext/input/gotext.txt ${DATALOADSOUTPUT}/go/gotext/input
rsync -avz bhmgiapp01:/data/loads/go/gotext ${DATALOADSOUTPUT}/go/gotext.prod

# vocload/MP
rsync -avz bhmgiapp01:/data/loads/mgi/vocload/runTimeMP ${DATALOADSOUTPUT}/mgi/vocload/runTimeMP.prod
scp bhmgiapp01:/data/loads/mgi/vocload/runTimeMP/MPheno_OBO.ontology ${DATALOADSOUTPUT}/mgi/vocload/runTimeMP
scp bhmgiapp01:/data/loads/mgi/vocload/runTimeMP/MP.note ${DATALOADSOUTPUT}/mgi/vocload/runTimeMP
scp bhmgiapp01:/data/loads/mgi/vocload/runTimeMP/MP.synonym ${DATALOADSOUTPUT}/mgi/vocload/runTimeMP
scp bhmgiapp01:/data/loads/mgi/vocload/runTimeMP/mp.json ${DATALOADSOUTPUT}/mgi/vocload/runTimeMP
scp bhmgiapp01:/data/loads/mgi/vocload/runTimeMP/mp.owl ${DATALOADSOUTPUT}/mgi/vocload/runTimeMP

# vocload/GO
scp bhmgiapp01:/data/downloads/purl.obolibrary.org/obo/go/snapshot/go-basic.obo /data/downloads/purl.obolibrary.org/obo/go/snapshot
rsync -avz bhmgiapp01:/data/loads/mgi/vocload/runTimeGO ${DATALOADSOUTPUT}/mgi/vocload/runTimeGO.prod

# vocload/EMAP
scp bhmgiapp01:/data/loads/mgi/vocload/emap/input/EMAPA.obo ${DATALOADSOUTPUT}/mgi/vocload/emap/input
rsync -avz bhmgiapp01:/data/loads/mgi/vocload/emap/input ${DATALOADSOUTPUT}/mgi/vocload/emap/input.prod
rsync -avz bhmgiapp01:/data/loads/mgi/vocload/emap/output ${DATALOADSOUTPUT}/mgi/vocload/emap/output.prod
rsync -avz bhmgiapp01:/data/loads/mgi/slimtermload/emapslimload bhmgiapp01:${DATALOADSOUTPUT}/mgi/slimtermload/emapslimload.prod

# mcvload
scp bhmgiapp01:/data/loads/mgi/mcvload/input/mcvload.txt ${DATALOADSOUTPUT}/mgi/mcvload/input/mcvload.txt
scp bhmgiapp01:/data/loads/mgi/mcvload/input/MCV_Vocab.obo ${DATALOADSOUTPUT}/mgi/mcvload/input/MCV_Vocab.obo
rsync -avz bhmgiapp01:/data/loads/mgi/mcvload/input ${DATALOADSOUTPUT}/mgi/mcvload/input.prod
rsync -avz bhmgiapp01:/data/loads/mgi/mcvload/output ${DATALOADSOUTPUT}/mgi/mcvload/output.prod

# rvload
scp bhmgiapp01:/data/loads/mgi/rvload/input/RelationshipVocab.obo ${DATALOADSOUTPUT}/mgi/rvload/input
rsync -avz bhmgiapp01:/data/loads/mgi/rvload/input ${DATALOADSOUTPUT}/mgi/rvload/input.prod
rsync -avz bhmgiapp01:/data/loads/mgi/rvload/output ${DATALOADSOUTPUT}/mgi/rvload/output.prod

# mrkcoordload - mocked up file
scp bhmgiapp01:/data/loads/mgi/mrkcoordload/input/mrkcoordload.txt ${DATALOADSOUTPUT}/mgi/mrkcoordload/input
rsync -avz bhmgiapp01:/data/loads/mgi/mrkcoordload/input ${DATALOADSOUTPUT}/mgi/mrkcoordload/input.prod
rsync -avz bhmgiapp01:/data/loads/mgi/mrkcoordload/output ${DATALOADSOUTPUT}/mgi/mrkcoordload/output.prod

# For SEQ_NMs.py
scp bhmgiapp01:/data/loads/entrezgene/egload/reports/bucket_one_to_many.txt ${DATALOADSOUTPUT}/entrezgene/egload/reports
scp bhmgiapp01:/data/loads/entrezgene/egload/reports/bucket_zero_to_one.txt ${DATALOADSOUTPUT}/entrezgene/egload/reports
scp bhmgiapp01:/data/loads/entrezgene/egload/reports/bucket_many_to_one.txt ${DATALOADSOUTPUT}/entrezgene/egload/reports
scp bhmgiapp01:/data/loads/entrezgene/egload/reports/bucket_many_to_many.txt ${DATALOADSOUTPUT}/entrezgene/egload/reports

# mrkcacheload
rsync -avz bhmgiapp01:/data/loads/mgi/mgicacheload/output ${DATALOADSOUTPUT}/mgi/mgicacheload/output.prod

