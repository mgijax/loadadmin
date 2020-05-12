#!/bin/sh

# remove lastrun
rm -rf /data/loads/mgi/fearload/input/lastrun
rm -rf /data/loads/mgi/htmpload/impcmpload/input/lastrun
rm -rf /data/loads/mgi/strainmarkerload/output/lastrun
rm -rf /data/loads/mgi/slimtermload/emapslimload/input/lastrun
rm -rf /data/loads/mgi/slimtermload/goslimload/input/lastrun
rm -rf /data/loads/mgi/slimtermload/mpslimload/input/lastrun
rm -rf /data/loads/pro/proload/input/lastrun
rm -rf /data/loads/mgi/rvload/input/lastrun
rm -rf /data/loads/swissprot/spseqload/input/lastrun
rm -rf /data/loads/swissprot/trseqload/input/lastrun

# geoload
rsync -avz bhmgiapp01:/data/loads/geo/geoload/input /data/loads/geo/geoload/input.prod
rsync -avz bhmgiapp01:/data/loads/geo/geoload/output /data/loads/geo/geoload/output.prod
rsync -avz bhmgiapp01:/data/loads/geo/geoload/reports /data/loads/geo/geoload/reports.prod

# proload
scp bhmgiapp01:/data/downloads/proconsortium.org/download/more/mgi/PRO_mgi.txt /data/downloads/proconsortium.org/download/more/mgi/
rsync -avz bhmgiapp01:/data/loads/pro/proload/input /data/loads/pro/proload/input.prod
rsync -avz bhmgiapp01:/data/loads/pro/proload/output /data/loads/pro/proload/output.prod

# rvload
rsync -avz bhmgiapp01:/data/loads/mgi/rvload/input /data/loads/mgi/rvload/input.prod
rsync -avz bhmgiapp01:/data/loads/mgi/rvload/output /data/loads/mgi/rvload/output.prod

# fearload  - this file should  load 22 relationships
scp bhmgiap09lt:/data/fear/current/cluster_has_member/cluster_20190731.txt /data/loads/mgi/fearload/input/fearload.txt

# slimtermload
scp bhmgiapp01:/data/loads/mgi/slimtermload/emapslimload/input/emapslimload.txt /data/loads/mgi/slimtermload/emapslimload/input
rsync -avz bhmgiapp01:/data/loads/mgi/slimtermload/emapslimload/input /data/loads/mgi/slimtermload/emapslimload/input.prod
rsync -avz bhmgiapp01:/data/loads/mgi/slimtermload/emapslimload/output /data/loads/mgi/slimtermload/emapslimload/output.prod
scp bhmgiapp01:/data/loads/mgi/slimtermload/goslimload/input/goslimload.txt /data/loads/mgi/slimtermload/goslimload/input
rsync -avz bhmgiapp01:/data/loads/mgi/slimtermload/goslimload/input /data/loads/mgi/slimtermload/goslimload/input.prod
rsync -avz bhmgiapp01:/data/loads/mgi/slimtermload/goslimload/output /data/loads/mgi/slimtermload/goslimload/output.prod
scp bhmgiapp01:/data/loads/mgi/slimtermload/mpslimload/input/mpslimload.txt /data/loads/mgi/slimtermload/mpslimload/input
rsync -avz bhmgiapp01:/data/loads/mgi/slimtermload/mpslimload/input /data/loads/mgi/slimtermload/mpslimload/input.prod
rsync -avz bhmgiapp01:/data/loads/mgi/slimtermload/mpslimload/output /data/loads/mgi/slimtermload/mpslimload/output.prod

# targetedalleleload
scp bhmgiapp01:/data/downloads/www.mousephenotype.org/mgi_es_cell_allele_report.tsv /data/downloads/www.mousephenotype.org
scp bhmgiapp01:/data/downloads/www.mousephenotype.org/mgi_es_cell_allele_report.tsv /data/downloads/www.mousephenotype.org
scp bhmgiapp01:/data/downloads/www.mousephenotype.org/mgi_es_cell_allele_report.tsv /data/downloads/www.mousephenotype.org
scp bhmgiapp01:/data/downloads/www.mousephenotype.org/mgi_es_cell_allele_report.tsv /data/downloads/www.mousephenotype.org
scp bhmgiapp01:/data/loads/targetedallele/duplicatedAllele.rpt /data/loads/targetedallele/duplicatedAllele.rpt.prod
rsync -avz bhmgiapp01:/data/loads/targetedallele/input /data/loads/targetedallele/input.prod
rsync -avz bhmgiapp01:/data/loads/targetedallele/csd_load_mbp/output /data/loads/targetedallele/csd_load_mbp/output.prod
rsync -avz bhmgiapp01:/data/loads/targetedallele/csd_load_mbp/reports /data/loads/targetedallele/csd_load_mbp/reports.prod
rsync -avz bhmgiapp01:/data/loads/targetedallele/csd_load_wtsi/output /data/loads/targetedallele/csd_load_wtsi/output.prod
rsync -avz bhmgiapp01:/data/loads/targetedallele/csd_load_wtsi/reports /data/loads/targetedallele/csd_load_wtsi/reports.prod
rsync -avz bhmgiapp01:/data/loads/targetedallele/eucomm_load_hmgu/output /data/loads/targetedallele/eucomm_load_hmgu/output.prod
rsync -avz bhmgiapp01:/data/loads/targetedallele/eucomm_load_hmgu/reports /data/loads/targetedallele/eucomm_load_hmgu/reports.prod
rsync -avz bhmgiapp01:/data/loads/targetedallele/eucomm_load_wtsi/output /data/loads/targetedallele/eucomm_load_wtsi/output.prod
rsync -avz bhmgiapp01:/data/loads/targetedallele/eucomm_load_wtsi/reports /data/loads/targetedallele/eucomm_load_wtsi/reports.prod

# alleleload
scp bhmgiapp01:/data/downloads/www.mousephenotype.org/mgi_modification_allele_report.tsv /data/downloads/www.mousephenotype.org
rsync -avz bhmgiapp01:/data/loads/mgi/alleleload/ikmc/input /data/loads/mgi/alleleload/ikmc/input.prod
rsync -avz bhmgiapp01:/data/loads/mgi/alleleload/ikmc/output /data/loads/mgi/alleleload/ikmc/output.prod

# htmpload
scp bhmgiapp01:/data/downloads/www.ebi.ac.uk/impc.json /data/downloads/www.ebi.ac.uk/impc.json
scp bhmgiapp01:/data/downloads/www.mousephenotype.org/mp2_load_phenotyping_colonies_report.tsv /data/downloads/www.mousephenotype.org/mp2_load_phenotyping_colonies_report.tsv
rsync -avz bhmgiapp01:/data/loads/mgi/htmpload/impcmpload/output /data/loads/mgi/htmpload/impcmpload/output.prod
rsync -avz bhmgiapp01:/data/loads/mgi/htmpload/impcmpload/logs /data/loads/mgi/htmpload/impcmpload/logs.prod

# mp_emapaload
scp bhmgiapp01:/data/downloads/purl.obolibrary.org/obo/uberon.obo /data/downloads/purl.obolibrary.org/obo
scp bhmgiapp01:/data/loads/mgi/vocload/runTimeMP/mp.owl /data/loads/mgi/vocload/runTimeMP
scp bhmgiapp01:/data/loads/mgi/vocload/emap/input/EMAPA.obo /data/loads/mgi/vocload/emap/input
rsync -avz bhmgiapp01:/data/loads/mp_emapaload/input /data/loads/mp_emapaload/input.prod
rsync -avz bhmgiapp01:/data/loads/mp_emapaload/output /data/loads/mp_emapaload/output.prod
rsync -avz bhmgiapp01:/data/loads/mp_emapaload/reports /data/loads/mp_emapaload/reports.prod

# gxdhtload
scp bhmgiapp01:/data/downloads/www.ebi.ac.uk/arrayexpress.json /data/downloads/www.ebi.ac.uk
rsync -avz bhmgiapp01:/data/loads/mgi/gxdhtload/input /data/loads/mgi/gxdhtload/input.prod
rsync -avz bhmgiapp01:/data/loads/mgi/gxdhtload/output /data/loads/mgi/gxdhtload/output.prod
rsync -avz bhmgiapp01:/data/loads/mgi/gxdhtload/reports /data/loads/mgi/gxdhtload/reports.prod

# genemodelload
scp bhmgiapp01:/data/genemodels/current/models/ensembl_genemodels.txt /data/genemodels/current/models
rsync -avz bhmgiapp01:/data/loads/mgi/genemodelload/input /data/loads/mgi/genemodelload/input.prod
rsync -avz bhmgiapp01:/data/loads/mgi/genemodelload/output /data/loads/mgi/genemodelload/output.prod
rsync -avz bhmgiapp01:/data/genemodels/current/models /data/genemodels/current/models.prod

# emalload
scp bhmgiapp01:/data/downloads/www.mousephenotype.org/mgi_crispr_allele_report.tsv /data/downloads/www.mousephenotype.org
rsync -avz bhmgiapp01:/data/loads/mgi/emalload/impc/input /data/loads/mgi/emalload/impc/input.prod
rsync -avz bhmgiapp01:/data/loads/mgi/emalload/impc/output /data/loads/mgi/emalload/impc/output.prod
rsync -avz bhmgiapp01:/data/loads/mgi/emalload/impc/reports /data/loads/mgi/emalload/impc/reports.prod

# straingenemodelload
# input is database and mgigff - see strainmarkerload above
rsync -avz bhmgiapp01:/data/loads/mgi/straingenemodelload/input /data/loads/mgi/straingenemodelload/input.prod
rsync -avz bhmgiapp01:/data/loads/mgi/straingenemodelload/output /data/loads/mgi/straingenemodelload/output.prod
rsync -avz bhmgiapp01:/data/loads/mgi/straingenemodelload/logs /data/loads/mgi/straingenemodelload/logs.prod

# rnaseqload
rsync -avz bhmgiapp01:/data/loads/mgi/rnaseqload/raw_input /data/loads/mgi/rnaseqload

# rollupload
rsync -avz  bhmgiapp01:/data/loads/rollupload/input /data/loads/rollupload/input.prod
rsync -avz  bhmgiapp01:/data/loads/rollupload/output /data/loads/rollupload/output.prod

# seqcacheload
rsync -avz  bhmgiapp01:/data/loads/mgi/seqcacheload/input /data/loads/mgi/seqcacheload/input.prod
rsync -avz  bhmgiapp01:/data/loads/mgi/mrkcacheload/output /data/loads/mgi/mrkcacheload/output.prod

# mrkcacheload
rsync -avz  bhmgiapp01:/data/loads/mgi/mrkcacheload/input /data/loads/mgi/mrkcacheload/input.prod
rsync -avz  bhmgiapp01:/data/loads/mgi/mrkcacheload/output /data/loads/mgi/mrkcacheload/output.prod

# alomrkload
rsync -avz  bhmgiapp01:/data/loads/mgi/alomrkload/input /data/loads/mgi/alomrkload/input.prod
rsync -avz  bhmgiapp01:/data/loads/mgi/alomrkload/output /data/loads/mgi/alomrkload/output.prod

# allcacheload
rsync -avz  bhmgiapp01:/data/loads/mgi/allcacheload/input /data/loads/mgi/allcacheload/input.prod
rsync -avz  bhmgiapp01:/data/loads/mgi/allcacheload/output /data/loads/mgi/allcacheload/output.prod

# strainmarkerload
# mgigff3 file is copied by the load
scp bhmgiapp01:/export/gondor/ftp/pub/mgigff3/MGI.gff3.gz /data/loads/mgi/strainmarkerload/input
rsync -avz bhmgiapp01:/data/downloads/ftp.ensembl.org/pub/release-92/gff3 /data/downloads/ftp.ensembl.org/pub/release-92/
rsync -avz bhmgiapp01:/data/loads/mgi/strainmarkerload/input /data/loads/mgi/strainmarkerload/input.prod
rsync -avz bhmgiapp01:/data/loads/mgi/strainmarkerload/output /data/loads/mgi/strainmarkerload/output.prod
rsync -avz bhmgiapp01:/data/loads/mgi/strainmarkerload/logs /data/loads/mgi/strainmarkerload/logs.prod

# assembly stuff
rsync -avz bhmgiapp01:/data/loads/assembly/b6seqload/output /data/loads/assembly/b6seqload/output.prod
rsync -avz bhmgiapp01:/data/loads/assembly/b6seqload/logs /data/loads/assembly/b6seqload/logs.prod

# assemblyseqload/ensemblseqload/seqseqassocload
rsync -avz bhmgiapp01:/data/loads/assembly/ensemblseqload/reports /data/loads/assembly/ensemblseqload/reports.prod
rsync -avz bhmgiapp01:/data/loads/mgi/genemodelload/input /data/loads/mgi/genemodelload/input.prod
rsync -avz bhmgiapp01:/data/loads/ensembl/ensembl_transcriptassocload/reports ensembl/ensembl_transcriptassocload/reports.prod
rsync -avz bhmgiapp01:/data/loads/ensembl/ensembl_transcriptseqload/output /data/loads/ensembl/ensembl_transcriptseqload/output.prod
rsync -avz bhmgiapp01:/data/loads/ensembl/ensembl_transcriptassocload/output /data/loads/ensembl/ensembl_transcriptassocload/output.prod
rsync -avz bhmgiapp01:/data/loads/ensembl/ensembl_proteinassocload/output /data/loads/ensembl/ensembl_proteinassocload/output.prod
rsync -avz bhmgiapp01:/data/loads/ensembl/ensembl_proteinassocload/reports /data/loads/ensembl/ensembl_proteinassocload/reports.prod
rsync -avz bhmgiapp01:/data/loads/ensembl/ensembl_proteinseqload/output /data/loads/ensembl/ensembl_proteinseqload/output.prod
rsync -avz bhmgiapp01:/data/loads/ensembl/ensembl_protein_seqseqassocload/output /data/loads/ensembl/ensembl_protein_seqseqassocload/output.prod
rsync -avz bhmgiapp01:/data/loads/ensembl/ensembl_transcript_seqseqassocload/output /data/loads/ensembl/ensembl_transcript_seqseqassocload/output.prod

## end
cd /usr/local/mgi/scrum-dog/loadadmin/prod

