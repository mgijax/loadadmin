#!/bin/csh -f
#
#  buildQSIndexes.csh
###########################################################################
#
#  Purpose:
#
#      This script is a wrapper for creating the public Quick Search (QS)
#      indexes.
#
#  Usage:
#
#      buildQSIndexes.csh
#
#  Env Vars:
#
#      - See Configuration file (loadadmin product)
#
#      - See master.config.csh (mgiconfig product)
#
#  Inputs:  None
#
#  Outputs:
#
#      - Log file for the script (${LOG})
#
#      - Public index log files (${ST_PUB_LOGDIR})
#
#      - Public index tar file (${ST_PUB_TARFILE})
#
#      - Process control flags
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
#      2) Build the QS indexes for public.
#      3) Save the prior public log directory.
#      4) Save the new public log directory.
#      5) Save the prior public QS index tar file.
#      6) Create a tar file of the new public QS indexes.
#      7) Copy the public QS index tar file to the public/robot searchtool
#         server if it is different than the current server.
#      8) Set the flag to signal that the QS index tar file is ready for
#         the public load.
#      9) Set the flag to signal that the QS index tar file is ready for
#         the robot load.
#
#  Notes:  None
#
###########################################################################

cd `dirname $0` && source ./Configuration

setenv SCRIPT_NAME `basename $0`

setenv LOG ${LOGSDIR}/${SCRIPT_NAME}.log
rm -f ${LOG}
touch ${LOG}

echo "$0" >> ${LOG}
env | sort >> ${LOG}

#
# Build the QS indexes for public
#
date >>& ${LOG}
echo 'Build the QS indexes for public' >>& ${LOG}
cd ${SEARCHTOOL_DATADIR}
rm -rf ${SEARCHTOOL_LOGDIR}
rm -rf ${SEARCHTOOL_BUILDDIR}
${ST_INDEXER_PUB}/bin/makeIndexes >>& ${LOG}

#
# If there is anything in the exception log, it is considered a fatal error.
#
if ( ! -z ${SEARCHTOOL_LOGDIR}/exception.log ) then
    echo "${SCRIPT_NAME} failed" >>& ${LOG}
    date >>& ${LOG}
    exit 1
endif

#
# Save the prior public log directory.
#
date >>& ${LOG}
echo 'Save the prior public log directory' >>& ${LOG}
cd ${SEARCHTOOL_DATADIR}
rm -rf ${ST_PUB_LOGDIR}.old
if ( -d ${ST_PUB_LOGDIR} ) then
    mv ${ST_PUB_LOGDIR} ${ST_PUB_LOGDIR}.old
endif

#
# Save the new public log directory.
#
date >>& ${LOG}
echo 'Save the new public log directory' >>& ${LOG}
if ( -d ${SEARCHTOOL_LOGDIR} ) then
    mv ${SEARCHTOOL_LOGDIR} ${ST_PUB_LOGDIR}
endif

#
# Save the prior public QS index tar file.
#
date >>& ${LOG}
echo 'Save the prior public QS index tar file.' >>& ${LOG}
rm -f ${ST_PUB_TARFILE}.old
if ( -e ${ST_PUB_TARFILE} ) then
    mv ${ST_PUB_TARFILE} ${ST_PUB_TARFILE}.old
endif

#
# Create a tar file of the new public QS indexes.
#
date >>& ${LOG}
echo 'Create a tar file of the new public QS indexes' >>& ${LOG}
cd ${SEARCHTOOL_BUILDDIR}
tar cvf ${ST_PUB_TARFILE} * >>& ${LOG}
if ( $status != 0 ) then
    echo "${SCRIPT_NAME} failed" >>& ${LOG}
    date >>& ${LOG}
    exit 1
endif

#
# Copy the public QS index tar file to the server where the public/robot
# QS indexes should reside. This only needs to be done if it is a different
# server than the one where this script generated them.
#
if ( ${ST_PUB_SERVER} != ${SERVER_NAME} ) then
    date >>& ${LOG}
    echo "Copy the public QS index tar file to ${ST_PUB_SERVER}" >>& ${LOG}
    scp -q ${ST_PUB_TARFILE} ${ST_PUB_SERVER}:${SEARCHTOOL_DISTDIR}
    if ( $status != 0 ) then
        echo "${SCRIPT_NAME} failed" >>& ${LOG}
        date >>& ${LOG}
        exit 1
    endif
endif

#
# Set the "QS Index Tar File Ready" flag.
#
date >>& ${LOG}
echo 'Set process control flag: QS Index Tar File Ready' >>& ${LOG}
${PROC_CTRL_CMD_PUB}/setFlag ${NS_PUB_LOAD} ${FLAG_QS_TAR_FILE} ${SCRIPT_NAME}

#
# Set the "QS Index Tar File Ready" flag.
#
date >>& ${LOG}
echo 'Set process control flag: QS Index Tar File Ready' >>& ${LOG}
${PROC_CTRL_CMD_ROBOT}/setFlag ${NS_ROBOT_LOAD} ${FLAG_QS_TAR_FILE} ${SCRIPT_NAME}

echo "${SCRIPT_NAME} completed successfully" >>& ${LOG}
date >>& ${LOG}
exit 0
