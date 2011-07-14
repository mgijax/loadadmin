#!/bin/csh -x -f

#
# Drops all editors and progs users from database
#

cd `dirname $0` && source ./Configuration

if ( ${#argv} < 2 ) then
	echo "Usage: $0 DBSERVER DBNAME"
	exit 0
endif

setenv DBSERVER  $1
setenv DBNAME $2

cat - <<EOSQL | doisql.csh ${DBSERVER} ${DBNAME} $0

use ${DBNAME}
go

select name
into tempdb..username
from sysusers
where suid > 0
and gid in (select uid from sysusers where name in ('editors', 'progs'))
go

declare userCursor cursor for
select name
from tempdb..username
for read only
go

declare @userName varchar(30)

open userCursor

fetch userCursor into @userName

while (@@sqlstatus = 0)
begin
	execute sp_dropuser @userName
        fetch userCursor into @userName
end
go

close userCursor
deallocate cursor userCursor
go

drop table tempdb..username
go

EOSQL
