#!/bin/csh -f
#
#  eiDisable.csh
###########################################################################
#
#  Purpose:
#
#      This script will disable the production EI on lindon and bhmgiei01
#      by renaming the symbolic link on each server. It is intended to be
#      run from lindon.
#
#  Usage:
#
#      eiDisable.csh
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
#      2) Make sure the script is being run on lindon.
#      3) If the "ei" link exists, rename it to "ei.disable".
#      4) If the "ei" link exists on bhmgiei01, rename it to "ei.disable".
#
#  Notes:  None
#
###########################################################################

cd `dirname $0` && source ./Configuration

if ( "`uname -n`" != "lindon" ) then
    echo "This script needs to be run on lindon"
    exit 1
endif

echo "Disable the EI on lindon"
if ( -e ${MGI_LIVE}/ei ) then
    cd ${MGI_LIVE}
    mv ei ei.disable
endif

echo "Disable the EI on bhmgiei01"
set str=`ssh -q mgiadmin@bhmgiei01 "cd ${MGI_LIVE}; ls -l | grep ' ei -> '"`
if ( "$str" != "" ) then
    ssh -q mgiadmin@bhmgiei01 "cd ${MGI_LIVE}; mv ei ei.disable"
endif

exit 0
