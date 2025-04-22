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

# pubmed2geneload
#scp bhmgiapp01:/data/loads/pubmed2geneload/output/MGI_Reference_Assoc.bcp ${DATALOADSOUTPUT}/pubmed2geneload/output/MGI_Reference_Assoc.bcp.prod
#scp bhmgiapp01:/data/loads/pubmed2geneload/logs/pubmed2geneload.cur.log ${DATALOADSOUTPUT}/pubmed2geneload/logs/pubmed2geneload.cur.log.prod

# homologyload

# geisha
scp bhmgiapp01:/data/downloads/geisha.arizona.edu/geisha/orthology.txt /data/downloads/geisha.arizona.edu/geisha/orthology.txt
scp bhmgiapp01:/data/downloads/geisha.arizona.edu/geisha/expression.txt /data/downloads/geisha.arizona.edu/geisha/expression.txt
#scp bhmgiapp01:/data/loads/homology/geishaload/output/MRK_Cluster.bcp ${DATALOADSOUTPUT}/homology/geishaload/output/MRK_Cluster.bcp.prod
#scp bhmgiapp01:/data/loads/homology/geishaload/output/MRK_ClusterMember.bcp ${DATALOADSOUTPUT}/homology/geishaload/output/MRK_ClusterMember.bcp.prod

# alliance clustered and direct
scp bhmgiapp01:/data/downloads/fms.alliancegenome.org/download/ORTHOLOGY-ALLIANCE_COMBINED.tsv.gz /data/downloads/fms.alliancegenome.org/download/
scp bhmgiapp01:/data/downloads/fms.alliancegenome.org/download/DISEASE-ALLIANCE_HUMAN.tsv.gz /data/downloads/fms.alliancegenome.org/download/

# xenbase
scp bhmgiapp01:/data/downloads/ftp.xenbase.org/GenePageTropicalisEntrezGeneUnigeneMapping.txt /data/downloads/ftp.xenbase.org/GenePageTropicalisEntrezGeneUnigeneMapping.txt
scp bhmgiapp01:/data/downloads/ftp.xenbase.org/XenbaseGenepageToGeneIdMapping.txt /data/downloads/ftp.xenbase.org/XenbaseGenepageToGeneIdMapping.txt
scp bhmgiapp01:/data/downloads/ftp.xenbase.org/XenbaseGeneMouseOrthologMapping.txt /data/downloads/ftp.xenbase.org/XenbaseGeneMouseOrthologMapping.txt
scp bhmgiapp01:/data/downloads/ftp.xenbase.org/GeneExpression_tropicalis.txt /data/downloads/ftp.xenbase.org/GeneExpression_tropicalis.txt
#scp bhmgiapp01:/data/loads/homology/xenbaseload/output/MRK_Cluster.bcp ${DATALOADSOUTPUT}/homology/xenbaseload/output/MRK_Cluster.bcp.prod
#scp bhmgiapp01:/data/loads/homology/xenbaseload/output/MRK_ClusterMember.bcp ${DATALOADSOUTPUT}/homology/xenbaseload/output/MRK_ClusterMember.bcp.prod

# zfin
scp bhmgiapp01:/data/downloads/zfin.org/downloads/gene.txt /data/downloads/zfin.org/downloads/gene.txt
scp bhmgiapp01:/data/downloads/zfin.org/downloads/mouse_orthos.txt /data/downloads/zfin.org/downloads/mouse_orthos.txt
scp bhmgiapp01:/data/downloads/zfin.org/downloads/xpat_fish.txt /data/downloads/zfin.org/downloads/xpat_fish.txt
#scp bhmgiapp01:/data/loads/homology/zfinload/output/MRK_Cluster.bcp ${DATALOADSOUTPUT}/homology/zfinload/output/MRK_Cluster.bcp.prod
#scp bhmgiapp01:/data/loads/homology/zfinload/output/MRK_ClusterMember.bcp ${DATALOADSOUTPUT}/homology/zfinload/output/MRK_ClusterMember.bcp.prod

# goload
scp bhmgiapp01:/data/downloads/purl.obolibrary.org/obo/pr/pr-dev.gpi /data/downloads/purl.obolibrary.org/obo/pr
scp bhmgiapp01:/data/downloads/purl.obolibrary.org/obo/uberon.obo /data/downloads/purl.obolibrary.org/obo
scp bhmgiapp01:/data/downloads/snapshot.geneontology.org/annotations/mgi.gpad.gz /data/downloads/snapshot.geneontology.org/annotations

# vocload
# Mouse Adult Anatomy
rm -rf ${DATALOADSOUTPUT}/mgi/vocload/runTimeMA/adult_mouse_anatomy.obo
scp bhmgiapp01:/data/loads/mgi/vocload/runTimeMA/adult_mouse_anatomy.obo ${DATALOADSOUTPUT}/mgi/vocload/runTimeMA
#rsync -avz bhmgiapp01:/data/loads/mgi/vocload/runTimeMA ${DATALOADSOUTPUT}/mgi/vocload/runTimeMA.prod

# Cell Ontology
scp bhmgiapp01:/data/downloads/purl.obolibrary.org/obo/cl/cl-basic.obo /data/downloads/purl.obolibrary.org/obo/cl
#rsync -avz bhmgiapp01:/data/loads/mgi/vocload/runTimeCL ${DATALOADSOUTPUT}/mgi/vocload/runTimeCL.prod

#OMIM
scp bhmgiapp01:/data/downloads/data.omim.org/omim.txt.gz /data/downloads/data.omim.org
#rsync -avz bhmgiapp01:/data/loads/mgi/vocload/OMIM ${DATALOADSOUTPUT}/mgi/vocload/OMIM.prod
scp bhmgiapp01:/data/loads/mgi/vocload/OMIM/OMIM.exclude ${DATALOADSOUTPUT}/mgi/vocload/OMIM
scp bhmgiapp01:/data/loads/mgi/vocload/OMIM/OMIM.special ${DATALOADSOUTPUT}/mgi/vocload/OMIM
scp bhmgiapp01:/data/loads/mgi/vocload/OMIM/OMIM.synonym ${DATALOADSOUTPUT}/mgi/vocload/OMIM
scp bhmgiapp01:/data/loads/mgi/vocload/OMIM/OMIM.translation ${DATALOADSOUTPUT}/mgi/vocload/OMIM

# Disease Ontology
scp bhmgiapp01:/data/downloads/raw.githubusercontent.com/DiseaseOntology/HumanDiseaseOntology/main/src/ontology/doid-merged.obo /data/downloads/raw.githubusercontent.com/DiseaseOntology/HumanDiseaseOntology/main/src/ontology
#rsync -avz bhmgiapp01:/data/loads/mgi/vocload/runTimeDO ${DATALOADSOUTPUT}/mgi/vocload/runTimeDO.prod

# Sequence Ontology
scp bhmgiapp01:/data/downloads/raw.githubusercontent.com/The-Sequence-Ontology/SO-Ontologies/master/Ontology_Files/so.obo /data/downloads/raw.githubusercontent.com/The-Sequence-Ontology/SO-Ontologies/master/Ontology_Files
#rsync -avz bhmgiapp01:/data/loads/mgi/vocload/runTimeSO ${DATALOADSOUTPUT}/mgi/vocload/runTimeSO.prod

# HPO
scp bhmgiapp01:/data/downloads/purl.obolibrary.org/obo/hp.obo /data/downloads/purl.obolibrary.org/obo
#rsync -avz bhmgiapp01:/data/loads/mgi/vocload/runTimeHPO ${DATALOADSOUTPUT}/mgi/vocload/runTimeHPO.prod

# entrezgeneload/egload
scp bhmgiapp01:/data/downloads/ftp.ncbi.nih.gov/gene/DATA/gene2accession.gz /data/downloads/ftp.ncbi.nih.gov/gene/DATA
scp bhmgiapp01:/data/downloads/ftp.ncbi.nih.gov/gene/DATA/gene2pubmed.gz /data/downloads/ftp.ncbi.nih.gov/gene/DATA
scp bhmgiapp01:/data/downloads/ftp.ncbi.nih.gov/gene/DATA/gene2refseq.gz /data/downloads/ftp.ncbi.nih.gov/gene/DATA
scp bhmgiapp01:/data/downloads/ftp.ncbi.nih.gov/gene/DATA/gene_history.gz /data/downloads/ftp.ncbi.nih.gov/gene/DATA
scp bhmgiapp01:/data/downloads/ftp.ncbi.nih.gov/gene/DATA/gene_info.gz /data/downloads/ftp.ncbi.nih.gov/gene/DATA
scp bhmgiapp01:/data/downloads/ftp.ncbi.nih.gov/gene/DATA/mim2gene_medgen /data/downloads/ftp.ncbi.nih.gov/gene/DATA
#rsync -avz bhmgiapp01:/data/loads/entrezgene/entrezgeneload/input ${DATALOADSOUTPUT}/entrezgene/entrezgeneload/input.prod
#rsync -avz bhmgiapp01:/data/loads/entrezgene/entrezgeneload/logs ${DATALOADSOUTPUT}/entrezgene/entrezgeneload/logs.prod
#rsync -avz bhmgiapp01:/data/loads/entrezgene/entrezgeneload/output ${DATALOADSOUTPUT}/entrezgene/entrezgeneload/output.prod
#rsync -avz bhmgiapp01:/data/loads/entrezgene/egload/logs ${DATALOADSOUTPUT}/entrezgene/egload/logs.prod
#rsync -avz bhmgiapp01:/data/loads/entrezgene/egload/output ${DATALOADSOUTPUT}/entrezgene/egload/output.prod
#rsync -avz bhmgiapp01:/data/loads/entrezgene/egload/reports ${DATALOADSOUTPUT}/entrezgene/egload/reports.prod

# uniprotload
scp bhmgiapp01:/data/downloads/uniprot/uniprotmus.dat /data/downloads/uniprot
scp bhmgiapp01:/data/downloads/go_translation/ec2go /data/downloads/go_translation
scp bhmgiapp01:/data/downloads/go_translation/interpro2go /data/downloads/go_translation
scp bhmgiapp01:/data/downloads/go_translation/uniprotkb_kw2go /data/downloads/go_translation
scp bhmgiapp01:/data/downloads/go_translation/uniprotkb_sl2go /data/downloads/go_translation
scp bhmgiapp01:/data/downloads/ftp.ebi.ac.uk/pub/databases/interpro/names.dat /data/downloads/ftp.ebi.ac.uk/pub/databases/interpro
#rsync -avz bhmgiapp01:/data/loads/uniprot/uniprotload/logs ${DATALOADSOUTPUT}/uniprot/uniprotload/logs.prod
#rsync -avz bhmgiapp01:/data/loads/uniprot/uniprotload/output ${DATALOADSOUTPUT}/uniprot/uniprotload/output.prod
#rsync -avz bhmgiapp01:/data/loads/uniprot/uniprotload/reports ${DATALOADSOUTPUT}/uniprot/uniprotload/reports.prod
#rsync -avz bhmgiapp01:/data/loads/uniprot/uniprotload/uniprotload_override ${DATALOADSOUTPUT}/uniprot/uniprotload/uniprotload_override.prod
scp bhmgiapp01:/data/loads/uniprot/uniprotload/uniprotload_override/input/override.txt ${DATALOADSOUTPUT}/uniprot/uniprotload/uniprotload_override/input

# pirsfload
scp bhmgiapp01:/data/downloads/www.uniprot.org/pirsfload/m_musculus.xml /data/downloads/www.uniprot.org/pirsfload/
#rsync -avz bhmgiapp01:/data/loads/pirsf/pirsfload/output ${DATALOADSOUTPUT}/pirsf/pirsfload/output.prod
#rsync -avz bhmgiapp01:/data/loads/pirsf/pirsfload/reports ${DATALOADSOUTPUT}/pirsf/pirsfload/reports.prod

# ccdsload
scp bhmgiapp01:/data/downloads/ccds_mus/CCDS.current.txt /data/downloads/ccds_mus
#rsync -avz bhmgiapp01:/data/loads/ccds/ccdsload/input ${DATALOADSOUTPUT}/ccds/ccdsload/input.prod
#rsync -avz bhmgiapp01:/data/loads/ccds/ccdsload/output ${DATALOADSOUTPUT}/ccds/ccdsload/output.prod
#rsync -avz bhmgiapp01:/data/loads/ccds/ccdsload/reports ${DATALOADSOUTPUT}/ccds/ccdsload/reports.prod

# seqcacheload
#rsync -avz bhmgiapp01:/data/loads/mgi/seqcacheload/output ${DATALOADSOUTPUT}/mgi/seqcacheload/output.prod

# mrkcacheload
#rsync -avz bhmgiapp01:/data/loads/mgi/mrkcacheload/output ${DATALOADSOUTPUT}/mgi/mrkcacheload/output.prod

# omim_hpoload
scp bhmgiapp01:/data/downloads/purl.obolibrary.org/obo/hp/hpoa/phenotype.hpoa /data/downloads/purl.obolibrary.org/obo/hp/hpoa/
scp bhmgiapp01:/data/downloads/purl.obolibrary.org/obo/hp.obo /data/downloads/purl.obolibrary.org/obo
#rsync -avz bhmgiapp01:/data/loads/omim_hpo/logs ${DATALOADSOUTPUT}/omim_hpo/logs.prod
#rsync -avz bhmgiapp01:/data/loads/omim_hpo/input ${DATALOADSOUTPUT}/omim_hpo/input.prod
#rsync -avz bhmgiapp01:/data/loads/omim_hpo/output ${DATALOADSOUTPUT}/omim_hpo/output.prod
#rsync -avz bhmgiapp01:/data/loads/omim_hpo/reports ${DATALOADSOUTPUT}/omim_hpo/reports.prod

# mp_hpoload
scp bhmgiapp01:/data/downloads/purl.obolibrary.org/obo/hp.obo /data/downloads/purl.obolibrary.org/obo
scp bhmgiapp01:/data/loads/mp_hpo/input/mp_hpo.txt ${DATALOADSOUTPUT}/mp_hpo/input
#rsync -avz bhmgiapp01:/data/loads/mp_hpo/input ${DATALOADSOUTPUT}/mp_hpo/input.prod
#rsync -avz bhmgiapp01:/data/loads/mp_hpo/logs ${DATALOADSOUTPUT}/mp_hpo/logs.prod
#rsync -avz bhmgiapp01:/data/loads/mp_hpo/input ${DATALOADSOUTPUT}/mp_hpo/input.prod
#rsync -avz bhmgiapp01:/data/loads/mp_hpo/output ${DATALOADSOUTPUT}/mp_hpo/output.prod
#rsync -avz bhmgiapp01:/data/loads/mp_hpo/reports ${DATALOADSOUTPUT}/mp_hpo/reports.prod

