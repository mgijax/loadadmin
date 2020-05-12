#!/bin/sh

if [ "${MGICONFIG}" = "" ]
then
    MGICONFIG=/usr/local/mgi/live/mgiconfig
    export MGICONFIG
fi

. ${MGICONFIG}/master.config.sh

# remove lastrun
rm -rf ${DATALOADSOUTPUT}/mgi/fearload/input/lastrun
rm -rf ${DATALOADSOUTPUT}/mgi/htmpload/impcmpload/input/lastrun
rm -rf ${DATALOADSOUTPUT}/mgi/strainmarkerload/output/lastrun
rm -rf ${DATALOADSOUTPUT}/mgi/slimtermload/emapslimload/input/lastrun
rm -rf ${DATALOADSOUTPUT}/mgi/slimtermload/goslimload/input/lastrun
rm -rf ${DATALOADSOUTPUT}/mgi/slimtermload/mpslimload/input/lastrun
rm -rf ${DATALOADSOUTPUT}/pro/proload/input/lastrun
rm -rf ${DATALOADSOUTPUT}/mgi/rvload/input/lastrun
rm -rf ${DATALOADSOUTPUT}/swissprot/spseqload/input/lastrun
rm -rf ${DATALOADSOUTPUT}/swissprot/trseqload/input/lastrun

# geoload
rsync -avz bhmgiapp01:/data/loads/geo/geoload/input ${DATALOADSOUTPUT}/geo/geoload/input.prod
rsync -avz bhmgiapp01:/data/loads/geo/geoload/output ${DATALOADSOUTPUT}/geo/geoload/output.prod
rsync -avz bhmgiapp01:/data/loads/geo/geoload/reports ${DATALOADSOUTPUT}/geo/geoload/reports.prod

# proload
scp bhmgiapp01:/data/downloads/proconsortium.org/download/more/mgi/PRO_mgi.txt /data/downloads/proconsortium.org/download/more/mgi/
rsync -avz bhmgiapp01:/data/loads/pro/proload/input ${DATALOADSOUTPUT}/pro/proload/input.prod
rsync -avz bhmgiapp01:/data/loads/pro/proload/output ${DATALOADSOUTPUT}/pro/proload/output.prod

# rvload
rsync -avz bhmgiapp01:/data/loads/mgi/rvload/input ${DATALOADSOUTPUT}/mgi/rvload/input.prod
rsync -avz bhmgiapp01:/data/loads/mgi/rvload/output ${DATALOADSOUTPUT}/mgi/rvload/output.prod

# fearload  - this file should  load 22 relationships
scp bhmgiap09lt:/data/fear/current/cluster_has_member/cluster_20190731.txt ${DATALOADSOUTPUT}/mgi/fearload/input/fearload.txt

# slimtermload
scp bhmgiapp01:/data/loads/mgi/slimtermload/emapslimload/input/emapslimload.txt ${DATALOADSOUTPUT}/mgi/slimtermload/emapslimload/input
rsync -avz bhmgiapp01:/data/loads/mgi/slimtermload/emapslimload/input ${DATALOADSOUTPUT}/mgi/slimtermload/emapslimload/input.prod
rsync -avz bhmgiapp01:/data/loads/mgi/slimtermload/emapslimload/output ${DATALOADSOUTPUT}/mgi/slimtermload/emapslimload/output.prod
scp bhmgiapp01:/data/loads/mgi/slimtermload/goslimload/input/goslimload.txt ${DATALOADSOUTPUT}/mgi/slimtermload/goslimload/input
rsync -avz bhmgiapp01:/data/loads/mgi/slimtermload/goslimload/input ${DATALOADSOUTPUT}/mgi/slimtermload/goslimload/input.prod
rsync -avz bhmgiapp01:/data/loads/mgi/slimtermload/goslimload/output ${DATALOADSOUTPUT}/mgi/slimtermload/goslimload/output.prod
scp bhmgiapp01:/data/loads/mgi/slimtermload/mpslimload/input/mpslimload.txt ${DATALOADSOUTPUT}/mgi/slimtermload/mpslimload/input
rsync -avz bhmgiapp01:/data/loads/mgi/slimtermload/mpslimload/input ${DATALOADSOUTPUT}/mgi/slimtermload/mpslimload/input.prod
rsync -avz bhmgiapp01:/data/loads/mgi/slimtermload/mpslimload/output ${DATALOADSOUTPUT}/mgi/slimtermload/mpslimload/output.prod

# targetedalleleload
scp bhmgiapp01:/data/downloads/www.mousephenotype.org/mgi_es_cell_allele_report.tsv /data/downloads/www.mousephenotype.org
scp bhmgiapp01:/data/downloads/www.mousephenotype.org/mgi_es_cell_allele_report.tsv /data/downloads/www.mousephenotype.org
scp bhmgiapp01:/data/downloads/www.mousephenotype.org/mgi_es_cell_allele_report.tsv /data/downloads/www.mousephenotype.org
scp bhmgiapp01:/data/downloads/www.mousephenotype.org/mgi_es_cell_allele_report.tsv /data/downloads/www.mousephenotype.org
scp bhmgiapp01:/data/loads/targetedallele/duplicatedAllele.rpt ${DATALOADSOUTPUT}/targetedallele/duplicatedAllele.rpt.prod
rsync -avz bhmgiapp01:/data/loads/targetedallele/input ${DATALOADSOUTPUT}/targetedallele/input.prod
rsync -avz bhmgiapp01:/data/loads/targetedallele/csd_load_mbp/output ${DATALOADSOUTPUT}/targetedallele/csd_load_mbp/output.prod
rsync -avz bhmgiapp01:/data/loads/targetedallele/csd_load_mbp/reports ${DATALOADSOUTPUT}/targetedallele/csd_load_mbp/reports.prod
rsync -avz bhmgiapp01:/data/loads/targetedallele/csd_load_wtsi/output ${DATALOADSOUTPUT}/targetedallele/csd_load_wtsi/output.prod
rsync -avz bhmgiapp01:/data/loads/targetedallele/csd_load_wtsi/reports ${DATALOADSOUTPUT}/targetedallele/csd_load_wtsi/reports.prod
rsync -avz bhmgiapp01:/data/loads/targetedallele/eucomm_load_hmgu/output ${DATALOADSOUTPUT}/targetedallele/eucomm_load_hmgu/output.prod
rsync -avz bhmgiapp01:/data/loads/targetedallele/eucomm_load_hmgu/reports ${DATALOADSOUTPUT}/targetedallele/eucomm_load_hmgu/reports.prod
rsync -avz bhmgiapp01:/data/loads/targetedallele/eucomm_load_wtsi/output ${DATALOADSOUTPUT}/targetedallele/eucomm_load_wtsi/output.prod
rsync -avz bhmgiapp01:/data/loads/targetedallele/eucomm_load_wtsi/reports ${DATALOADSOUTPUT}/targetedallele/eucomm_load_wtsi/reports.prod

# alleleload
scp bhmgiapp01:/data/downloads/www.mousephenotype.org/mgi_modification_allele_report.tsv /data/downloads/www.mousephenotype.org
rsync -avz bhmgiapp01:/data/loads/mgi/alleleload/ikmc/input ${DATALOADSOUTPUT}/mgi/alleleload/ikmc/input.prod
rsync -avz bhmgiapp01:/data/loads/mgi/alleleload/ikmc/output ${DATALOADSOUTPUT}/mgi/alleleload/ikmc/output.prod

# htmpload
scp bhmgiapp01:/data/downloads/www.ebi.ac.uk/impc.json /data/downloads/www.ebi.ac.uk/impc.json
scp bhmgiapp01:/data/downloads/www.mousephenotype.org/mp2_load_phenotyping_colonies_report.tsv /data/downloads/www.mousephenotype.org/mp2_load_phenotyping_colonies_report.tsv
rsync -avz bhmgiapp01:/data/loads/mgi/htmpload/impcmpload/output ${DATALOADSOUTPUT}/mgi/htmpload/impcmpload/output.prod
rsync -avz bhmgiapp01:/data/loads/mgi/htmpload/impcmpload/logs ${DATALOADSOUTPUT}/mgi/htmpload/impcmpload/logs.prod

# mp_emapaload
scp bhmgiapp01:/data/downloads/purl.obolibrary.org/obo/uberon.obo /data/downloads/purl.obolibrary.org/obo
scp bhmgiapp01:/data/loads/mgi/vocload/runTimeMP/mp.owl ${DATALOADSOUTPUT}/mgi/vocload/runTimeMP
scp bhmgiapp01:/data/loads/mgi/vocload/emap/input/EMAPA.obo ${DATALOADSOUTPUT}/mgi/vocload/emap/input
rsync -avz bhmgiapp01:/data/loads/mp_emapaload/input ${DATALOADSOUTPUT}/mp_emapaload/input.prod
rsync -avz bhmgiapp01:/data/loads/mp_emapaload/output ${DATALOADSOUTPUT}/mp_emapaload/output.prod
rsync -avz bhmgiapp01:/data/loads/mp_emapaload/reports ${DATALOADSOUTPUT}/mp_emapaload/reports.prod

# gxdhtload
scp bhmgiapp01:/data/downloads/www.ebi.ac.uk/arrayexpress.json /data/downloads/www.ebi.ac.uk
rsync -avz bhmgiapp01:/data/loads/mgi/gxdhtload/input ${DATALOADSOUTPUT}/mgi/gxdhtload/input.prod
rsync -avz bhmgiapp01:/data/loads/mgi/gxdhtload/output ${DATALOADSOUTPUT}/mgi/gxdhtload/output.prod
rsync -avz bhmgiapp01:/data/loads/mgi/gxdhtload/reports ${DATALOADSOUTPUT}/mgi/gxdhtload/reports.prod

# genemodelload
scp bhmgiapp01:/data/genemodels/current/models/ensembl_genemodels.txt /data/genemodels/current/models
rsync -avz bhmgiapp01:/data/loads/mgi/genemodelload/input ${DATALOADSOUTPUT}/mgi/genemodelload/input.prod
rsync -avz bhmgiapp01:/data/loads/mgi/genemodelload/output ${DATALOADSOUTPUT}/mgi/genemodelload/output.prod
rsync -avz bhmgiapp01:/data/genemodels/current/models /data/genemodels/current/models.prod

# emalload
scp bhmgiapp01:/data/downloads/www.mousephenotype.org/mgi_crispr_allele_report.tsv /data/downloads/www.mousephenotype.org
rsync -avz bhmgiapp01:/data/loads/mgi/emalload/impc/input ${DATALOADSOUTPUT}/mgi/emalload/impc/input.prod
rsync -avz bhmgiapp01:/data/loads/mgi/emalload/impc/output ${DATALOADSOUTPUT}/mgi/emalload/impc/output.prod
rsync -avz bhmgiapp01:/data/loads/mgi/emalload/impc/reports ${DATALOADSOUTPUT}/mgi/emalload/impc/reports.prod

# straingenemodelload
# input is database and mgigff - see strainmarkerload above
rsync -avz bhmgiapp01:/data/loads/mgi/straingenemodelload/input ${DATALOADSOUTPUT}/mgi/straingenemodelload/input.prod
rsync -avz bhmgiapp01:/data/loads/mgi/straingenemodelload/output ${DATALOADSOUTPUT}/mgi/straingenemodelload/output.prod
rsync -avz bhmgiapp01:/data/loads/mgi/straingenemodelload/logs ${DATALOADSOUTPUT}/mgi/straingenemodelload/logs.prod

# rnaseqload
rsync -avz bhmgiapp01:/data/loads/mgi/rnaseqload/raw_input ${DATALOADSOUTPUT}/mgi/rnaseqload

# rollupload
rsync -avz  bhmgiapp01:/data/loads/rollupload/input ${DATALOADSOUTPUT}/rollupload/input.prod
rsync -avz  bhmgiapp01:/data/loads/rollupload/output ${DATALOADSOUTPUT}/rollupload/output.prod

# seqcacheload
rsync -avz  bhmgiapp01:/data/loads/mgi/seqcacheload/input ${DATALOADSOUTPUT}/mgi/seqcacheload/input.prod
rsync -avz  bhmgiapp01:/data/loads/mgi/mrkcacheload/output ${DATALOADSOUTPUT}/mgi/mrkcacheload/output.prod

# mrkcacheload
rsync -avz  bhmgiapp01:/data/loads/mgi/mrkcacheload/input ${DATALOADSOUTPUT}/mgi/mrkcacheload/input.prod
rsync -avz  bhmgiapp01:/data/loads/mgi/mrkcacheload/output ${DATALOADSOUTPUT}/mgi/mrkcacheload/output.prod

# alomrkload
rsync -avz  bhmgiapp01:/data/loads/mgi/alomrkload/input ${DATALOADSOUTPUT}/mgi/alomrkload/input.prod
rsync -avz  bhmgiapp01:/data/loads/mgi/alomrkload/output ${DATALOADSOUTPUT}/mgi/alomrkload/output.prod

# allcacheload
rsync -avz  bhmgiapp01:/data/loads/mgi/allcacheload/input ${DATALOADSOUTPUT}/mgi/allcacheload/input.prod
rsync -avz  bhmgiapp01:/data/loads/mgi/allcacheload/output ${DATALOADSOUTPUT}/mgi/allcacheload/output.prod

# strainmarkerload
# mgigff3 file is copied by the load
scp bhmgiapp01:/export/gondor/ftp/pub/mgigff3/MGI.gff3.gz ${DATALOADSOUTPUT}/mgi/strainmarkerload/input
rsync -avz bhmgiapp01:/data/downloads/ftp.ensembl.org/pub/release-92/gff3 /data/downloads/ftp.ensembl.org/pub/release-92/
rsync -avz bhmgiapp01:/data/loads/mgi/strainmarkerload/input ${DATALOADSOUTPUT}/mgi/strainmarkerload/input.prod
rsync -avz bhmgiapp01:/data/loads/mgi/strainmarkerload/output ${DATALOADSOUTPUT}/mgi/strainmarkerload/output.prod
rsync -avz bhmgiapp01:/data/loads/mgi/strainmarkerload/logs ${DATALOADSOUTPUT}/mgi/strainmarkerload/logs.prod

# assembly stuff
rsync -avz bhmgiapp01:/data/loads/assembly/b6seqload/output ${DATALOADSOUTPUT}/assembly/b6seqload/output.prod
rsync -avz bhmgiapp01:/data/loads/assembly/b6seqload/logs ${DATALOADSOUTPUT}/assembly/b6seqload/logs.prod

# assemblyseqload/ensemblseqload/seqseqassocload
rsync -avz bhmgiapp01:/data/loads/assembly/ensemblseqload/reports ${DATALOADSOUTPUT}/assembly/ensemblseqload/reports.prod
rsync -avz bhmgiapp01:/data/loads/mgi/genemodelload/input ${DATALOADSOUTPUT}/mgi/genemodelload/input.prod
rsync -avz bhmgiapp01:/data/loads/ensembl/ensembl_transcriptassocload/reports ${DATALOADSOUTPUT}/ensembl/ensembl_transcriptassocload/reports.prod
rsync -avz bhmgiapp01:/data/loads/ensembl/ensembl_transcriptseqload/output ${DATALOADSOUTPUT}/ensembl/ensembl_transcriptseqload/output.prod
rsync -avz bhmgiapp01:/data/loads/ensembl/ensembl_transcriptassocload/output ${DATALOADSOUTPUT}/ensembl/ensembl_transcriptassocload/output.prod
rsync -avz bhmgiapp01:/data/loads/ensembl/ensembl_proteinassocload/output ${DATALOADSOUTPUT}/ensembl/ensembl_proteinassocload/output.prod
rsync -avz bhmgiapp01:/data/loads/ensembl/ensembl_proteinassocload/reports ${DATALOADSOUTPUT}/ensembl/ensembl_proteinassocload/reports.prod
rsync -avz bhmgiapp01:/data/loads/ensembl/ensembl_proteinseqload/output ${DATALOADSOUTPUT}/ensembl/ensembl_proteinseqload/output.prod
rsync -avz bhmgiapp01:/data/loads/ensembl/ensembl_protein_seqseqassocload/output ${DATALOADSOUTPUT}/ensembl/ensembl_protein_seqseqassocload/output.prod
rsync -avz bhmgiapp01:/data/loads/ensembl/ensembl_transcript_seqseqassocload/output ${DATALOADSOUTPUT}/ensembl/ensembl_transcript_seqseqassocload/output.prod

