#!/bin/sh

if [ "${MGICONFIG}" = "" ]
then
    MGICONFIG=/usr/local/mgi/live/mgiconfig
    export MGICONFIG
fi

. ${MGICONFIG}/master.config.sh

# pubmed2geneload
scp bhmgiapp01:/data/loads/pubmed2geneload/output/MGI_Reference_Assoc.bcp ${DATALOADSOUTPUT}/pubmed2geneload/output/MGI_Reference_Assoc.bcp.prod
scp bhmgiapp01:/data/loads/pubmed2geneload/logs/pubmed2geneload.cur.log ${DATALOADSOUTPUT}/pubmed2geneload/logs/pubmed2geneload.cur.log.prod

# homologyload
scp bhmgiapp01:/data/downloads/homologene/RELEASE_NUMBER /data/downloads/homologene/

# geisha
scp bhmgiapp01:/data/downloads/geisha.arizona.edu/geisha/orthology.txt /data/downloads/geisha.arizona.edu/geisha/orthology.txt
scp bhmgiapp01:/data/downloads/geisha.arizona.edu/geisha/expression.txt /data/downloads/geisha.arizona.edu/geisha/expression.txt
scp bhmgiapp01:/data/loads/homology/geishaload/output/MRK_Cluster.bcp ${DATALOADSOUTPUT}/homology/geishaload/output/MRK_Cluster.bcp.prod
scp bhmgiapp01:/data/loads/homology/geishaload/output/MRK_ClusterMember.bcp ${DATALOADSOUTPUT}/homology/geishaload/output/MRK_ClusterMember.bcp.prod

# hgnc
scp bhmgiapp01:/data/downloads/www.genenames.org/hgnc.tsv /data/downloads/www.genenames.org/hgnc.tsv
scp bhmgiapp01:/data/loads/homology/hgncload/output/MRK_Cluster.bcp ${DATALOADSOUTPUT}/homology/hgncload/output/MRK_Cluster.bcp.prod
scp bhmgiapp01:/data/loads/homology/hgncload/output/MRK_ClusterMember.bcp ${DATALOADSOUTPUT}/homology/hgncload/output/MRK_ClusterMember.bcp.prod
scp bhmgiapp01:/data/loads/homology/hgncload/output/hgnc_load.txt ${DATALOADSOUTPUT}/homology/hgncload/output/hgnc_load.txt.prod
scp bhmgiapp01:/data/loads/homology/hgncload/output/hgnc_tocluster.txt ${DATALOADSOUTPUT}/homology/hgncload/output/hgnc_tocluster.txt.prod

# homologene
scp bhmgiapp01:/data/downloads/homologene/RELEASE_NUMBER /data/downloads/homologene/
scp bhmgiapp01:/data/downloads/homologene/homologene.data /data/downloads/homologene/homologene.data
scp bhmgiapp01:/data/loads/homology/homologeneload/output/MRK_Cluster.bcp ${DATALOADSOUTPUT}/homology/homologeneload/output/MRK_Cluster.bcp.prod
scp bhmgiapp01:/data/loads/homology/homologeneload/output/MRK_ClusterMember.bcp ${DATALOADSOUTPUT}/homology/homologeneload/output/MRK_ClusterMember.bcp.prod
scp bhmgiapp01:/data/loads/homology/homologeneload/output/ACC_Accession.bcp ${DATALOADSOUTPUT}/homology/homologeneload/output/ACC_Accession.bcp.prod
scp bhmgiapp01:/data/loads/homology/homologeneload/output/homologeneload_load.txt ${DATALOADSOUTPUT}/homology/homologeneload/output/homologeneload_load.txt.prod

# hybrid - no input file, all from db
scp bhmgiapp01:/data/loads/homology/hybridload/output/MRK_Cluster.bcp ${DATALOADSOUTPUT}/homology/hybridload/output/MRK_Cluster.bcp.prod
scp bhmgiapp01:/data/loads/homology/hybridload/output/MRK_ClusterMember.bcp ${DATALOADSOUTPUT}/homology/hybridload/output/MRK_ClusterMember.bcp.prod
scp bhmgiapp01:/data/loads/homology/hybridload/output/MGI_Property.bcp ${DATALOADSOUTPUT}/homology/hybridload/output/MGI_Property.bcp.prod
scp bhmgiapp01:/data/loads/homology/hybridload/output/hybrid_load.txt ${DATALOADSOUTPUT}/homology/hybridload/output/hybrid_load.txt.prod

# xenbase
scp bhmgiapp01:/data/downloads/ftp.xenbase.org/GenePageTropicalisEntrezGeneUnigeneMapping.txt /data/downloads/ftp.xenbase.org/GenePageTropicalisEntrezGeneUnigeneMapping.txt
scp bhmgiapp01:/data/downloads/ftp.xenbase.org/XenbaseGenepageToGeneIdMapping.txt /data/downloads/ftp.xenbase.org/XenbaseGenepageToGeneIdMapping.txt
scp bhmgiapp01:/data/downloads/ftp.xenbase.org/XenbaseGeneMouseOrthologMapping.txt /data/downloads/ftp.xenbase.org/XenbaseGeneMouseOrthologMapping.txt
scp bhmgiapp01:/data/downloads/ftp.xenbase.org/GeneExpression_tropicalis.txt /data/downloads/ftp.xenbase.org/GeneExpression_tropicalis.txt
scp bhmgiapp01:/data/loads/homology/xenbaseload/output/MRK_Cluster.bcp ${DATALOADSOUTPUT}/homology/xenbaseload/output/MRK_Cluster.bcp.prod
scp bhmgiapp01:/data/loads/homology/xenbaseload/output/MRK_ClusterMember.bcp ${DATALOADSOUTPUT}/homology/xenbaseload/output/MRK_ClusterMember.bcp.prod

# zfin
scp bhmgiapp01:/data/downloads/zfin.org/downloads/gene.txt /data/downloads/zfin.org/downloads/gene.txt
scp bhmgiapp01:/data/downloads/zfin.org/downloads/mouse_orthos.txt /data/downloads/zfin.org/downloads/mouse_orthos.txt
scp bhmgiapp01:/data/downloads/zfin.org/downloads/xpat_fish.txt /data/downloads/zfin.org/downloads/xpat_fish.txt
scp bhmgiapp01:/data/loads/homology/zfinload/output/MRK_Cluster.bcp ${DATALOADSOUTPUT}/homology/zfinload/output/MRK_Cluster.bcp.prod
scp bhmgiapp01:/data/loads/homology/zfinload/output/MRK_ClusterMember.bcp ${DATALOADSOUTPUT}/homology/zfinload/output/MRK_ClusterMember.bcp.prod

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

rsync -avz bhmgiapp01:/data/loads/go/goahuman/input ${DATALOADSOUTPUT}/go/goahuman/input.prod
rsync -avz bhmgiapp01:/data/loads/go/goahuman/output ${DATALOADSOUTPUT}/go/goahuman/output.prod
rsync -avz bhmgiapp01:/data/loads/go/gocfp/input ${DATALOADSOUTPUT}/go/gocfp/input.prod
rsync -avz bhmgiapp01:/data/loads/go/gocfp/output ${DATALOADSOUTPUT}/go/gocfp/output.prod
rsync -avz bhmgiapp01:/data/loads/go/goamouse/input ${DATALOADSOUTPUT}/go/goamouse/input.prod
rsync -avz bhmgiapp01:/data/loads/go/goamouse/output ${DATALOADSOUTPUT}/go/goamouse/output.prod
rsync -avz bhmgiapp01:/data/loads/go/gomousenoctua/input ${DATALOADSOUTPUT}/go/gomousenoctua/input.prod
rsync -avz bhmgiapp01:/data/loads/go/gomousenoctua/output ${DATALOADSOUTPUT}/go/gomousenoctua/output.prod
rsync -avz bhmgiapp01:/data/loads/go/gorat/input ${DATALOADSOUTPUT}/go/gorat/input.prod
rsync -avz bhmgiapp01:/data/loads/go/gorat/output ${DATALOADSOUTPUT}/go/gorat/output.prod
rsync -avz bhmgiapp01:/data/loads/go/gorefgen/input ${DATALOADSOUTPUT}/go/gorefgen/input.prod
rsync -avz bhmgiapp01:/data/loads/go/gorefgen/output ${DATALOADSOUTPUT}/go/gorefgen/output.prod

# vocload
rm -rf ${DATALOADSOUTPUT}/mgi/vocload/runTimeMA/adult_mouse_anatomy.obo
scp bhmgiapp01:/data/loads/mgi/vocload/runTimeMA/adult_mouse_anatomy.obo ${DATALOADSOUTPUT}/mgi/vocload/runTimeMA
rsync -avz bhmgiapp01:/data/loads/mgi/vocload/runTimeMA ${DATALOADSOUTPUT}/mgi/vocload/runTimeMA.prod

scp bhmgiapp01:/data/downloads/purl.obolibrary.org/obo/cl/cl-basic.obo /data/downloads/purl.obolibrary.org/obo/cl
rsync -avz bhmgiapp01:/data/loads/mgi/vocload/runTimeCL ${DATALOADSOUTPUT}/mgi/vocload/runTimeCL.prod

scp bhmgiapp01:/data/downloads/data.omim.org/omim.txt.gz /data/downloads/data.omim.org
rsync -avz bhmgiapp01:/data/loads/mgi/vocload/OMIM ${DATALOADSOUTPUT}/mgi/vocload/OMIM.prod
#scp bhmgiapp01:/data/loads/mgi/vocload/OMIM/OMIM.exclude ${DATALOADSOUTPUT}/mgi/vocload/OMIM
scp bhmgiapp01:/data/loads/mgi/vocload/OMIM/OMIM.special ${DATALOADSOUTPUT}/mgi/vocload/OMIM
scp bhmgiapp01:/data/loads/mgi/vocload/OMIM/OMIM.synonym ${DATALOADSOUTPUT}/mgi/vocload/OMIM
scp bhmgiapp01:/data/loads/mgi/vocload/OMIM/OMIM.translation ${DATALOADSOUTPUT}/mgi/vocload/OMIM

scp bhmgiapp01:/data/downloads/raw.githubusercontent.com/DiseaseOntology/HumanDiseaseOntology/master/src/ontology/doid-merged.obo /data/downloads/raw.githubusercontent.com/DiseaseOntology/HumanDiseaseOntology/master/src/ontology
rsync -avz bhmgiapp01:/data/loads/mgi/vocload/runTimeDO ${DATALOADSOUTPUT}/mgi/vocload/runTimeDO.prod

scp bhmgiapp01:/data/downloads/raw.githubusercontent.com/The-Sequence-Ontology/SO-Ontologies/master/so.obo /data/downloads/raw.githubusercontent.com/The-Sequence-Ontology/SO-Ontologies/master
rsync -avz bhmgiapp01:/data/loads/mgi/vocload/runTimeSO ${DATALOADSOUTPUT}/mgi/vocload/runTimeSO.prod

scp bhmgiapp01:/data/downloads/purl.obolibrary.org/obo/hp.obo /data/downloads/purl.obolibrary.org/obo
rsync -avz bhmgiapp01:/data/loads/mgi/vocload/runTimeHPO ${DATALOADSOUTPUT}/mgi/vocload/runTimeHPO.prod

# entrezgeneload/egload
scp bhmgiapp01:/data/downloads/ftp.ncbi.nih.gov/gene/DATA/gene2accession.gz /data/downloads/ftp.ncbi.nih.gov/gene/DATA
scp bhmgiapp01:/data/downloads/ftp.ncbi.nih.gov/gene/DATA/gene2pubmed.gz /data/downloads/ftp.ncbi.nih.gov/gene/DATA
scp bhmgiapp01:/data/downloads/ftp.ncbi.nih.gov/gene/DATA/gene2refseq.gz /data/downloads/ftp.ncbi.nih.gov/gene/DATA
scp bhmgiapp01:/data/downloads/ftp.ncbi.nih.gov/gene/DATA/gene_history.gz /data/downloads/ftp.ncbi.nih.gov/gene/DATA
scp bhmgiapp01:/data/downloads/ftp.ncbi.nih.gov/gene/DATA/gene_info.gz /data/downloads/ftp.ncbi.nih.gov/gene/DATA
scp bhmgiapp01:/data/downloads/ftp.ncbi.nih.gov/gene/DATA/mim2gene_medgen /data/downloads/ftp.ncbi.nih.gov/gene/DATA
scp bhmgiapp01:/data/downloads/ftp.ncbi.nih.gov/pub/HomoloGene/current/homologene.data /data/downloads/ftp.ncbi.nih.gov/pub/HomoloGene/current
scp bhmgiapp01:/data/downloads/ftp.ncbi.nih.gov/pub/HomoloGene/current/RELEASE_NUMBER /data/downloads/ftp.ncbi.nih.gov/pub/HomoloGene/current
rsync -avz bhmgiapp01:/data/loads/entrezgene/entrezgeneload/input ${DATALOADSOUTPUT}/entrezgene/entrezgeneload/input.prod
rsync -avz bhmgiapp01:/data/loads/entrezgene/entrezgeneload/logs ${DATALOADSOUTPUT}/entrezgene/entrezgeneload/logs.prod
rsync -avz bhmgiapp01:/data/loads/entrezgene/entrezgeneload/output ${DATALOADSOUTPUT}/entrezgene/entrezgeneload/output.prod
rsync -avz bhmgiapp01:/data/loads/entrezgene/egload/logs ${DATALOADSOUTPUT}/entrezgene/egload/logs.prod
rsync -avz bhmgiapp01:/data/loads/entrezgene/egload/output ${DATALOADSOUTPUT}/entrezgene/egload/output.prod
rsync -avz bhmgiapp01:/data/loads/entrezgene/egload/reports ${DATALOADSOUTPUT}/entrezgene/egload/reports.prod

# uniprotload
scp bhmgiapp01:/data/downloads/uniprot/uniprotmus.dat /data/downloads/uniprot
scp bhmgiapp01:/data/downloads/go_translation/ec2go /data/downloads/go_translation
scp bhmgiapp01:/data/downloads/go_translation/interpro2go /data/downloads/go_translation
scp bhmgiapp01:/data/downloads/go_translation/uniprotkb_kw2go /data/downloads/go_translation
scp bhmgiapp01:/data/downloads/go_translation/uniprotkb_sl2go /data/downloads/go_translation
scp bhmgiapp01:/data/downloads/ftp.ebi.ac.uk/pub/databases/interpro/names.dat /data/downloads/ftp.ebi.ac.uk/pub/databases/interpro
rsync -avz bhmgiapp01:/data/loads/uniprot/uniprotload/logs ${DATALOADSOUTPUT}/uniprot/uniprotload/logs.prod
rsync -avz bhmgiapp01:/data/loads/uniprot/uniprotload/output ${DATALOADSOUTPUT}/uniprot/uniprotload/output.prod
rsync -avz bhmgiapp01:/data/loads/uniprot/uniprotload/reports ${DATALOADSOUTPUT}/uniprot/uniprotload/reports.prod
rsync -avz bhmgiapp01:/data/loads/uniprot/uniprotload/uniprotload_override ${DATALOADSOUTPUT}/uniprot/uniprotload/uniprotload_override.prod
cp /data/loads/uniprot/uniprotload/uniprotload_override.prod/uniprotload_override/input/override.txt ${DATALOADSOUTPUT}/uniprot/uniprotload/uniprotload_override/input

# omim_hpoload
scp bhmgiapp01:/data/downloads/compbio.charite.de/jenkins/job/hpo.annotations.current/lastSuccessfulBuild/artifact/current/phenotype.hpoa /data/downloads/compbio.charite.de/jenkins/job/hpo.annotations.current/lastSuccessfulBuild/artifact/current
scp bhmgiapp01:/data/downloads/raw.githubusercontent.com/DiseaseOntology/HumanDiseaseOntology/master/src/ontology/doid-merged.obo /data/downloads/raw.githubusercontent.com/DiseaseOntology/HumanDiseaseOntology/master/src/ontology
scp bhmgiapp01:/data/downloads/purl.obolibrary.org/obo/hp.obo /data/downloads/purl.obolibrary.org/obo
rsync -avz bhmgiapp01:/data/loads/omim_hpo/logs ${DATALOADSOUTPUT}/omim_hpo/logs.prod
rsync -avz bhmgiapp01:/data/loads/omim_hpo/input ${DATALOADSOUTPUT}/omim_hpo/input.prod
rsync -avz bhmgiapp01:/data/loads/omim_hpo/output ${DATALOADSOUTPUT}/omim_hpo/output.prod
rsync -avz bhmgiapp01:/data/loads/omim_hpo/reports ${DATALOADSOUTPUT}/omim_hpo/reports.prod

# mp_hpoload
scp bhmgiapp01:/data/downloads/purl.obolibrary.org/obo/hp.obo /data/downloads/purl.obolibrary.org/obo
scp bhmgiapp01:/data/loads/mp_hpo/input/mp_hpo.txt ${DATALOADSOUTPUT}/mp_hpo/input
rsync -avz bhmgiapp01:/data/loads/mp_hpo/input ${DATALOADSOUTPUT}/mp_hpo/input.prod
rsync -avz bhmgiapp01:/data/loads/mp_hpo/logs ${DATALOADSOUTPUT}/mp_hpo/logs.prod
rsync -avz bhmgiapp01:/data/loads/mp_hpo/input ${DATALOADSOUTPUT}/mp_hpo/input.prod
rsync -avz bhmgiapp01:/data/loads/mp_hpo/output ${DATALOADSOUTPUT}/mp_hpo/output.prod
rsync -avz bhmgiapp01:/data/loads/mp_hpo/reports ${DATALOADSOUTPUT}/mp_hpo/reports.prod
rm -rf ${DATALOADSOUTPUT}/mp_hpo/input/lastrun

# pirsfload
scp bhmgiapp01:/data/downloads/ftp.pir.georgetown.edu/databases/iproclass/more_xml_files/m_musculus.xml.gz /data/downloads/ftp.pir.georgetown.edu/databases/iproclass/more_xml_files
rsync -avz bhmgiapp01:/data/loads/pirsf/pirsfload/output ${DATALOADSOUTPUT}/pirsf/pirsfload/output.prod
rsync -avz bhmgiapp01:/data/loads/pirsf/pirsfload/reports ${DATALOADSOUTPUT}/pirsf/pirsfload/reports.prod

