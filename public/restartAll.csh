#!/bin/csh -f
#
#  restartAll.csh
###########################################################################
#
#  Purpose:
#
#      This script will restart all the components of the active public WI
#      instance. It is intended to be run from gondor and uses ssh calls to
#      run scripts on other servers.
#
#  Usage:
#
#      restartAll.csh
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
#      4) Determines which WI instance is active so it can identify the
#         correct Fewi server and QS restart script.
#      5) Runs scripts on the appropriate servers to restart everything.
#
#  Notes:  None
#
###########################################################################

cd `dirname $0` && source ./Configuration

#
# Make sure this script wasn't run by accident.
#
echo -n "You are about to restart all public WI components. Confirm (yes/no) ? "
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
# Determine which WI instance is active.
#
cd ${MGI_LIVE}
set str=`ls -l wicurrent | sed "s/.*wipub/wipub/"`
if ( "$str" == "wipub1" ) then
    set FEWI="mgi-pubfewi1"
    set QS_SCRIPT="restartSearchtool_pub1"
else if ( "$str" == "wipub2" ) then
    set FEWI="mgi-pubfewi2"
    set QS_SCRIPT="restartSearchtool_pub2"
else
    echo "Cannot determine which WI instance is active"
    exit 1
endif

#
# Run scripts on gondor.
#
echo "****"
echo "**** gondor: Run gen_webshare ****"
echo "****"
cd ${MGI_LIVE}/mgiconfig/bin
gen_webshare

echo "****"
echo "**** gondor: Restart tomcat ****"
echo "****"
${MGI_LIVE}/loadadmin/bin/restartTomcat

#
# Run scripts on the active Fewi.
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

exit 0
