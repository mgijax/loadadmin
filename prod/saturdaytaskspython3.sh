#!/bin/sh

# Sharon

# fearload  - this file should  load 22 relationships
scp bhmgiap09lt:/data/fear/current/cluster_has_member/cluster_20190731.txt   /data/loads/mgi/fearload/input/fearload.txt

# htmpload
scp bhmgiapp01:/data/downloads/www.ebi.ac.uk/impc.json /data/downloads/www.ebi.ac.uk/impc.json
scp bhmgiapp01:/data/downloads/www.mousephenotype.org/mp2_load_phenotyping_colonies_report.tsv  /data/downloads/www.mousephenotype.org/mp2_load_phenotyping_colonies_report.tsv

rsync -avz bhmgiapp01:/data/loads/mgi/htmpload/impcmpload/output /data/loads/mgi/htmpload/impcmpload/output.prod

# remove lastrun
rm /data/loads/mgi/fearload/input/lastrun
rm /data/loads/mgi/htmpload/impcmpload/input/lastrun

# cache loads (just mrkcoord cache)

# public reports

# qc reports

# Lori

# geoload
cd /data/loads/geo/geoload/input
scp bhmgiapp01:/data/loads/geo/geoload/input/geoload_input.txt geoload_input.txt.prod
cd /data/loads/geo/geoload/output
scp bhmgiapp01:/data/loads/geo/geoload/output/ACC_Accession.bcp ACC_Accession.bcp.prod
cd /data/loads/geo/geoload/reports
scp bhmgiapp01:/data/loads/geo/geoload/reports/geoload.rpt geoload.rpt.prod

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

