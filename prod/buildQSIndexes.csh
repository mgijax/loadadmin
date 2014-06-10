#!/bin/csh -f
#
#  buildQSIndexes.csh
###########################################################################
#
#  Purpose:
#
#      This script is a wrapper for creating the production and/or public
#      Quick Search (QS) indexes.
#
#  Usage:
#
#      buildQSIndexes.csh  [ NOPROD | NOPUB ]
#
#      where
#          NOPROD = optional flag to skip the production indexes
#          NOPUB = optional flag to skip the public indexes
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
#      - Production index log files (${ST_PROD_LOGDIR})
#
#      - Production index tar file (${ST_PROD_TARFILE})
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
#      2) Check the arguments to the script to see if the production or
#         public indexes should be skipped.
#      3) If the production QS indexes need to be generated:
#          1) Build the QS indexes for production.
#          2) Save the prior production log directory.
#          3) Save the new production log directory.
#          4) Save the prior production QS index tar file.
#          5) Create a tar file of the new production QS indexes.
#          6) Copy the production QS index tar file to the production
#             searchtool server if it is different than the current server.
#          7) Set the flag to signal that the QS index tar file is ready for
#             the production load.
#      4) If the public QS indexes need to be generated:
#          1) Build the QS indexes for public.
#          2) Save the prior public log directory.
#          3) Save the new public log directory.
#          4) Save the prior public QS index tar file.
#          5) Create a tar file of the new public QS indexes.
#          6) Copy the public QS index tar file to the public/robot searchtool
#             server if it is different than the current server.
#          7) Set the flag to signal that the QS index tar file is ready for
#             the public load.
#          8) Set the flag to signal that the QS index tar file is ready for
#             the robot load.
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

setenv DO_PROD_INDEXES 1
setenv DO_PUB_INDEXES 1

#
# Check the arguments to the script to see if the production or public
# indexes should be skipped. The default is to run both.
#
foreach ARG (${argv})
    if ( ${ARG} == "NOPROD" ) then
        setenv DO_PROD_INDEXES 0
    else if ( ${ARG} == "NOPUB" ) then
        setenv DO_PUB_INDEXES 0
    else
        echo "Usage: ${SCRIPT_NAME} [ NOPROD | NOPUB ]" | tee -a ${LOG}
        exit 1
    endif
end

if ( ${DO_PROD_INDEXES} == 0 && ${DO_PUB_INDEXES} == 0 ) then
    echo 'Found NOPROD and NOPUB options. Skipping build' | tee -a ${LOG}
    exit 1
endif

#
# Perform the production build steps, if applicable.
#
if ( ${DO_PROD_INDEXES} == 1 ) then

    #
    # Build the QS indexes for production
    #
    date >>& ${LOG}
    echo 'Build the QS indexes for production' >>& ${LOG}
    cd ${SEARCHTOOL_DATADIR}
    rm -rf ${SEARCHTOOL_LOGDIR}
    rm -rf ${SEARCHTOOL_BUILDDIR}
    ${ST_INDEXER_PROD}/bin/makeIndexes >>& ${LOG}

    #
    # If there is anything in the exception log, it is considered a fatal error.
    #
    if ( ! -z ${SEARCHTOOL_LOGDIR}/exception.log ) then
        echo "${SCRIPT_NAME} failed" >>& ${LOG}
        date >>& ${LOG}
        exit 1
    endif

    #
    # Save the prior production log directory.
    #
    date >>& ${LOG}
    echo 'Save the prior production log directory' >>& ${LOG}
    cd ${SEARCHTOOL_DATADIR}
    rm -rf ${ST_PROD_LOGDIR}.old
    if ( -d ${ST_PROD_LOGDIR} ) then
        mv ${ST_PROD_LOGDIR} ${ST_PROD_LOGDIR}.old
    endif

    #
    # Save the new production log directory.
    #
    date >>& ${LOG}
    echo 'Save the new production log directory' >>& ${LOG}
    if ( -d ${SEARCHTOOL_LOGDIR} ) then
        mv ${SEARCHTOOL_LOGDIR} ${ST_PROD_LOGDIR}
    endif

    #
    # Save the prior production QS index tar file.
    #
    date >>& ${LOG}
    echo 'Save the prior production QS index tar file.' >>& ${LOG}
    rm -f ${ST_PROD_TARFILE}.old
    if ( -e ${ST_PROD_TARFILE} ) then
        mv ${ST_PROD_TARFILE} ${ST_PROD_TARFILE}.old
    endif

    #
    # Create a tar file of the new production QS indexes.
    #
    date >>& ${LOG}
    echo 'Create a tar file of the new production QS indexes' >>& ${LOG}
    cd ${SEARCHTOOL_BUILDDIR}
    tar cvf ${ST_PROD_TARFILE} * >>& ${LOG}
    if ( $status != 0 ) then
        echo "${SCRIPT_NAME} failed" >>& ${LOG}
        date >>& ${LOG}
        exit 1
    endif

    #
    # Copy the production QS index tar file to the server where the production
    # QS indexes should reside. This only needs to be done if it is a different
    # server than the one where this script generated them.
    #
    if ( ${ST_PROD_SERVER} != ${SERVER_NAME} ) then
        date >>& ${LOG}
        echo "Copy the production QS index tar file to ${ST_PROD_SERVER}" >>& ${LOG}
        scp -q ${ST_PROD_TARFILE} ${ST_PROD_SERVER}:${SEARCHTOOL_DISTDIR}
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
    ${PROC_CTRL_CMD_PROD}/setFlag ${NS_PROD_LOAD} ${FLAG_QS_TAR_FILE} ${SCRIPT_NAME}

endif # End of production QS index build

#
# Perform the public build steps, if applicable.
#
if ( ${DO_PUB_INDEXES} == 1 ) then

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

endif # End of public QS index build

echo "${SCRIPT_NAME} completed successfully" >>& ${LOG}
date >>& ${LOG}
exit 0
