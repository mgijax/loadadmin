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

