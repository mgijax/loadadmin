#!/bin/csh -f
#
#  swapPublic.csh
###########################################################################
#
#  Purpose:
#
#      This script will swap over to the inactive public WI instance and
#      restart all the components on the various servers. It is intended
#      to be run from gondor and uses ssh calls to run scripts on other
#      servers.
#
#  Usage:
#
#      swapPublic.csh
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
#      2) Prompts for confirmation before proceeding.
#      3) Make sure the script is being run on gondor.
#      4) Determines which WI instance is inactive so it can identify the
#         correct Fewi server and QS restart script.
#      5) Runs scripts on the appropriate servers to swap/restart everything.
#
#  Notes:  None
#
###########################################################################

cd `dirname $0` && source ./Configuration

#
# Make sure this script wasn't run by accident.
#
echo -n "You are about to swap the public WI. Confirm (yes/no) ? "
set answer = $<
if ( "$answer" != "yes" ) then
    exit 0
endif

#
# Make sure the script is being run on gondor.
#
if ( "`uname -n`" != "gondor" ) then
    echo "This script needs to be run on gondor"
    exit 1
endif

#
# Determine which WI instance is inactive.
#
cd ${MGI_LIVE}
set str=`ls -l wiinactive | sed "s/.*wipub/wipub/"`
if ( "$str" == "wipub1" ) then
    set NEW_INSTANCE="pub1"
    set FEWI="mgi-pubfewi1"
    set QS_SCRIPT="restartSearchtool_pub1"
else if ( "$str" == "wipub2" ) then
    set NEW_INSTANCE="pub2"
    set FEWI="mgi-pubfewi2"
    set QS_SCRIPT="restartSearchtool_pub2"
else
    echo "Cannot determine which WI instance is inactive"
    exit 1
endif

echo "****"
echo "**** Swap to ${NEW_INSTANCE} ****"
echo "****"

#
# Run scripts on gondor.
#
echo "****"
echo "**** gondor: Swap GlobalConfig ****"
echo "****"
cd ${MGI_LIVE}/webshare/config
mv GlobalConfig.old saveold
mv GlobalConfig GlobalConfig.old
mv saveold GlobalConfig

echo "****"
echo "**** gondor: Run gen_webshare ****"
echo "****"
cd ${MGI_LIVE}/mgiconfig/bin
gen_webshare

echo "****"
echo "**** gondor: Restart tomcat ****"
echo "****"
${MGI_LIVE}/loadadmin/bin/restartTomcat

echo "****"
echo "**** gondor: Swap Java WI cache ****"
echo "****"
cd ${MGI_LIVE}
mv javawi2.cache.old saveold
mv javawi2.cache javawi2.cache.old
mv saveold javawi2.cache
rm -rf /usr/local/mgi/live/javawi2.cache.old/*

echo "****"
echo "**** gondor: Update Python WI ****"
echo "****"
cd ${MGI_LIVE}/wiinactive/admin
gen_includes

echo "****"
echo "**** gondor: Swap Python WI ****"
echo "****"
cd ${MGI_LIVE}
mv wiinactive saveold
mv wicurrent wiinactive
mv saveold wicurrent

echo "****"
echo "**** gondor: Clean inactive Python WI ****"
echo "****"
${MGI_LIVE}/wiinactive/admin/cleanup tmp

echo "****"
echo "**** gondor: Update MGI Home ****"
echo "****"
cd ${MGI_LIVE}/mgihome/admin
gen_stats
gen_includes

#
# Run scripts on buckland.
#
echo "****"
echo "**** buckland: Run gen_webshare ****"
echo "****"
ssh mgiadmin@buckland "cd ${MGI_LIVE}/mgiconfig/bin; gen_webshare"

#
# Run scripts on the active Fewi that is now active.
#
echo "****"
echo "**** ${FEWI}: Run gen_webshare ****"
echo "****"
ssh -q mgiadmin@${FEWI} "cd ${MGI_LIVE}/mgiconfig/bin; gen_webshare"

echo "****"
echo "**** ${FEWI}: Restart Fewi ****"
echo "****"
ssh -q mgiadmin@${FEWI} "${LOADADMIN}/jboss/restartFewi >& /dev/null"

echo "****"
echo "**** ${FEWI}: Restart FewiBatch ****"
echo "****"
ssh -q mgiadmin@${FEWI} "${LOADADMIN}/jboss/restartFewiBatch >& /dev/null"

#
# Run scripts on emnet.
#
echo "****"
echo "**** emnet: Run gen_webshare ****"
echo "****"
ssh mgiadmin@emnet "cd ${MGI_LIVE}/mgiconfig/bin; gen_webshare"

echo "****"
echo "**** emnet: Restart Searchtool ****"
echo "****"
ssh mgiadmin@emnet "${LOADADMIN}/jboss/${QS_SCRIPT} >& /dev/null"

echo "*************************************************************"
echo "REMEMBER to toggle the InactivePublic process control setting"
echo "*************************************************************"

exit 0