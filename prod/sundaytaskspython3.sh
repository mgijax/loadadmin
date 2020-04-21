#!/bin/sh

# Lori

# goload
scp bhmgiapp01:/data/downloads/snapshot.geneontology.org/products/annotations/mgi-prediction.gaf /data/downloads/go_noctua
scp bhmgiapp01:/data/downloads/snapshot.geneontology.org/products/annotations/noctua_mgi.gpad.gz /data/downloads/go_noctua
scp bhmgiapp01:/data/downloads/snapshot.geneontology.org/products/annotations/noctua_pr.gpad.gz /data/downloads/go_noctua
scp bhmgiapp01:/data/downloads/purl.obolibrary.org/obo/pr.obo /data/downloads/purl.obolibrary.org/obo
scp bhmgiapp01:/data/downloads/purl.obolibrary.org/obo/uberon.obo /data/downloads/purl.obolibrary.org/obo
scp bhmgiapp01:/data/downloads/purl.obolibrary.org/obo/pr/pr-dev.obo /data/downloads/purl.obolibrary.org/obo/pr
scp bhmgiapp01:/data/downloads/goa/HUMAN/goa_human.gaf.gz /data/downloads/goa/HUMAN
scp bhmgiapp01:/data/downloads/goa/HUMAN/goa_human_isoform.gaf.gz /data/downloads/goa/HUMAN
scp bhmgiapp01:/data/downloads/goa/MOUSE/goa_mouse.gaf.gz /data/downloads/goa/MOUSE
scp bhmgiapp01:/data/downloads/goa/MOUSE/goa_mouse_isoform.gaf.gz /data/downloads/goa/MOUSE
scp bhmgiapp01:/data/downloads/purl.obolibrary.org/obo/uberon.obo /data/downloads/purl.obolibrary.org/obo
scp bhmgiapp01:/data/downloads/snapshot.geneontology.org/products/annotations/mgi-prediction.gaf /data/downloads/snapshot.geneontology.org/products/annotations
scp bhmgiapp01:/data/downloads/go_noctua/noctua_mgi.gpad.gz /data/downloads/go_noctua
scp bhmgiapp01:/data/downloads/go_noctua/noctua_pr.gpad.gz /data/downloads/go_noctua
scp bhmgiapp01:/data/downloads/raw.githubusercontent.com/evidenceontology/evidenceontology/master/gaf-eco-mapping-derived.txt /data/downloads/raw.githubusercontent.com/evidenceontology/evidenceontology/master
scp bhmgiapp01:/data/downloads/purl.obolibrary.org/obo/uberon.obo /data/downloads/purl.obolibrary.org/obo
scp bhmgiapp01:/data/downloads/go_gene_assoc/gene_association.rgd.gz /data/downloads/go_gene_assoc
scp bhmgiapp01:/data/downloads/snapshot.geneontology.org/annotations/mgi.gaf.gz /data/downloads/snapshot.geneontology.org/annotations

# vocload
cd /data/loads/mgi/vocload/runTimeMA
scp bhmgiapp01:/data/loads/mgi/vocload/runTimeMA/adult_mouse_anatomy.obo .
scp bhmgiapp01:/data/loads/mgi/vocload/runTimeMA/dagClosure.bcp dagClosure.bcp.prod
scp bhmgiapp01:/data/loads/mgi/vocload/runTimeMA/dagDiscrepancy.html dagDiscrepancy.html.prod
scp bhmgiapp01:/data/loads/mgi/vocload/runTimeMA/dagEdge.bcp dagEdge.bcp.prod
scp bhmgiapp01:/data/loads/mgi/vocload/runTimeMA/dag.ma dag.ma.prod
scp bhmgiapp01:/data/loads/mgi/vocload/runTimeMA/dagNode.bcp dagNode.bcp.prod
scp bhmgiapp01:/data/loads/mgi/vocload/runTimeMA/discrepancy.html discrepancy.html.prod
scp bhmgiapp01:/data/loads/mgi/vocload/runTimeMA/Termfile Termfile.prod

scp bhmgiapp01:/data/downloads/purl.obolibrary.org/obo/cl/cl-basic.obo /data/downloads/purl.obolibrary.org/obo/cl
cd /data/loads/mgi/vocload/runTimeCL
scp bhmgiapp01:/data/loads/mgi/vocload/runTimeCL/accAccession.bcp accAccession.bcp.prod
scp bhmgiapp01:/data/loads/mgi/vocload/runTimeCL/dag.cell dag.cell.prod
scp bhmgiapp01:/data/loads/mgi/vocload/runTimeCL/discrepancy.html discrepancy.html.prod
scp bhmgiapp01:/data/loads/mgi/vocload/runTimeCL/Termfile Termfile.prod
scp bhmgiapp01:/data/loads/mgi/vocload/runTimeCL/termNote.bcp termNote.bcp.prod
scp bhmgiapp01:/data/loads/mgi/vocload/runTimeCL/termNoteChunk.bcp termNoteChunk.bcp.prod
scp bhmgiapp01:/data/loads/mgi/vocload/runTimeCL/termSynonym.bcp termSynonym.bcp.prod
scp bhmgiapp01:/data/loads/mgi/vocload/runTimeCL/termTerm.bcp termTerm.bcp.prod
scp bhmgiapp01:/data/loads/mgi/vocload/runTimeCL/validationLog.txt validationLog.txt.prod

cd /data/loads/mgi/vocload/OMIM
scp bhmgiapp01:/data/downloads/data.omim.org/omim.txt.gz /data/downloads/data.omim.org
scp bhmgiapp01:/data/loads/mgi/vocload/OMIM/OMIM.exclude .
scp bhmgiapp01:/data/loads/mgi/vocload/OMIM/OMIM.special .
scp bhmgiapp01:/data/loads/mgi/vocload/OMIM/OMIM.synonym .
scp bhmgiapp01:/data/loads/mgi/vocload/OMIM/OMIM.translation .
scp bhmgiapp01:/data/loads/mgi/vocload/OMIM/discrepancy.html discrepancy.html.prod
scp bhmgiapp01:/data/loads/mgi/vocload/OMIM/OMIM.tab OMIM.tab.prod
scp bhmgiapp01:/data/loads/mgi/vocload/OMIM/termSynonym.bcp termSynonym.bcp.prod
scp bhmgiapp01:/data/loads/mgi/vocload/OMIM/OMIMtermcheck.2020-04-19.rpt OMIMtermcheck.2020-04-19.rpt
ln -s /data/loads/mgi/vocload/OMIM/OMIMtermcheck.2020-04-19.rpt OMIMtermcheck.current.rpt

cd /data/loads/mgi/vocload/runTimeDO
scp bhmgiapp01:/data/downloads/raw.githubusercontent.com/DiseaseOntology/HumanDiseaseOntology/master/src/ontology/doid-merged.obo /data/downloads/raw.githubusercontent.com/DiseaseOntology/HumanDiseaseOntology/master/src/ontology
scp bhmgiapp01:/data/loads/mgi/vocload/runTimeDO/dagClosure.bcp dagClosure.bcp.prod
scp bhmgiapp01:/data/loads/mgi/vocload/runTimeDO/dagDiscrepancy.html dagDiscrepancy.html.prod
scp bhmgiapp01:/data/loads/mgi/vocload/runTimeDO/dagEdge.bcp dagEdge.bcp.prod
scp bhmgiapp01:/data/loads/mgi/vocload/runTimeDO/dagNode.bcp dagNode.bcp.prod
scp bhmgiapp01:/data/loads/mgi/vocload/runTimeDO/discrepancy.html discrepancy.html.prod
scp bhmgiapp01:/data/loads/mgi/vocload/runTimeDO/dogxdslim.txt dogxdslim.txt.prod
scp bhmgiapp01:/data/loads/mgi/vocload/runTimeDO/domgislimsanity.txt domgislimsanity.txt.prod
scp bhmgiapp01:/data/loads/mgi/vocload/runTimeDO/domgislim.txt domgislim.txt.prod
scp bhmgiapp01:/data/loads/mgi/vocload/runTimeDO/MGI_Set.bcp MGI_Set.bcp.prod
scp bhmgiapp01:/data/loads/mgi/vocload/runTimeDO/MGI_SetMember.bcp MGI_SetMember.bcp.prod
scp bhmgiapp01:/data/loads/mgi/vocload/runTimeDO/Termfile Termfile.prod

cd /data/loads/mgi/vocload/runTimeSO
scp bhmgiapp01:/data/downloads/raw.githubusercontent.com/The-Sequence-Ontology/SO-Ontologies/master/so.obo /data/downloads/raw.githubusercontent.com/The-Sequence-Ontology/SO-Ontologies/master
scp bhmgiapp01:/data/loads/mgi/vocload/runTimeSO/discrepancy.html discrepancy.html.prod
scp bhmgiapp01:/data/loads/mgi/vocload/runTimeSO/Termfile Termfile.prod

cd /data/loads/mgi/vocload/runTimeHPO
scp bhmgiapp01:/data/downloads/purl.obolibrary.org/obo/hp.obo /data/downloads/purl.obolibrary.org/obo
scp bhmgiapp01:/data/loads/mgi/vocload/runTimeHPO/discrepancy.html discrepancy.html.prod
scp bhmgiapp01:/data/loads/mgi/vocload/runTimeHPO/Termfile Termfile.prod
scp bhmgiapp01:/data/loads/mgi/vocload/runTimeHPO/dagClosure.bcp dagClosure.bcp.prod
scp bhmgiapp01:/data/loads/mgi/vocload/runTimeHPO/dagDiscrepancy.html dagDiscrepancy.html.prod
scp bhmgiapp01:/data/loads/mgi/vocload/runTimeHPO/dagEdge.bcp dagEdge.bcp.prod
scp bhmgiapp01:/data/loads/mgi/vocload/runTimeHPO/dag.hpo dag.hpo.prod
scp bhmgiapp01:/data/loads/mgi/vocload/runTimeHPO/dagNode.bcp dagNode.bcp.prod

