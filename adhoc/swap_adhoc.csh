#!/bin/csh -f
#
#  load_adhoc.csh
###########################################################################
#
#  Purpose:
#
#      This script swaps the active/inactive database by renaming them.
#
#  Usage:
#
#      swap_adhoc.csh
#
#  Env Vars:
#
#      - See configuration file (adhoc.config)
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
#      This script will perform following steps:
#
#      1) Source the configuration file to establish the environment.
#      2) Rename the active adhoc database with a temporary name. If this
#         fails (e.g. open connection), abort the swap.
#      3) Rename the newly loaded database to be the active database.
#      4) Rename the temporary database to be the load database for the
#         next update.
#
#  Notes:  None
#
###########################################################################

cd `dirname $0` && source ./adhoc.config

#
# Swap the active and inactive databases. If the active database cannot be
# renamed, do not continue with the swap. This will happen if there are
# users with open connections to the database.
#
echo "Rename ${PGMGD_ACTIVE_DB} to ${PGMGD_TEMP_DB}"
psql -q -w -d ${PGMGD_CONNECT_DB} -U ${PGMGD_DBUSER} -c "alter database ${PGMGD_ACTIVE_DB} rename to ${PGMGD_TEMP_DB}"
if ( $status != 0 ) then
    exit 1
endif

echo "Rename ${PGMGD_INACTIVE_DB} to ${PGMGD_ACTIVE_DB}"
psql -q -w -d ${PGMGD_CONNECT_DB} -U ${PGMGD_DBUSER} -c "alter database ${PGMGD_INACTIVE_DB} rename to ${PGMGD_ACTIVE_DB}"
echo "Rename ${PGMGD_TEMP_DB} to ${PGMGD_INACTIVE_DB}"
psql -q -w -d ${PGMGD_CONNECT_DB} -U ${PGMGD_DBUSER} -c "alter database ${PGMGD_TEMP_DB} rename to ${PGMGD_INACTIVE_DB}"

exit 0
