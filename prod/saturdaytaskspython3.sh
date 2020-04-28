#!/bin/sh

# Sharon

# fearload  - this file should  load 22 relationships
scp bhmgiap09lt:/data/fear/current/cluster_has_member/cluster_20190731.txt   /data/loads/mgi/fearload/input/fearload.txt

# htmpload
scp bhmgiapp01:/data/downloads/www.ebi.ac.uk/impc.json /data/downloads/www.ebi.ac.uk/impc.json
scp bhmgiapp01:/data/downloads/www.mousephenotype.org/mp2_load_phenotyping_colonies_report.tsv  /data/downloads/www.mousephenotype.org/mp2_load_phenotyping_colonies_report.tsv

rsync -avz bhmgiapp01:/data/loads/mgi/htmpload/impcmpload/output /data/loads/mgi/htmpload/impcmpload/output.prod
rsync -avz bhmgiapp01:/data/loads/mgi/htmpload/impcmpload/logs /data/loads/mgi/htmpload/impcmpload/logs.prod

# rnaseqload
rsync -avz bhmgiapp01:/data/loads/mgi/rnaseqload/raw_input /data/loads/mgi/rnaseqload

# strainmarkerload
rsync -avz bhmgiapp01:/data/downloads/ftp.ensembl.org/pub/release-92/gff3 /data/downloads/ftp.ensembl.org/pub/release-92/
# mgigff3 file is copied by the load

rsync -avz  bhmgiapp01:/data/loads/mgi/strainmarkerload/input /data/loads/mgi/strainmarkerload/input.prod
rsync -avz  bhmgiapp01:/data/loads/mgi/strainmarkerload/output /data/loads/mgi/strainmarkerload/output.prod
rsync -avz  bhmgiapp01:/data/loads/mgi/strainmarkerload/logs /data/loads/mgi/strainmarkerload/logs.prod

# straingenemodelload
# input is database and mgigff - see strainmarkerload above
rsync -avz  bhmgiapp01:/data/loads/mgi/straingenemodelload/input /data/loads/mgi/straingenemodelload/input.prod
rsync -avz  bhmgiapp01:/data/loads/mgi/straingenemodelload/output /data/loads/mgi/straingenemodelload/output.prod
rsync -avz  bhmgiapp01:/data/loads/mgi/straingenemodelload/logs /data/loads/mgi/straingenemodelload/logs.prod

rsync -avz  bhmgiapp01:/data/loads/assembly/b6seqload/output /data/loads/assembly/b6seqload/output.prod
rsync -avz  bhmgiapp01:/data/loads/assembly/b6seqload/logs /data/loads/assembly/b6seqload/logs.prod


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

# cache loads (just mrkcoord cache)

# public reports

# qc reports

# Lori

# strainmarkerload
scp bhmgiapp01:/export/gondor/ftp/pub/mgigff3/MGI.gff3.gz /data/loads/mgi/strainmarkerload/input

# slimtermload
cd /data/loads/mgi/slimtermload/emapslimload/input
scp bhmgiapp01:/data/loads/mgi/slimtermload/emapslimload/input/emapslimload.txt .
cd /data/loads/mgi/slimtermload/goslimload/input
scp bhmgiapp01:/data/loads/mgi/slimtermload/goslimload/input/goslimload.txt .
cd /data/loads/mgi/slimtermload/mpslimload/input
scp bhmgiapp01:/data/loads/mgi/slimtermload/mpslimload/input/mpslimload.txt .

# geoload
cd /data/loads/geo/geoload/input
scp bhmgiapp01:/data/loads/geo/geoload/input/geoload_input.txt geoload_input.txt.prod
cd /data/loads/geo/geoload/output
scp bhmgiapp01:/data/loads/geo/geoload/output/ACC_Accession.bcp ACC_Accession.bcp.prod
cd /data/loads/geo/geoload/reports
scp bhmgiapp01:/data/loads/geo/geoload/reports/geoload.rpt geoload.rpt.prod

# proload
scp bhmgiapp01:/data/downloads/proconsortium.org/download/more/mgi/PRO_mgi.txt /data/downloads/proconsortium.org/download/more/mgi/
cd /data/loads/pro/proload/input
scp bhmgiapp01:/data/loads/pro/proload/input/proannot.txt proannot.txt.prod
scp bhmgiapp01:/data/loads/pro/proload/input/proassoc.txt proassoc.txt.prod
scp bhmgiapp01:/data/loads/pro/proload/input/provoc.txt provoc.txt.prod
mkdir /data/loads/pro/proload/output.prod
cd /data/loads/pro/proload/output.prod
scp bhmgiapp01:/data/loads/pro/proload/output/discrepancy.html .
scp bhmgiapp01:/data/loads/pro/proload/output/accAccession.bcp .
scp bhmgiapp01:/data/loads/pro/proload/output/ACC_Accession.bcp .
scp bhmgiapp01:/data/loads/pro/proload/output/ACC_AccessionReference.bcp .
scp bhmgiapp01:/data/loads/pro/proload/output/MGI_Association.bcp .
scp bhmgiapp01:/data/loads/pro/proload/output/PRB_Reference.bcp .
scp bhmgiapp01:/data/loads/pro/proload/output/proannot.txt.MGI_Note.bcp .
scp bhmgiapp01:/data/loads/pro/proload/output/proannot.txt.MGI_NoteChunk.bcp .
scp bhmgiapp01:/data/loads/pro/proload/output/proannot.txt.VOC_Annot.bcp .
scp bhmgiapp01:/data/loads/pro/proload/output/proannot.txt.VOC_Evidence.bcp .
scp bhmgiapp01:/data/loads/pro/proload/output/proannot.txt.VOC_Evidence_Property.bcp .
scp bhmgiapp01:/data/loads/pro/proload/output/QC_AssocLoad_Assoc_Discrep.bcp .
scp bhmgiapp01:/data/loads/pro/proload/output/QC_AssocLoad_Target_Discrep.bcp .
scp bhmgiapp01:/data/loads/pro/proload/output/termNote.bcp .
scp bhmgiapp01:/data/loads/pro/proload/output/termNoteChunk.bcp .
scp bhmgiapp01:/data/loads/pro/proload/output/termSynonym.bcp .
scp bhmgiapp01:/data/loads/pro/proload/output/termTerm.bcp .

# genemodelload
cd /data/loads/mgi/genemodelload/output/
scp bhmgiapp01:/data/loads/mgi/genemodelload/output/MRK_BiotypeMapping.bcp MRK_BiotypeMapping.bcp.prod
scp bhmgiapp01:/data/loads/mgi/genemodelload/output/SEQ_GeneModel.ensembl.bcp SEQ_GeneModel.ensembl.bcp.prod
scp bhmgiapp01:/data/loads/mgi/genemodelload/output/SEQ_GeneModel.ncbi.bcp SEQ_GeneModel.ncbi.bcp.prod
cd /data/loads/mgi/genemodelload/input
scp bhmgiapp01:/data/loads/mgi/genemodelload/input/ensembl_biotypes.gz .
scp bhmgiapp01:/data/loads/mgi/genemodelload/input/ncbi_biotypes.gz .
scp bhmgiapp01:/data/loads/mgi/genemodelload/input/ensembl.txt .
cd /data/genemodels/current/models
scp bhmgiapp01:/data/genemodels/current/models/ensembl_genemodels.txt .
cd /data/genemodels/pending/associations/ensembl
scp bhmgiapp01:/data/genemodels/pending//associations/ensembl/ensembl_assoc.txt .
scp bhmgiapp01:/data/genemodels/pending//associations/ensembl/ensembl_assoc_sanity.rpt ensembl_assoc_sanity.rpt.prod
scp bhmgiapp01:/data/genemodels/pending//associations/ensembl/ensembl_assoc.txt ensembl_assoc.txt.prod
scp bhmgiapp01:/data/genemodels/pending//associations/ensembl/ensembl_chr_discrep.rpt ensembl_chr_discrep.rpt.prod
scp bhmgiapp01:/data/genemodels/pending//associations/ensembl/ensembl_genemodelQC.log ensembl_genemodelQC.log.prod
scp bhmgiapp01:/data/genemodels/pending//associations/ensembl/ensembl_genemodels_sanity.rpt ensembl_genemodels_sanity.rpt.prod
scp bhmgiapp01:/data/genemodels/pending//associations/ensembl/ensembl_invalid_marker.rpt ensembl_invalid_marker.rpt.prod
scp bhmgiapp01:/data/genemodels/pending//associations/ensembl/ensembl_missing_gmid.rpt ensembl_missing_gmid.rpt.prod
scp bhmgiapp01:/data/genemodels/pending//associations/ensembl/ensembl_reportsWithDiscrepancies.rpt ensembl_reportsWithDiscrepancies.rpt.prod
scp bhmgiapp01:/data/genemodels/pending//associations/ensembl/ensembl_sec_marker.rpt ensembl_sec_marker.rpt.prod

# alleleload
cd /data/downloads/www.mousephenotype.org
#scp bhmgiapp01:/data/downloads/www.mousephenotype.org/mgi_modification_allele_report.tsv .
scp bhmgiapp14ld:/data/downloads/www.mousephenotype.org/mgi_modification_allele_report_rmb.tsv mgi_modification_allele_report.tsv
cd /data/loads/mgi/alleleload/ikmc/input
scp bhmgiapp01:/data/loads/mgi/alleleload/ikmc/input/mgi_modification_allele_report.tsv mgi_modification_allele_report.tsv.prod

# emalload
cd /data/downloads/www.mousephenotype.org
scp bhmgiapp01:/data/downloads/www.mousephenotype.org/mgi_crispr_allele_report.tsv .

cd /data/loads/mgi/emalload/impc/input
scp bhmgiapp01:/data/loads/mgi/emalload/impc/input/crispr_file.txt crispr_file.txt.prod
cd /data/loads/mgi/emalload/impc/output.prod
scp bhmgiapp01:/data/loads/mgi/emalload/impc/output/ACC_Accession.bcp .
scp bhmgiapp01:/data/loads/mgi/emalload/impc/output/ALL_Allele.bcp .
scp bhmgiapp01:/data/loads/mgi/emalload/impc/output/ALL_Allele_Mutation.bcp .
scp bhmgiapp01:/data/loads/mgi/emalload/impc/output/allele_file.txt .
scp bhmgiapp01:/data/loads/mgi/emalload/impc/output/cid_noteload.txt .
scp bhmgiapp01:/data/loads/mgi/emalload/impc/output/MGI_Note.bcp .
scp bhmgiapp01:/data/loads/mgi/emalload/impc/output/MGI_NoteChunk.bcp .
scp bhmgiapp01:/data/loads/mgi/emalload/impc/output/MGI_Reference_Assoc.bcp .
scp bhmgiapp01:/data/loads/mgi/emalload/impc/output/VOC_Annot.bcp .
cd /data/loads/mgi/emalload/impc/reports
scp bhmgiapp01:/data/loads/mgi/emalload/impc/reports/emalload_qc.rpt emalload_qc.rpt.prod
scp bhmgiapp01:/data/loads/mgi/emalload/impc/reports/MGI_impc_crispr_allele.rpt MGI_impc_crispr_allele.rpt.prod
scp bhmgiapp01:/data/loads/mgi/emalload/impc/reports/sanity.rpt sanity.rpt.prod

# mp_emapaload
scp bhmgiapp01:/data/downloads/purl.obolibrary.org/obo/uberon.obo /data/downloads/purl.obolibrary.org/obo
scp bhmgiapp01:/data/loads/mgi/vocload/runTimeMP/mp.owl /data/loads/mgi/vocload/runTimeMP
scp bhmgiapp01:/data/loads/mgi/vocload/emap/input/EMAPA.obo /data/loads/mgi/vocload/emap/input
cd /data/loads/mp_emapaload/input
scp bhmgiapp01:/data/loads/mp_emapaload/input/emapa.txt emapa.txt.prod
scp bhmgiapp01:/data/loads/mp_emapaload/input/mpToUberon.txt mpToUberon.txt.prod
scp bhmgiapp01:/data/loads/mp_emapaload/input/uberonToEmapa.txt uberonToEmapa.txt.prod
cd /data/loads/mp_emapaload/output
scp bhmgiapp01:/data/loads/mp_emapaload/output/MGI_Relationship.bcp MGI_Relationship.bcp.prod
cd /data/loads/mp_emapaload/reports
scp bhmgiapp01:/data/loads/mp_emapaload/reports/MP_EMAPA.rpt.new MP_EMAPA.rpt.new.prod

# assemblyseqload/ensemblseqload/seqseqassocload

scp bhmgiapp01:/data/loads/assembly/ensemblseqload/reports/chrcheck.rpt /data/loads/assembly/ensemblseqload/reports/chrcheck.rpt.prod
scp bhmgiapp01:/data/loads/mgi/genemodelload/input/ensembl_transcripts.gz /data/loads/mgi/genemodelload/input/ensembl_transcripts.gz
scp bhmgiapp01:/data/loads/mgi/genemodelload/input/ensembl_ncrna.gz /data/loads/mgi/genemodelload/input/ensembl_ncrna.gz
scp bhmgiapp01:/data/loads/mgi/genemodelload/input/ensembl_proteins.gz /data/loads/mgi/genemodelload/input
scp bhmgiapp01:/data/loads/ensembl/ensembl_transcriptassocload/reports/AssocDiscrepancy.rpt /data/loads/ensembl/ensembl_transcriptassocload/reports/AssocDiscrepancy.rpt.prod
scp bhmgiapp01:/data/loads/ensembl/ensembl_transcriptassocload/reports/TargetDiscrepancy.rpt /data/loads/ensembl/ensembl_transcriptassocload/reports/TargetDiscrepancy.rpt.prod
scp bhmgiapp01:/data/loads/ensembl/ensembl_transcriptseqload/output/ensembl_transcript_mkrassoc.txt /data/loads/ensembl/ensembl_transcriptseqload/output/ensembl_transcript_mkrassoc.txt.prod
scp bhmgiapp01:/data/loads/ensembl/ensembl_transcriptassocload/output/ACC_Accession.bcp /data/loads/ensembl/ensembl_transcriptassocload/output/ACC_Accession.bcp.prod
scp bhmgiapp01:/data/loads/ensembl/ensembl_transcriptassocload/output/ACC_AccessionReference.bcp /data/loads/ensembl/ensembl_transcriptassocload/output/ACC_AccessionReference.bcp.prod
scp bhmgiapp01:/data/loads/ensembl/ensembl_transcriptassocload/output/MGI_Association.bcp /data/loads/ensembl/ensembl_transcriptassocload/output/MGI_Association.bcp.prod
scp bhmgiapp01:/data/loads/ensembl/ensembl_transcriptassocload/output/PRB_Reference.bcp /data/loads/ensembl/ensembl_transcriptassocload/output/PRB_Reference.bcp.prod
scp bhmgiapp01:/data/loads/ensembl/ensembl_transcriptassocload/output/QC_AssocLoad_Assoc_Discrep.bcp /data/loads/ensembl/ensembl_transcriptassocload/output/QC_AssocLoad_Assoc_Discrep.bcp.prod
scp bhmgiapp01:/data/loads/ensembl/ensembl_transcriptassocload/output/QC_AssocLoad_Target_Discrep.bcp /data/loads/ensembl/ensembl_transcriptassocload/output/QC_AssocLoad_Target_Discrep.bcp.prod
scp bhmgiapp01:/data/loads/ensembl/ensembl_transcriptseqload/output/ACC_Accession.bcp /data/loads/ensembl/ensembl_transcriptseqload/output/ACC_Accession.bcp.prod
scp bhmgiapp01:/data/loads/ensembl/ensembl_transcriptseqload/output/ensembl_transcript_mkrassoc.txt /data/loads/ensembl/ensembl_transcriptseqload/output/ensembl_transcript_mkrassoc.txt.prod
scp bhmgiapp01:/data/loads/ensembl/ensembl_transcriptseqload/output/ensembl_transcript_seqseqassoc.txt /data/loads/ensembl/ensembl_transcriptseqload/output/ensembl_transcript_seqseqassoc.txt.prod
scp bhmgiapp01:/data/loads/ensembl/ensembl_transcriptseqload/output/MGI_Reference_Assoc.bcp /data/loads/ensembl/ensembl_transcriptseqload/output/MGI_Reference_Assoc.bcp.prod
scp bhmgiapp01:/data/loads/ensembl/ensembl_transcriptseqload/output/SEQ_Sequence.bcp /data/loads/ensembl/ensembl_transcriptseqload/output/SEQ_Sequence.bcp.prod
scp bhmgiapp01:/data/loads/ensembl/ensembl_transcriptseqload/output/SEQ_Sequence_Raw.bcp /data/loads/ensembl/ensembl_transcriptseqload/output/SEQ_Sequence_Raw.bcp.prod
scp bhmgiapp01:/data/loads/ensembl/ensembl_transcriptseqload/output/SEQ_Source_Assoc.bcp /data/loads/ensembl/ensembl_transcriptseqload/output/SEQ_Source_Assoc.bcp.prod
scp bhmgiapp01:/data/loads/ensembl/ensembl_proteinassocload/output/ACC_Accession.bcp /data/loads/ensembl/ensembl_proteinassocload/output/ACC_Accession.bcp.prod
scp bhmgiapp01:/data/loads/ensembl/ensembl_proteinassocload/output/ACC_AccessionReference.bcp /data/loads/ensembl/ensembl_proteinassocload/output/ACC_AccessionReference.bcp.prod
scp bhmgiapp01:/data/loads/ensembl/ensembl_proteinassocload/output/MGI_Association.bcp /data/loads/ensembl/ensembl_proteinassocload/output/MGI_Association.bcp.prod
scp bhmgiapp01:/data/loads/ensembl/ensembl_proteinassocload/output/PRB_Reference.bcp /data/loads/ensembl/ensembl_proteinassocload/output/PRB_Reference.bcp.prod
scp bhmgiapp01:/data/loads/ensembl/ensembl_proteinassocload/output/QC_AssocLoad_Assoc_Discrep.bcp /data/loads/ensembl/ensembl_proteinassocload/output/QC_AssocLoad_Assoc_Discrep.bcp.prod
scp bhmgiapp01:/data/loads/ensembl/ensembl_proteinassocload/output/QC_AssocLoad_Target_Discrep.bcp /data/loads/ensembl/ensembl_proteinassocload/output/QC_AssocLoad_Target_Discrep.bcp.prod
scp bhmgiapp01:/data/loads/ensembl/ensembl_proteinassocload/reports/AssocDiscrepancy.rpt /data/loads/ensembl/ensembl_proteinassocload/reports/AssocDiscrepancy.rpt.prod
scp bhmgiapp01:/data/loads/ensembl/ensembl_proteinassocload/reports/TargetDiscrepancy.rpt /data/loads/ensembl/ensembl_proteinassocload/reports/TargetDiscrepancy.rpt.prod
scp bhmgiapp01:/data/loads/ensembl/ensembl_proteinseqload/output/ACC_Accession.bcp /data/loads/ensembl/ensembl_proteinseqload/output/ACC_Accession.bcp.prod
scp bhmgiapp01:/data/loads/ensembl/ensembl_proteinseqload/output/ensembl_protein_mkrassoc.txt /data/loads/ensembl/ensembl_proteinseqload/output/ensembl_protein_mkrassoc.txt.prod
scp bhmgiapp01:/data/loads/ensembl/ensembl_proteinseqload/output/ensembl_protein_seqseqassoc.txt /data/loads/ensembl/ensembl_proteinseqload/output/ensembl_protein_seqseqassoc.txt.prod
scp bhmgiapp01:/data/loads/ensembl/ensembl_proteinseqload/output/MGI_Reference_Assoc.bcp /data/loads/ensembl/ensembl_proteinseqload/output/MGI_Reference_Assoc.bcp.prod
scp bhmgiapp01:/data/loads/ensembl/ensembl_proteinseqload/output/SEQ_Sequence.bcp /data/loads/ensembl/ensembl_proteinseqload/output/SEQ_Sequence.bcp.prod
scp bhmgiapp01:/data/loads/ensembl/ensembl_proteinseqload/output/SEQ_Sequence_Raw.bcp /data/loads/ensembl/ensembl_proteinseqload/output/SEQ_Sequence_Raw.bcp.prod
scp bhmgiapp01:/data/loads/ensembl/ensembl_proteinseqload/output/SEQ_Source_Assoc.bcp /data/loads/ensembl/ensembl_proteinseqload/output/SEQ_Source_Assoc.bcp.prod
scp bhmgiapp01:/data/loads/ensembl/ensembl_protein_seqseqassocload/output/SEQ_Sequence_Assoc.bcp /data/loads/ensembl/ensembl_protein_seqseqassocload/output/SEQ_Sequence_Assoc.bcp.prod
scp bhmgiapp01:/data/loads/ensembl/ensembl_transcript_seqseqassocload/output/SEQ_Sequence_Assoc.bcp /data/loads/ensembl/ensembl_transcript_seqseqassocload/output/SEQ_Sequence_Assoc.bcp.prod

# alomrkload
cd /data/loads/mgi/alomrkload/input
scp bhmgiapp01:/data/loads/mgi/alomrkload/input/fjoin.out fjoin.out.prod
scp bhmgiapp01:/data/loads/mgi/alomrkload/input/markers.gff markers.gff.prod
scp bhmgiapp01:/data/loads/mgi/alomrkload/input/sequences.gff sequences.gff.prod
cd /data/loads/mgi/alomrkload/output
scp bhmgiapp01:/data/loads/mgi/alomrkload/output/MGI_Note.bcp MGI_Note.bcp.prod
scp bhmgiapp01:/data/loads/mgi/alomrkload/output/MGI_NoteChunk.bcp MGI_NoteChunk.bcp.prod

# targetedalleleload

cd /data/downloads/www.mousephenotype.org
scp bhmgiapp01:/data/downloads/www.mousephenotype.org/mgi_es_cell_allele_report.tsv .
scp bhmgiapp01:/data/downloads/www.mousephenotype.org/mgi_es_cell_allele_report.tsv .
scp bhmgiapp01:/data/downloads/www.mousephenotype.org/mgi_es_cell_allele_report.tsv .
scp bhmgiapp01:/data/downloads/www.mousephenotype.org/mgi_es_cell_allele_report.tsv .

cd /data/loads/targetedallele/input
scp bhmgiapp01:/data/loads/targetedallele/input/mgi_es_cell_allele_report.tsv mgi_es_cell_allele_report.tsv.prod

cd /data/loads/targetedallele
scp bhmgiapp01:/data/loads/targetedallele/duplicatedAllele.rpt duplicatedAllele.rpt.prod

cd /data/loads/targetedallele/csd_load_mbp/reports
scp bhmgiapp01:/data/loads/targetedallele/csd_load_wtsi/reports/AbandonedAllele.rpt AbandonedAllele.rpt.prod
cd /data/loads/targetedallele/csd_load_wtsi/reports
scp bhmgiapp01:/data/loads/targetedallele/csd_load_wtsi/reports/AbandonedAllele.rpt AbandonedAllele.rpt.prod
cd /data/loads/targetedallele/eucomm_load_hmgu/reports
scp bhmgiapp01:/data/loads/targetedallele/eucomm_load_hmgu/reports/AbandonedAllele.rpt AbandonedAllele.rpt.prod
cd /data/loads/targetedallele/eucomm_load_wtsi/reports
scp bhmgiapp01:/data/loads//targetedallele/eucomm_load_wtsi/reports/AbandonedAllele.rpt AbandonedAllele.rpt.prod

# gxdhtload
scp bhmgiapp01:/data/downloads/www.ebi.ac.uk/arrayexpress.json /data/downloads/www.ebi.ac.uk
rsync -avz  bhmgiapp01:/data/loads/mgi/gxdhtload/input /data/loads/lec/mgi/gxdhtload/input.prod
rsync -avz  bhmgiapp01:/data/loads/mgi/gxdhtload/output /data/loads/lec/mgi/gxdhtload/output.prod
rsync -avz  bhmgiapp01:/data/loads/mgi/gxdhtload/reports /data/loads/lec/mgi/gxdhtload/reports.prod

## end
cd /usr/local/mgi/scrum-dog/loadadmin/prod

