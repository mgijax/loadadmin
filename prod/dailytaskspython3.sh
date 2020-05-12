#!/bin/sh

# remove lastrun
rm -rf /data/loads/mgi/nomenload/input/lastrun
rm -rf /data/loads/mgi/mcvload/input/lastrun
rm -rf /data/loads/mgi/mrkcoordload/input/lastrun
rm -rf /data/loads/mgi/rvload/input/lastrun

scp bhmgiapp01:/data/downloads/snapshot.geneontology.org/products/annotations/mgi-prediction.gaf /data/downloads/go_noctua
scp bhmgiapp01:/data/downloads/snapshot.geneontology.org/products/annotations/noctua_mgi.gpad.gz /data/downloads/go_noctua
scp bhmgiapp01:/data/downloads/snapshot.geneontology.org/products/annotations/noctua_pr.gpad.gz /data/downloads/go_noctua
scp bhmgiapp01:/data/downloads/purl.obolibrary.org/obo/uberon.obo data/downloads/purl.obolibrary.org/obo
scp bhmgiapp01:/data/downloads/purl.obolibrary.org/obo/pr/pr-dev.gpi /data/downloads/purl.obolibrary.org/obo/pr
scp bhmgiapp01:/data/downloads/ftp.ebi.ac.uk/pub/databases/GO/goa/MOUSE/goa_mouse.gaf.gz /data/downloads/ftp.ebi.ac.uk/pub/databases/GO/goa/MOUSE
scp bhmgiapp01:/data/downloads/ftp.ebi.ac.uk/pub/databases/GO/goa/MOUSE/goa_mouse.gpi.gz /data/downloads/ftp.ebi.ac.uk/pub/databases/GO/goa/MOUSE
scp bhmgiapp01:/data/downloads/ftp.ebi.ac.uk/pub/databases/GO/goa/MOUSE/goa_mouse_isoform.gaf.gz /data/downloads/ftp.ebi.ac.uk/pub/databases/GO/goa/MOUSE
rsync -avz bhmgiapp01:/data/reports/reports_db/output /data/reports/reports_db/output.prod
rsync -avz bhmgiapp01:/data/loads/go/go
rsync -avz bhmgiapp01:/data/loads/go/gomousenoctua/input /data/loads/go/gomousenoctua/input.prod
rsync -avz bhmgiapp01:/data/loads/go/gomousenoctua/output /data/loads/go/gomousenoctua/output.prod

# littriageload
rsync -avz bhmgiapp01:/data/loads/mgi/littriageload/logs /data/loads/mgi/littriageload/logs.prod
rsync -avz bhmgiapp01:/data/loads/mgi/littriageload/output /data/loads/mgi/littriageload/output.prod

# noteload/gotext
scp bhmgiapp01:/data/loads/go/gotext/input/gotext.txt /data/loads/go/gotext/input
rsync -avz bhmgiapp01:/data/loads/go/gotext /data/loads/go/gotext.prod

# vocload/MP
rsync -avz bhmgiapp01:/data/loads/mgi/vocload/runTimeMP /data/loads/mgi/vocload/runTimeMP.prod
scp bhmgiapp01:/data/loads/mgi/vocload/runTimeMP/MPheno_OBO.ontology /data/loads/mgi/vocload/runTimeMP
scp bhmgiapp01:/data/loads/mgi/vocload/runTimeMP/MP.note /data/loads/mgi/vocload/runTimeMP
scp bhmgiapp01:/data/loads/mgi/vocload/runTimeMP/MP.synonym /data/loads/mgi/vocload/runTimeMP
scp bhmgiapp01:/data/loads/mgi/vocload/runTimeMP/mp.json /data/loads/mgi/vocload/runTimeMP
scp bhmgiapp01:/data/loads/mgi/vocload/runTimeMP/mp.owl /data/loads/mgi/vocload/runTimeMP

# vocload/GO
scp bhmgiapp01:/data/downloads/purl.obolibrary.org/obo/go/snapshot/go-basic.obo /data/downloads/purl.obolibrary.org/obo/go/snapshot
rsync -avz bhmgiapp01:/data/loads/mgi/vocload/runTimeGO /data/loads/mgi/vocload/runTimeGO.prod

# vocload/EMAP
scp bhmgiapp01:/data/loads/mgi/vocload/emap/input/EMAPA.obo /data/loads/mgi/vocload/emap/input
rsync -avz bhmgiapp01:/data/loads/mgi/vocload/emap /data/loads/mgi/vocload/emap.prod
rsync -avz bhmgiapp01:/data/loads/mgi/slimtermload/emapslimload bhmgiapp01:/data/loads/mgi/slimtermload/emapslimload.prod

# mcvload
scp bhmgiapp01:/data/loads/mgi/mcvload/input/mcvload.txt /data/loads/mgi/mcvload/input/mcvload.txt
scp bhmgiapp01:/data/loads/mgi/mcvload/input/MCV_Vocab.obo /data/loads/mgi/mcvload/input/MCV_Vocab.obo
rsync -avz bhmgiapp01:/data/loads/mgi/mcvload /data/loads/mgi/mcvload.prod

# rvload
scp bhmgiapp01:/data/loads/mgi/rvload/input/RelationshipVocab.obo /data/loads/mgi/rvload/input
rsync -avz bhmgiapp01:/data/loads/mgi/rvload /data/loads/mgi/rvload.prod

# mrkcoordload - mocked up file
scp bhmgiapp01:/data/loads/mgi/mrkcoordload/input/mrkcoordload.txt /data/loads/mgi/mrkcoordload/input
rsync -avz bhmgiapp01:/data/loads/mgi/mrkcoordload /data/loads/mgi/mrkcoordload.prod

# For SEQ_NMs.py
scp bhmgiapp01:/data/loads/entrezgene/egload/reports/bucket_one_to_many.txt /data/loads/entrezgene/egload/reports
scp bhmgiapp01:/data/loads/entrezgene/egload/reports/bucket_zero_to_one.txt /data/loads/entrezgene/egload/reports
scp bhmgiapp01:/data/loads/entrezgene/egload/reports/bucket_many_to_one.txt /data/loads/entrezgene/egload/reports
scp bhmgiapp01:/data/loads/entrezgene/egload/reports/bucket_many_to_many.txt /data/loads/entrezgene/egload/reports

# mrkcacheload
rsync -avz bhmgiapp01:/data/loads/mgi/mgicacheload/output /data/loads/mgi/mgicacheload/output.prod

