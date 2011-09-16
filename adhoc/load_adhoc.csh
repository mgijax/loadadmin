#!/bin/csh -f
#
#  load_adhoc.csh
###########################################################################
#
#  Purpose:
#
#      This script is a wrapper for loading the adhoc database. It waits
#      for the Postgres backup file to be available and loads the inactive
#      Postgres database. Then it swaps the active/inactive database by
#      renaming them.
#
#  Usage:
#
#      load_adhoc.csh
#
#  Env Vars:
#
#      - See configuration file (adhoc.config)
#
#  Inputs:
#
#      - Postgres backup file (${BACKUP_FILE})
#
#        /export/upload/mgd.postgres.dump
#
#      - Backup-ready flag (${BACKUP_FLAG})
#
#        /export/upload/mgd.postgres.flag
#
#  Outputs:
#
#      - Log file for the script (${LOG})
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
#      2) Wait for the flag to signal that the backup is available.
#      3) Drop/create the mgd schema in the inactive database.
#      4) Load the mgd schema in the inactive database.
#      5) Grant permissions.
#      6) Swap the active and inactive databases. If the swap attempt
#         fails, it will retry several times.
#
#  Notes:  None
#
###########################################################################

cd `dirname $0` && source ./adhoc.config

setenv SCRIPT_NAME `basename $0`

setenv LOG `pwd`/${SCRIPT_NAME}.log
rm -f ${LOG}
touch ${LOG}

echo "$0" | tee -a ${LOG}
env | sort | tee -a ${LOG}

#
# Wait for the Postgres backup file to be available.
# 
date | tee -a ${LOG}
echo 'Wait for the Postgres backup file to be available' | tee -a ${LOG}

setenv RETRY ${RETRIES}
while ( ${RETRY} > 0 )
    if ( -e ${BACKUP_FLAG} ) then
        break
    else
        sleep ${WAIT_TIME}
    endif
    
    setenv RETRY `expr ${RETRY} - 1`
end

if ( ${RETRY} == 0 ) then
    echo "${SCRIPT_NAME} timed out" | tee -a ${LOG}
    date | tee -a ${LOG} 
    exit 1 
endif

#
# Remove the backup flag.
# 
date | tee -a ${LOG}
echo "Remove the backup flag (${BACKUP_FLAG})" | tee -a ${LOG}
rm -f ${BACKUP_FLAG}

#
# Drop/create the mgd schema in the inactive database.
#
date | tee -a ${LOG}
echo "Drop/create the mgd schema in the inactive database (${PGMGD_INACTIVE_DB})" | tee -a ${LOG}
psql -q -w -d ${PGMGD_INACTIVE_DB} -U ${PGMGD_DBUSER} << EOF
    drop schema if exists ${PGMGD_SCHEMA} cascade;
    create schema ${PGMGD_SCHEMA};
EOF

#
# Load the mgd schema in the inactive database.
#
date | tee -a ${LOG}
echo "Load the mgd schema in the inactive database (${PGMGD_INACTIVE_DB})" | tee -a ${LOG}
echo '------------------------------------------------------------' >> ${LOG}
pg_restore -d ${PGMGD_INACTIVE_DB} -n ${PGMGD_SCHEMA} -j ${PROCESSES} -O -U ${PGMGD_DBUSER} -v ${BACKUP_FILE} >>& ${LOG}
echo "Return status = $status" | tee -a ${LOG}
echo '------------------------------------------------------------' >> ${LOG}

#
# Grant permissions.
#
date | tee -a ${LOG}
echo "Grant permissions" | tee -a ${LOG}
psql -q -w -d ${PGMGD_INACTIVE_DB} -U ${PGMGD_DBUSER} << EOF
    grant usage on schema ${PGMGD_SCHEMA} to read_only_users;
    grant select on all tables in schema ${PGMGD_SCHEMA} to read_only_users;
EOF

#
# Swap the active and inactive databases. Make several attempts to complete
# the swap, with a delay between each attempt. If there are any open
# connections to the database, hopefully this will give them time to close
# and allow the swap to complete.
#
date | tee -a ${LOG}
echo "Swap the active and inactive databases" | tee -a ${LOG}
setenv RETRY ${SWAP_ATTEMPTS}
while ( ${RETRY} > 0 )
    ./swap_adhoc.csh | tee -a ${LOG}
    if ( $status == 0 ) then
        break
    else
        echo "Wait and retry ..." | tee -a ${LOG}
        sleep ${WAIT_TIME}
    endif

    setenv RETRY `expr ${RETRY} - 1`
end

if ( ${RETRY} == 0 ) then
    echo "${SCRIPT_NAME} timed out" | tee -a ${LOG}
    date | tee -a ${LOG}
    exit 1
endif

echo "${SCRIPT_NAME} completed successfully" | tee -a ${LOG}
date | tee -a ${LOG}
exit 0
