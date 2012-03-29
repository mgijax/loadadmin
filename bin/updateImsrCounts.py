#!/usr/local/bin/python

# Program: updateImsrCounts.py
# Purpose: to update the IMSR counts in a front-end (fe) database
# Notes:
# 1. Counts are downloaded from a report in the IMSR web site
# 2. Counts are stored in the allele_imsr_counts table in the fe database

import sys
import os
import time
import httpReader
import pg_db

USAGE = '''Usage: %s
	1. Do not call directly.
	2. Instead, call wrapper shell script updateImsrCounts.csh.
''' % sys.argv[0]

###--- globals ---###

# time (in seconds) at which the script began
START = time.time()

# list of environment variables that we need to access
REQUIRED_PARAMETERS = [
	'IMSR_COUNT_URL',
	'IMSR_COUNT_TIMEOUT',
	'PG_FE_DBSERVER',
	'PG_FE_DBNAME',
	'PG_FE_DBUSER',
	'PG_FE_DBPASSWORDFILE',
	]

###--- functions ---###

def log (message):
	sys.stderr.write ('%7.3f : %s\n' % (time.time() - START, message))
	return

def bailout (message, showUsage = False):
	# Purpose: exit the script with an error message and a 1 exit code

	if showUsage:
		sys.stderr.write (USAGE)
	sys.stderr.write ('Error: %s\n' % message)
	sys.exit(1)

def checkEnvironment():
	# Purpose: to determine if we have the parameters we need in the 
	#	environment, and if not then exit with an error message

	badParms = []
	for parm in REQUIRED_PARAMETERS:
		if not os.environ.has_key (parm):
			badParms.append (parm)
	if badParms:
		bailout ('Could not find %s in the environment' % \
			','.join(badParms), True )

	log('Checked environment')
	return

def doDatabaseLogin():
	pg_db.useOneConnection(1)
	pg_db.set_sqlUser (os.environ['PG_FE_DBUSER'])
	pg_db.set_sqlPasswordFromPgpass (os.environ['PG_FE_DBPASSWORDFILE'])
	pg_db.set_sqlServer (os.environ['PG_FE_DBSERVER'])
	pg_db.set_sqlDatabase (os.environ['PG_FE_DBNAME'])

	try:
		results = pg_db.sql ('select count(1) from database_info')
	except:
		bailout ('Failed to query %s..%s as %s' % (
			os.environ['PG_FE_DBSERVER'],
			os.environ['PG_FE_DBNAME'],
			os.environ['PG_FE_DBUSER']))

	if len(results) != 1:
		bailout ('Bad results from %s..%s as %s' % (
			os.environ['PG_FE_DBSERVER'],
			os.environ['PG_FE_DBNAME'],
			os.environ['PG_FE_DBUSER']))

	log('Tested database login')
	return

def getDataFromImsr():
	# Purpose: read the data from a report available from the IMSR site
	# Returns: list of strings, each of which is a line from the report

	imsrUrl = os.environ['IMSR_COUNT_URL']
	imsrTimeout = int(os.environ['IMSR_COUNT_TIMEOUT'])

	(lines, err) = httpReader.getURL (imsrUrl, timeout = imsrTimeout)

	if not lines:
		sys.stderr.write ('IMSR_COUNT_URL: %s\n' % imsrUrl)
		sys.stderr.write ('IMSR_COUNT_TIMEOUT: %s\n' % imsrTimeout)

		if err:
			sys.stderr.write(err + '\n')
			bailout ('Failed to get counts from IMSR (%s)' % err)
		else:
			bailout ('Failed to get counts from IMSR')

	log ('Got %d lines from IMSR' % len(lines))
	return lines

def parseData(lines):
	# Purpose: parse the data in 'lines' and pull out the counts we need
	#	(while ignoring others that are present for KOMP)
	# Returns: tuple containing three dictionaries...
	#	( { allele ID : count of cell lines },
	#	  { allele ID : count of strains },
	#	  { marker ID : count of cell lines + strains for the marker's
	#		marker } )

	cellLines = {}
	strains = {}
	byMarker = {}

	for line in lines:

		# skip blank lines
		if len(line.strip()) == 0:
			continue

		items = line.split()

		# skip lines with too few fields
		if len(items) < 3:
			continue

		# add the count to the appropriate dictionary

		id = items[0]
		countType = items[1]
		count = int(items[2])

		if countType == 'ALL:ES':
			cellLines[id] = count
		elif countType == 'ALL:ST':
			strains[id] = count
		elif countType == 'MRK:UN':
			byMarker[id] = count

	log('Got %d alleles with cell lines' % len(cellLines))
	log('Got %d alleles with strains' % len(strains))
	log('Got %d markers with either' % len(byMarker))
	return cellLines, strains, byMarker

def getMarkerToAlleleMapping():
	# Purpose: to get a dictionary that maps from a marker ID to one or
	#	more associated allele IDs
	# Returns: dictionary like { marker id : [ allele id, ... ] }

	cmd = '''select m.primary_id as marker_id,
			a.primary_id as allele_id
		from marker m,
			marker_to_allele ma,
			allele a
		where m.marker_key = ma.marker_key
			and ma.allele_key = a.allele_key'''

	results = pg_db.sql(cmd)

	markerToAllele = {}
	for row in results:
		if markerToAllele.has_key(row['marker_id']):
			markerToAllele[row['marker_id']].append (
				row['allele_id'])
		else:
			markerToAllele[row['marker_id']] = [row['allele_id']]

	log('Mapped %d markers to alleles' % len(markerToAllele))
	return markerToAllele

def getAlleleIdToKeyMapping():
	# Purpose: to get a dictionary that maps from an allele ID to its key
	# Returns: dictionary like { allele id : allele key }

	cmd = 'select primary_id, allele_key from allele'

	results = pg_db.sql(cmd)

	idToKey = {}
	for row in results:
		idToKey[row['primary_id']] = row['allele_key']

	log('Mapped %d allele IDs to keys' % len(idToKey))
	return idToKey

def getCountsFromDatabase():
	# Purpose: to get a dictionary of the IMSR counts that already exist
	#	in the database
	# Returns: dictionary like { allele key : (cell line count,
	#	strain count, count for marker) }

	cmd = '''select allele_key, cell_line_count, strain_count,
			count_for_marker
		from allele_imsr_counts'''

	results = pg_db.sql(cmd)

	counts = {}
	for row in results:
		counts[row['allele_key']] = (row['cell_line_count'],
			row['strain_count'], row['count_for_marker'])

	log('Got old counts for %d alleles' % len(counts))
	return counts

def getNewCountsFromIMSR():
	# Purpose: to get a dictionary of the new counts from IMSR
	# Returns: dictionary like { allele key : (cell line count,
	#	strain count, count for marker) }

	cellLines, strains, byMarker = parseData (getDataFromImsr())
	markerToAlleles = getMarkerToAlleleMapping()
	idToKey = getAlleleIdToKeyMapping()

	allAlleles = {}		# allele key -> 1 (collecting all alleles)

	# convert the dictionary of marker-based data to instead be based on
	# allele keys
	
	kMarker = {}		# allele key -> count for its marker

	for (markerID, count) in byMarker.items():
		if not markerToAlleles.has_key(markerID):
			log('Unknown marker ID: %s' % markerID)
			continue

		for id in markerToAlleles[markerID]:
			if not idToKey.has_key(id):
				log('Unknown allele ID: %s' % id)
				continue

			kMarker[idToKey[id]] = count

			allAlleles[idToKey[id]] = 1

	# convert the dictionaries of ID-based data to instead be key-based

	kCellLines = {}
	kStrains = {}

	for (src, trgt) in [ (cellLines, kCellLines), (strains, kStrains) ] :
		for (id, count) in src.items():
			if not idToKey.has_key(id):
				log('Unknown allele ID: %s' % id)
				continue

			trgt[idToKey[id]] = count
			allAlleles[idToKey[id]] = 1

	# now collate the various counts into their final form

	final = {}	# allele key -> (cell lines, strains, for marker)

	keys = allAlleles.keys()
	keys.sort()

	for key in keys:
		cellLineCount = 0
		strainCount = 0
		markerCount = 0

		if kCellLines.has_key(key):
			cellLineCount = kCellLines[key]
		if kStrains.has_key(key):
			strainCount = kStrains[key]
		if kMarker.has_key(key):
			markerCount = kMarker[key]

		final[key] = (cellLineCount, strainCount, markerCount)

	log('Compiled counts for %d alleles' % len(final))
	return final

def applyDiff (oldCounts, newCounts):
	# Purpose: to make changes to the database which will bring the counts
	#	up to those found in 'newCounts'
	# Returns: (number of rows successfully updated, number that failed)

	toDelete = []	# allele keys to delete
	toAdd = []	# [ (allele key, cell lines, strains, markers), ... ]
	toUpdate = []	# [ (allele key, cell lines, strains, markers), ... ]

	# find those which need to be deleted or updated

	matches = 0

	for (key, (oldCellLines,oldStrains,oldMarkers)) in oldCounts.items():
		if not newCounts.has_key(key):
			toDelete.append(key)
			continue

		(newCellLines, newStrains, newMarkers) = newCounts[key]

		if (newCellLines != oldCellLines) or \
			(newStrains != oldStrains) or \
			(newMarkers != oldMarkers):
				toUpdate.append ( (key, newCellLines,
					newStrains, newMarkers) )
				log('%d | c %d:%d | s %d:%d | m %d:%d' % (
					key,
					oldCellLines, newCellLines,
					oldStrains, newStrains,
					oldMarkers, newMarkers) )
		else:
			matches = matches + 1

	log('Found %d that match' % matches)
	log('Found %d to delete' % len(toDelete))
	log('Found %d to update' % len(toUpdate))

	succeeded = 0
	allFailures = 0

	# find rows to add that were not in the database previously

	for key in newCounts.keys():
		if not oldCounts.has_key(key):
			(newCellLines, newStrains, newMarkers) = \
				newCounts[key]
			toAdd.append ( (key, newCellLines, newStrains,
				newMarkers) )

	log('Found %d to insert' % len(toAdd))

	# process rows to be deleted

	deleteCmd = 'delete from allele_imsr_counts where allele_key = %d'
	failures = 0
	for key in toDelete:
		try:
			pg_db.sql(deleteCmd % key)
		except:
			failures = failures + 1

	succeeded = succeeded + len(toDelete) - failures
	allFailures = allFailures + failures

	if toDelete:
		log('Processed %d deletes, %d failed' % (len(toDelete),
			failures) )

	# process rows to have their counts updated

	updateCmd = '''update allele_imsr_counts
		set cell_line_count = %d,
			strain_count = %d,
			count_for_marker = %d
		where allele_key = %d'''
	failures = 0
	for (key, cellLines, strains, markers) in toUpdate:
		try:
			pg_db.sql(updateCmd % (cellLines, strains,
				markers, key) )
		except:
			failures = failures + 1

	succeeded = succeeded + len(toUpdate) - failures
	allFailures = allFailures + failures

	if toUpdate:
		log('Processed %d updates, %d failed' % (len(toUpdate),
			failures) )

	# process rows to be added

	insertCmd = '''insert into allele_imsr_counts (allele_key,
			cell_line_count, strain_count, count_for_marker)
		values (%d, %d, %d, %d)'''
	for (key, cellLines, strains, markers) in toAdd:
		try:
			pg_db.sql(insertCmd % (key, cellLines, strains,
				markers) )
		except:
			failures = failures + 1

	succeeded = succeeded + len(toAdd) - failures
	allFailures = allFailures + failures

	if toAdd:
		log('Processed %d inserts, %d failed' % (len(toAdd),
			failures) )

	if succeeded:
		pg_db.commit()
		log('Committed changes')
	return succeeded, allFailures

###--- main program ---###

if __name__ == '__main__':

	checkEnvironment()
	doDatabaseLogin()
	oldCounts = getCountsFromDatabase()
	newCounts = getNewCountsFromIMSR()

	succeeded, failed = applyDiff (oldCounts, newCounts)

	if failed > 0:
		if succeeded > 0:
			bailout ('Partial failure: %d updated, %d failed' % (
				succeeded, failed) )
		else:
			bailout ('No rows updated: %d failed' % failed)

	elif succeeded > 0:
		log('Succeeded: %d rows updated' % succeeded)
	
	else:
		log('No changes needed; all alleles up to date')
