#!/bin/csh -f
#
#  runTask.csh
###########################################################################
#
#  Purpose:
#
#      This wrapper is used to invoke all other scripts pertaining to the
#      weekly public/robot update process. It checks the "UpdateActive"
#      setting in the public process controller to see if the update
#      process is active. If it is active, the specified script is called
#      with its arguments. If it is not active, this wrapper just exits
#      and does not invoke the script.
#
#      This wrapper is invoked from a cron for each script that is part
#      of the weekly public/robot update process. Each cron is set to fire
#      when the script is expected to run, just as if the script was
#      being run from the cron itself.
#
#      This allows the weekly public/robot update process to be enabled or
#      disabled by changing one process controller setting, rather than
#      having to enable or disable crons for each individual script that
#      is part of the update process.
#
#  Usage:
#
#      runTask.csh  script  [arg(s)]
#
#      where
#
#          script = the full path to the script to run
#          arg(s) = zero or more arguments to pass to the script
#
#  Env Vars:
#
#      - See Configuration file (loadadmin product)
#
#      - See master.config.csh (mgiconfig product)
#
#  Inputs:
#
#      - Process control setting (UpdateActive) - should be yes or no
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
#      2) Determine if the weekly public/robot update process is active.
#      3) If it is not active, just exit.
#      4) If it is active, run the specified script with its arguments.
#
#  Notes:  None
#
###########################################################################

cd `dirname $0` && source ./Configuration

setenv UPDATE_ACTIVE `${PROC_CTRL_CMD_PUB}/getSetting ${SET_UPDATE_ACTIVE}`
if ( "${UPDATE_ACTIVE}" == "yes" ) then
    $*
else
    exit 0
endif

exit 0
