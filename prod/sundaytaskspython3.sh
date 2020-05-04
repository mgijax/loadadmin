#!/bin/sh

# Sharon

# pubmed2geneload
scp bhmgiapp01:/data/loads/pubmed2geneload/output/MGI_Reference_Assoc.bcp /data/loads/pubmed2geneload/output/MGI_Reference_Assoc.bcp.prod
scp bhmgiapp01:/data/loads/pubmed2geneload/logs/pubmed2geneload.cur.log /data/loads/pubmed2geneload/logs/pubmed2geneload.cur.log.prod

# homologyload
scp bhmgiapp01:/data/downloads/homologene/RELEASE_NUMBER /data/downloads/homologene/

# geisha
scp bhmgiapp01:/data/downloads/geisha.arizona.edu/geisha/orthology.txt /data/downloads/geisha.arizona.edu/geisha/orthology.txt
scp bhmgiapp01:/data/downloads/geisha.arizona.edu/geisha/expression.txt /data/downloads/geisha.arizona.edu/geisha/expression.txt

scp bhmgiapp01:/data/loads/homology/geishaload/output/MRK_Cluster.bcp /data/loads/homology/geishaload/output/MRK_Cluster.bcp.prod
scp bhmgiapp01:/data/loads/homology/geishaload/output/MRK_ClusterMember.bcp /data/loads/homology/geishaload/output/MRK_ClusterMember.bcp.prod

# hgnc
scp bhmgiapp01:/data/downloads/www.genenames.org/hgnc.tsv /data/downloads/www.genenames.org/hgnc.tsv

scp bhmgiapp01:/data/loads/homology/hgncload/output/MRK_Cluster.bcp /data/loads/homology/hgncload/output/
scp bhmgiapp01:/data/loads/homology/hgncload/output/MRK_ClusterMember.bcp /data/loads/homology/hgncload/output/

# homologene
scp bhmgiapp01:/data/downloads/homologene/homologene.data /data/downloads/homologene/homologene.data

scp bhmgiapp01:/data/loads/homology/homologeneload/output/MRK_Cluster.bcp /data/loads/homology/homologeneload/output/MRK_Cluster.bcp.prod
scp bhmgiapp01:/data/loads/homology/homologeneload/output/MRK_ClusterMember.bcp /data/loads/homology/homologeneload/output/MRK_ClusterMember.bcp.prod

# hybrid - no input file, all from db
scp bhmgiapp01:/data/loads/homology/hybridload/output/MRK_Cluster.bcp /data/loads/homology/hybridload/output/MRK_Cluster.bcp.prod
scp bhmgiapp01:/data/loads/homology/hybridload/output/MRK_ClusterMember.bcp /data/loads/homology/hybridload/output/MRK_ClusterMember.bcp.prod
scp bhmgiapp01:/data/loads/homology/hybridload/output/MGI_Property.bcp /data/loads/homology/hybridload/output/MGI_Property.bcp.prod

# xenbase
scp bhmgiapp01:/data/downloads/ftp.xenbase.org/GenePageTropicalisEntrezGeneUnigeneMapping.txt /data/downloads/ftp.xenbase.org/GenePageTropicalisEntrezGeneUnigeneMapping.txt
scp bhmgiapp01:/data/downloads/ftp.xenbase.org/XenbaseGenepageToGeneIdMapping.txt /data/downloads/ftp.xenbase.org/XenbaseGenepageToGeneIdMapping.txt
scp bhmgiapp01:/data/downloads/ftp.xenbase.org/XenbaseGeneMouseOrthologMapping.txt /data/downloads/ftp.xenbase.org/XenbaseGeneMouseOrthologMapping.txt
scp bhmgiapp01:/data/downloads/ftp.xenbase.org/GeneExpression_tropicalis.txt /data/downloads/ftp.xenbase.org/GeneExpression_tropicalis.txt

scp bhmgiapp01:/data/loads/homology/xenbaseload/output/MRK_Cluster.bcp /data/loads/homology/xenbaseload/output/MRK_Cluster.bcp.prod
scp bhmgiapp01:/data/loads/homology/xenbaseload/output/MRK_ClusterMember.bcp /data/loads/homology/xenbaseload/output/MRK_ClusterMember.bcp.prod

# zfin
scp bhmgiapp01:/data/downloads/zfin.org/downloads/gene.txt /data/downloads/zfin.org/downloads/gene.txt
scp bhmgiapp01:/data/downloads/zfin.org/downloads/mouse_orthos.txt /data/downloads/zfin.org/downloads/mouse_orthos.txt
scp bhmgiapp01:/data/downloads/zfin.org/downloads/xpat_fish.txt /data/downloads/zfin.org/downloads/xpat_fish.txt

scp bhmgiapp01:/data/loads/homology/zfinload/output/MRK_Cluster.bcp /data/loads/homology/zfinload/output/MRK_Cluster.bcp.prod
scp bhmgiapp01:/data/loads/homology/zfinload/output/MRK_ClusterMember.bcp /data/loads/homology/zfinload/output/MRK_ClusterMember.bcp.prod

#
# Lori

# goload
scp bhmgiapp01:/data/downloads/snapshot.geneontology.org/products/annotations/mgi-prediction.gaf /data/downloads/go_noctua
scp bhmgiapp01:/data/downloads/snapshot.geneontology.org/products/annotations/noctua_mgi.gpad.gz /data/downloads/go_noctua
scp bhmgiapp01:/data/downloads/snapshot.geneontology.org/products/annotations/noctua_pr.gpad.gz /data/downloads/go_noctua
scp bhmgiapp01:/data/downloads/purl.obolibrary.org/obo/pr/pr-dev.gpi /data/downloads/purl.obolibrary.org/obo/pr
scp bhmgiapp01:/data/downloads/purl.obolibrary.org/obo/uberon.obo /data/downloads/purl.obolibrary.org/obo
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
scp bhmgiapp01:/data/downloads/snapshot.geneontology.org/annotations/mgi.gaf.gz /data/downloads/snapshot.geneontology.org/annotations
scp bhmgiapp01:/data/downloads/current.geneontology.org/annotations/rgd.gaf.gz /data/downloads/current.geneontology.org/annotations

rsync -avz  bhmgiapp01:/data/loads/go/goahuman/input /data/loads/go/goahuman.prod
rsync -avz  bhmgiapp01:/data/loads/go/goahuman/output /data/loads/go/goahuman.prod
rsync -avz  bhmgiapp01:/data/loads/go/gocfp/input /data/loads/go/gocfp.prod
rsync -avz  bhmgiapp01:/data/loads/go/gocfp/output /data/loads/go/gocfp.prod
rsync -avz  bhmgiapp01:/data/loads/go/goamouse/input /data/loads/go/goamouse.prod
rsync -avz  bhmgiapp01:/data/loads/go/goamouse/output /data/loads/go/goamouse.prod
rsync -avz  bhmgiapp01:/data/loads/go/gomousenoctua/input /data/loads/go/gomousenoctua.prod
rsync -avz  bhmgiapp01:/data/loads/go/gomousenoctua/output /data/loads/go/gomousenoctua.prod
rsync -avz  bhmgiapp01:/data/loads/go/gorat/input /data/loads/go/gorat.prod
rsync -avz  bhmgiapp01:/data/loads/go/gorat/output /data/loads/go/gorat.prod
rsync -avz  bhmgiapp01:/data/loads/go/gorefgen/input /data/loads/go/gorefgen.prod
rsync -avz  bhmgiapp01:/data/loads/go/gorefgen/output /data/loads/go/gorefgen.prod

# vocload
cd /data/loads/mgi/vocload/runTimeMA
rm -rf /data/loads/mgi/vocload/runTimeMA/adult_mouse_anatomy.obo
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

# entrezgeneload/egload
scp bhmgiapp01:/data/downloads/ftp.ncbi.nih.gov/gene/DATA/gene2accession.gz /data/downloads/ftp.ncbi.nih.gov/gene/DATA
scp bhmgiapp01:/data/downloads/ftp.ncbi.nih.gov/gene/DATA/gene2pubmed.gz /data/downloads/ftp.ncbi.nih.gov/gene/DATA
scp bhmgiapp01:/data/downloads/ftp.ncbi.nih.gov/gene/DATA/gene2refseq.gz /data/downloads/ftp.ncbi.nih.gov/gene/DATA
scp bhmgiapp01:/data/downloads/ftp.ncbi.nih.gov/gene/DATA/gene_history.gz /data/downloads/ftp.ncbi.nih.gov/gene/DATA
scp bhmgiapp01:/data/downloads/ftp.ncbi.nih.gov/gene/DATA/gene_info.gz /data/downloads/ftp.ncbi.nih.gov/gene/DATA
scp bhmgiapp01:/data/downloads/ftp.ncbi.nih.gov/gene/DATA/mim2gene_medgen /data/downloads/ftp.ncbi.nih.gov/gene/DATA
scp bhmgiapp01:/data/downloads/ftp.ncbi.nih.gov/pub/HomoloGene/current/homologene.data /data/downloads/ftp.ncbi.nih.gov/pub/HomoloGene/current
scp bhmgiapp01:/data/downloads/ftp.ncbi.nih.gov/pub/HomoloGene/current/RELEASE_NUMBER /data/downloads/ftp.ncbi.nih.gov/pub/HomoloGene/current
rsync -avz  bhmgiapp01:/data/loads/entrezgene/entrezgeneload/logs /data/loads/entrezgene/entrezgeneload/logs.prod
rsync -avz  bhmgiapp01:/data/loads/entrezgene/entrezgeneload/output /data/loads/entrezgene/entrezgeneload/output.prod
rsync -avz  bhmgiapp01:/data/loads/entrezgene/egload/logs /data/loads/entrezgene/egload/logs.prod
rsync -avz  bhmgiapp01:/data/loads/entrezgene/egload/output /data/loads/entrezgene/egload/output.prod
rsync -avz  bhmgiapp01:/data/loads/entrezgene/egload/reports /data/loads/entrezgene/egload/reports.prod

# uniprotload
scp bhmgiapp01:/data/downloads/uniprot/uniprotmus.dat /data/downloads/uniprot
scp bhmgiapp01:/data/downloads/go_translation/ec2go /data/downloads/go_translation
scp bhmgiapp01:/data/downloads/go_translation/interpro2go /data/downloads/go_translation
scp bhmgiapp01:/data/downloads/go_translation/uniprotkb_kw2go /data/downloads/go_translation
scp bhmgiapp01:/data/downloads/go_translation/uniprotkb_sl2go /data/downloads/go_translation
scp bhmgiapp01:/data/downloads/ftp.ebi.ac.uk/pub/databases/interpro/names.dat /data/downloads/ftp.ebi.ac.uk/pub/databases/interpro
rsync -avz  bhmgiapp01:/data/loads/uniprot/uniprotload/logs /data/loads/uniprot/uniprotload/logs.prod
rsync -avz  bhmgiapp01:/data/loads/uniprot/uniprotload/output /data/loads/uniprot/uniprotload/output.prod
rsync -avz  bhmgiapp01:/data/loads/uniprot/uniprotload/reports /data/loads/uniprot/uniprotload/reports.prod
rsync -avz  bhmgiapp01:/data/loads/uniprot/uniprotload/uniprotload_override /data/loads/uniprot/uniprotload/uniprotload_override.prod
cp /data/loads/uniprot/uniprotload/uniprotload_override.prod/uniprotload_override/input/override.txt /data/loads/uniprot/uniprotload/uniprotload_override/input

# omim_hpoload
scp bhmgiapp01:/data/downloads/compbio.charite.de/jenkins/job/hpo.annotations.current/lastSuccessfulBuild/artifact/current/phenotype.hpoa /data/downloads/compbio.charite.de/jenkins/job/hpo.annotations.current/lastSuccessfulBuild/artifact/current
scp bhmgiapp01:/data/downloads/raw.githubusercontent.com/DiseaseOntology/HumanDiseaseOntology/master/src/ontology/doid-merged.obo /data/downloads/raw.githubusercontent.com/DiseaseOntology/HumanDiseaseOntology/master/src/ontology
scp bhmgiapp01:/data/downloads/purl.obolibrary.org/obo/hp.obo /data/downloads/purl.obolibrary.org/obo
rsync -avz  bhmgiapp01:/data/loads/omim_hpo/logs /data/loads/omim_hpo/logs.prod
rsync -avz  bhmgiapp01:/data/loads/omim_hpo/input /data/loads/omim_hpo/input.prod
rsync -avz  bhmgiapp01:/data/loads/omim_hpo/output /data/loads/omim_hpo/output.prod
rsync -avz  bhmgiapp01:/data/loads/omim_hpo/reports /data/loads/omim_hpo/reports.prod

# mp_hpoload
scp bhmgiapp01:/data/downloads/purl.obolibrary.org/obo/hp.obo /data/downloads/purl.obolibrary.org/obo
scp bhmgiapp01:/data/loads/mp_hpo/input/mp_hpo.txt /data/loads/mp_hpo/input
rsync -avz  bhmgiapp01:/data/loads/mp_hpo/input /data/loads/mp_hpo/input.prod
rsync -avz  bhmgiapp01:/data/loads/mp_hpo/logs /data/loads/mp_hpo/logs.prod
rsync -avz  bhmgiapp01:/data/loads/mp_hpo/input /data/loads/mp_hpo/input.prod
rsync -avz  bhmgiapp01:/data/loads/mp_hpo/output /data/loads/mp_hpo/output.prod
rsync -avz  bhmgiapp01:/data/loads/mp_hpo/reports /data/loads/mp_hpo/reports.prod
rm -rf /data/loads/mp_hpo/input/lastrun
