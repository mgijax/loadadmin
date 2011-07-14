#!/bin/csh -f
#
#  build_indexes.csh
###########################################################################
#
#  Purpose:
#
#      This script is a wrapper for creating the production and public
#      Lucene indexes.
#
#  Usage:
#
#      build_indexes.csh  [ NOPROD | NOPUB ]
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
#  Inputs:
#
#      - MGD database backup files (from /lindon/sybase)
#
#      - Process control flags
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
#      This script will perform following steps:
#
#      1) Source the configuration file to establish the environment.
#      2) Check the arguments to the script to see if the production or
#         public indexes should be skipped.
#      3) Wait for the flag to signal that the MGD backup is available.
#      4) Load the MGD database.
#      5) If the production indexes need to be generated:
#          1) Build the indexes for production (with private data).
#          2) Save the prior production log directory.
#          3) Save the new production log directory.
#          4) Save the prior production index tar file.
#          5) Create a tar file of the new production indexes.
#          6) Copy the production index tar file to the production searchtool
#             server if it is different than the current server.
#          7) Set the flag to signal that the production indexes can be loaded.
#      6) If the public indexes need to be generated:
#          1) Delete the private data from the MGD database.
#          2) Build the indexes for public (without private data).
#          3) Save the prior public log directory.
#          4) Save the new public log directory.
#          5) Save the prior public index tar file.
#          6) Create a tar file of the new public indexes.
#          7) Copy the public index tar file to the public/robot searchtool
#             server if it is different than the current server.
#          8) Set the flag to signal that the public indexes can be loaded.
#          9) Set the flag to signal that the robot indexes can be loaded.
#
#  Notes:  None
#
###########################################################################

cd `dirname $0` && source ./Configuration

setenv SCRIPT_NAME `basename $0`

setenv MGD_BACKUP /lindon/sybase/mgd.backup

setenv LOG ${LOGSDIR}/${SCRIPT_NAME}.log
rm -f ${LOG}
touch ${LOG}

echo "$0" | tee -a ${LOG}
env | sort | tee -a ${LOG}

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
# Wait for the "MGD Backup Ready" flag to be set. Stop waiting if the number
# of retries expires or the abort flag is found.
#
date | tee -a ${LOG}
echo 'Wait for the "MGD Backup Ready" flag to be set' | tee -a ${LOG}

setenv RETRY ${PROC_CTRL_RETRIES}
while (${RETRY} > 0)
    setenv READY `${PROC_CTRL_CMD_PROD}/getFlag ${NS_PROD_LOAD} ${FLAG_MGD_BACKUP}`
    setenv ABORT `${PROC_CTRL_CMD_PROD}/getFlag ${NS_PROD_LOAD} ${FLAG_ABORT}`

    if (${READY} == 1 || ${ABORT} == 1) then
        break
    else
        sleep ${PROC_CTRL_WAIT_TIME}
    endif

    setenv RETRY `expr ${RETRY} - 1`
end

#
# Terminate the script if the number of retries expired or the abort flag
# was found.
#
if (${RETRY} == 0) then
   echo "${SCRIPT_NAME} timed out" | tee -a ${LOG}
   date | tee -a ${LOG}
   exit 1
else if (${ABORT} == 1) then
   echo "${SCRIPT_NAME} aborted by process controller" | tee -a ${LOG}
   date | tee -a ${LOG}
   exit 1
endif

#
# Clear the "MGD Backup Ready" flag.
#
date | tee -a ${LOG}
echo 'Clear process control flag: MGD Backup Ready' | tee -a ${LOG}
${PROC_CTRL_CMD_PROD}/clearFlag ${NS_PROD_LOAD} ${FLAG_MGD_BACKUP} ${SCRIPT_NAME}

#
# Load MGD database from backup.
#
date | tee -a ${LOG}
echo 'Load MGD database' | tee -a ${LOG}
${MGI_DBUTILS}/bin/load_db.csh ${MGDBE_DBSERVER} ${MGDBE_DBNAME} ${MGD_BACKUP}
if ( $status != 0 ) then
    echo "${SCRIPT_NAME} failed" | tee -a ${LOG}
    date | tee -a ${LOG}
    exit 1
endif

#
# Perform the production build steps, if applicable.
#
if ( ${DO_PROD_INDEXES} == 1 ) then

    #
    # Build the Lucene indexes for production (with private data).
    #
    date | tee -a ${LOG}
    echo 'Build the Lucene indexes for production' | tee -a ${LOG}
    cd ${SEARCHTOOL_DATADIR}
    rm -rf ${SEARCHTOOL_LOGDIR}
    rm -rf ${SEARCHTOOL_BUILDDIR}
    ${SEARCHTOOL_INDEXER}/bin/makeIndexes

    #
    # If there is anything in the exception log, it is considered a fatal error.
    #
    if ( ! -z ${SEARCHTOOL_LOGDIR}/exception.log ) then
        echo "${SCRIPT_NAME} failed" | tee -a ${LOG}
        date | tee -a ${LOG}
        exit 1
    endif

    #
    # Save the prior production log directory.
    #
    date | tee -a ${LOG}
    echo 'Save the prior production log directory' | tee -a ${LOG}
    cd ${SEARCHTOOL_DATADIR}
    rm -rf ${ST_PROD_LOGDIR}.old
    if ( -d ${ST_PROD_LOGDIR} ) then
        mv ${ST_PROD_LOGDIR} ${ST_PROD_LOGDIR}.old
    endif

    #
    # Save the new production log directory.
    #
    date | tee -a ${LOG}
    echo 'Save the new production log directory' | tee -a ${LOG}
    if ( -d ${SEARCHTOOL_LOGDIR} ) then
        mv ${SEARCHTOOL_LOGDIR} ${ST_PROD_LOGDIR}
    endif

    #
    # Save the prior production index tar file.
    #
    date | tee -a ${LOG}
    echo 'Save the prior production index tar file.' | tee -a ${LOG}
    rm -f ${ST_PROD_TARFILE}.old
    if ( -e ${ST_PROD_TARFILE} ) then
        mv ${ST_PROD_TARFILE} ${ST_PROD_TARFILE}.old
    endif

    #
    # Create a tar file of the new production indexes.
    #
    date | tee -a ${LOG}
    echo 'Create a tar file of the new production indexes' | tee -a ${LOG}
    cd ${SEARCHTOOL_BUILDDIR}
    tar cvf ${ST_PROD_TARFILE} *
    if ( $status != 0 ) then
        echo "${SCRIPT_NAME} failed" | tee -a ${LOG}
        date | tee -a ${LOG}
        exit 1
    endif

    #
    # Copy the production index tar file to the server where the production
    # indexes should reside. This only needs to be done if it is a different
    # server than the one where this script generated them.
    #
    if ( ${ST_PROD_SERVER} != ${SERVER_NAME} ) then
        date | tee -a ${LOG}
        echo "Copy the production index tar file to ${ST_PROD_SERVER}" | tee -a ${LOG}
        scp ${ST_PROD_TARFILE} ${ST_PROD_SERVER}:${SEARCHTOOL_DISTDIR}
        if ( $status != 0 ) then
            echo "${SCRIPT_NAME} failed" | tee -a ${LOG}
            date | tee -a ${LOG}
            exit 1
        endif
    endif

    #
    # Set the "Index Tar File Ready" flag.
    #
    date | tee -a ${LOG}
    echo 'Set process control flag: Index Tar File Ready' | tee -a ${LOG}
    ${PROC_CTRL_CMD_PROD}/setFlag ${NS_PROD_LOAD} ${FLAG_INDEX_TAR_FILE} ${SCRIPT_NAME}

endif # End of production index build

#
# Perform the public build steps, if applicable.
#
if ( ${DO_PUB_INDEXES} == 1 ) then

    #
    # Create a temp file that will be used to capture errors that occur within
    # the isql block.
    #
    setenv TMP_FILE /tmp/${SCRIPT_NAME}.$$
    rm -f ${TMP_FILE}
    touch ${TMP_FILE}

    #
    # Delete private data from the MGD database.
    #
    date | tee -a ${LOG}
    echo 'Delete private data from the MGD database' | tee -a ${LOG}
cat - <<EOSQL | doisql.csh ${MGDBE_DBSERVER} ${MGDBE_DBNAME} $0 | tee -a ${TMP_FILE}

exec MGI_deletePrivateData

if @@error != 0 print "ERROR Detected"
go

checkpoint
go

EOSQL

    #
    # If there are any errors detected from within the isql block, terminate the
    # script with a non-zero exit code.
    #
    if ( "`cat ${TMP_FILE} | grep -c '^ERROR'`" != "0" ) then
        echo "${SCRIPT_NAME} failed" | tee -a ${LOG}
        date | tee -a ${LOG}
        rm -f ${TMP_FILE}
        exit 1
    endif
    rm -f ${TMP_FILE}

    #
    # Build the Lucene indexes for public (without private data).
    #
    date | tee -a ${LOG}
    echo 'Build the Lucene indexes for public' | tee -a ${LOG}
    cd ${SEARCHTOOL_DATADIR}
    rm -rf ${SEARCHTOOL_LOGDIR}
    rm -rf ${SEARCHTOOL_BUILDDIR}
    ${SEARCHTOOL_INDEXER}/bin/makeIndexes

    #
    # If there is anything in the exception log, it is considered a fatal error.
    #
    if ( ! -z ${SEARCHTOOL_LOGDIR}/exception.log ) then
        echo "${SCRIPT_NAME} failed" | tee -a ${LOG}
        date | tee -a ${LOG}
        exit 1
    endif

    #
    # Save the prior public log directory.
    #
    date | tee -a ${LOG}
    echo 'Save the prior public log directory' | tee -a ${LOG}
    cd ${SEARCHTOOL_DATADIR}
    rm -rf ${ST_PUB_LOGDIR}.old
    if ( -d ${ST_PUB_LOGDIR} ) then
        mv ${ST_PUB_LOGDIR} ${ST_PUB_LOGDIR}.old
    endif

    #
    # Save the new public log directory.
    #
    date | tee -a ${LOG}
    echo 'Save the new public log directory' | tee -a ${LOG}
    if ( -d ${SEARCHTOOL_LOGDIR} ) then
        mv ${SEARCHTOOL_LOGDIR} ${ST_PUB_LOGDIR}
    endif

    #
    # Save the prior public index tar file.
    #
    date | tee -a ${LOG}
    echo 'Save the prior public index tar file.' | tee -a ${LOG}
    rm -f ${ST_PUB_TARFILE}.old
    if ( -e ${ST_PUB_TARFILE} ) then
        mv ${ST_PUB_TARFILE} ${ST_PUB_TARFILE}.old
    endif

    #
    # Create a tar file of the new public indexes.
    #
    date | tee -a ${LOG}
    echo 'Create a tar file of the new public indexes' | tee -a ${LOG}
    cd ${SEARCHTOOL_BUILDDIR}
    tar cvf ${ST_PUB_TARFILE} *
    if ( $status != 0 ) then
        echo "${SCRIPT_NAME} failed" | tee -a ${LOG}
        date | tee -a ${LOG}
        exit 1
    endif

    #
    # Copy the public index tar file to the server where the public/robot
    # indexes should reside. This only needs to be done if it is a different
    # server than the one where this script generated them.
    #
    if ( ${ST_PUB_SERVER} != ${SERVER_NAME} ) then
        date | tee -a ${LOG}
        echo "Copy the public index tar file to ${ST_PUB_SERVER}" | tee -a ${LOG}
        scp ${ST_PUB_TARFILE} ${ST_PUB_SERVER}:${SEARCHTOOL_DISTDIR}
        if ( $status != 0 ) then
            echo "${SCRIPT_NAME} failed" | tee -a ${LOG}
            date | tee -a ${LOG}
            exit 1
        endif
    endif

    #
    # Set the "Index Tar File Ready" flag.
    #
    date | tee -a ${LOG}
    echo 'Set process control flag: Index Tar File Ready' | tee -a ${LOG}
    ${PROC_CTRL_CMD_PUB}/setFlag ${NS_PUB_LOAD} ${FLAG_INDEX_TAR_FILE} ${SCRIPT_NAME}

    #
    # Set the "Index Tar File Ready" flag.
    #
    date | tee -a ${LOG}
    echo 'Set process control flag: Index Tar File Ready' | tee -a ${LOG}
    ${PROC_CTRL_CMD_ROBOT}/setFlag ${NS_ROBOT_LOAD} ${FLAG_INDEX_TAR_FILE} ${SCRIPT_NAME}

endif # End of public index build

echo "${SCRIPT_NAME} completed successfully" | tee -a ${LOG}
date | tee -a ${LOG}
exit 0
