#!/bin/csh -f
#
#  eiEnable.csh
###########################################################################
#
#  Purpose:
#
#      This script will enable the EI by restoring the symbolic link.
#
#  Usage:
#
#      eiEnable.csh
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
#  Exit Codes:
#
#      0:  Successful completion
#      1:  Fatal error occurred
#
#  Assumes:  Nothing
#
#  Implementation:
#
#      This script will perform the following steps:
#
#      1) Source the configuration file to establish the environment.
#      2) If the "ei.disable" link exists, restore it to "ei".
#
#  Notes:  None
#
###########################################################################

cd `dirname $0` && source ./Configuration

if ( -e ${MGI_LIVE}/ei.disable ) then
    cd ${MGI_LIVE}
    mv ei.disable ei
endif

exit 0
