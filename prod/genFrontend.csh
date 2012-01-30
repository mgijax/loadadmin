#!/bin/csh -f
#
#  genFrontend.csh
###########################################################################
#
#  Purpose:
#
#      Call scripts from frontend products that are needed to update
#      database-specific info.
#
#  Usage:
#
#      genFrontend.csh
#
#  Env Vars:
#
#      - See Configuration file (loadadmin product)
#
#      - See master.config.csh (mgiconfig product)
#
#  Inputs:  None
#
#  Outputs:  None
#
#  Exit Codes:  None
#
#  Assumes:  Nothing
#
#  Implementation:
#
#  Notes:  None
#
###########################################################################

cd `dirname $0` && source ./Configuration

#
# Update database-specific info in the WI.
#
date
echo 'Run dbdepends'
${MGI_LIVE}/wi/admin/dbdepends

#
# Generate new stats and include files for MGI Home.
#
date
echo 'Generate new stats and include files for MGI Home'
cd ${MGI_LIVE}/mgihome/admin
gen_stats
gen_includes

#
# Regenerate templates and GlobalConfig from webshare.
#
date
echo 'Regenerate templates and GlobalConfig from webshare'
cd ${MGI_LIVE}/mgiconfig/bin
gen_webshare_prod

date
