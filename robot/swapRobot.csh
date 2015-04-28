#!/bin/csh -f
#
#  swapRobot.csh
###########################################################################
#
#  Purpose:
#
#      This script will swap over to the inactive robot WI instance and
#      restart all the components on the various servers. It is intended
#      to be run from arnor and uses ssh calls to run scripts on other
#      servers.
#
#  Usage:
#
#      swapRobot.csh
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
#      3) Make sure the script is being run on arnor.
#      4) Determines which WI instance is inactive so it can identify the
#         correct Fewi server.
#      5) Runs scripts on the appropriate servers to swap/restart everything.
#
#  Notes:  None
#
###########################################################################

cd `dirname $0` && source ./Configuration

#
# Make sure this script wasn't run by accident.
#
echo -n "You are about to swap the robot WI. Confirm (yes/no) ? "
set answer = $<
if ( "$answer" != "yes" ) then
    exit 0
endif

#
# Make sure the script is being run on arnor.
#
if ( "`uname -n`" != "arnor" ) then
    echo "This script needs to be run on arnor"
    exit 1
endif

#
# Determine which WI instance is inactive.
#
cd ${MGI_LIVE}
set str=`ls -l wiinactive | sed "s/.*wibot/wibot/"`
if ( "$str" == "wibot1" ) then
    set NEW_INSTANCE="bot1"
    set FEWI="mgi-botfewi1"
else if ( "$str" == "wibot2" ) then
    set NEW_INSTANCE="bot2"
    set FEWI="mgi-botfewi2"
else
    echo "Cannot determine which WI instance is inactive"
    exit 1
endif

echo "****"
echo "**** Swap to ${NEW_INSTANCE} ****"
echo "****"

#
# Run scripts on arnor.
#
echo "****"
echo "**** arnor: Swap GlobalConfig ****"
echo "****"
cd ${MGI_LIVE}/webshare/config
mv GlobalConfig.old saveold
mv GlobalConfig GlobalConfig.old
mv saveold GlobalConfig

echo "****"
echo "**** arnor: Run gen_webshare ****"
echo "****"
cd ${MGI_LIVE}/mgiconfig/bin
gen_webshare

echo "****"
echo "**** arnor: Restart tomcat ****"
echo "****"
${MGI_LIVE}/loadadmin/bin/restartTomcat

echo "****"
echo "**** arnor: Swap Java WI cache ****"
echo "****"
cd ${MGI_LIVE}
mv javawi2.cache.old saveold
mv javawi2.cache javawi2.cache.old
mv saveold javawi2.cache
rm -rf /usr/local/mgi/live/javawi2.cache.old/*

echo "****"
echo "**** arnor: Update Python WI ****"
echo "****"
cd ${MGI_LIVE}/wiinactive/admin
gen_includes

echo "****"
echo "**** arnor: Swap Python WI ****"
echo "****"
cd ${MGI_LIVE}
mv wiinactive saveold
mv wicurrent wiinactive
mv saveold wicurrent

echo "****"
echo "**** arnor: Clean inactive Python WI ****"
echo "****"
${MGI_LIVE}/wiinactive/admin/cleanup tmp

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
ssh mgiadmin@emnet "${LOADADMIN}/jboss/restartSearchtool_robot >& /dev/null"

echo "************************************************************"
echo "REMEMBER to toggle the InactiveRobot process control setting"
echo "************************************************************"

exit 0
