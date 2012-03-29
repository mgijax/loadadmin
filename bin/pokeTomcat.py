#!/usr/local/bin/python

#
# Program: 
#
#	pokeTomcat.py
#
# Original Author:
#
#	Lori Corbani
#
# Purpose:
#
#	a) clear the memory cache
#	b) reload the config file 
#	c) suggest garbage collection
#	d) touch various pages to prime the javawi cache
#
# 	for the designated Tomcat server.
#
# Assumes:
#
#	ADMIN_URL1, ADMIN_URL2, ADMIN_URL3 are defined
#
# This is called from public/setWIdb.csh and is called
# after the Java WI config files are swapped.
#
# Modification History:
#
# 05/26/2006	lec
#	- new
# 05/28/2008	marka
#	- added priming functionality
#

import sys
import os
import httpReader

# clear cache, reload config, garbase collect
httpReader.getURL(os.environ['ADMIN_URL1'])
httpReader.getURL(os.environ['ADMIN_URL2'])
httpReader.getURL(os.environ['ADMIN_URL3'])
# refresh dio map for elsevier
httpReader.getURL('http://services.informatics.jax.org/doi/imageMap?id=refresh')

# urls to prime cache
host = 'http://www.informatics.jax.org'

pages = ['/javawi2/servlet/WIFetch?page=markerDetail&key=12184', 
	'/javawi2/servlet/WIFetch?page=markerGO&key=12184',
	'/javawi2/servlet/WIFetch?page=alleleDetail&key=37141',
	'/javawi2/servlet/WIFetch?page=glossaryTerm&key=x_chromosome',	
	'/javawi2/servlet/WIFetch?page=markerQF',
	'/javawi2/servlet/WIFetch?page=batchQF',
	'/javawi2/servlet/WIFetch?page=omimVocab&subset=A',
	'/javawi2/servlet/WIFetch?page=expressionQF',
	'/javawi2/servlet/WIFetch?page=expressionQFexpanded',
	'/javawi2/servlet/WIFetch?page=cDNAQF',
	'/javawi2/servlet/WIFetch?page=pirsfVocab&subset=S',
	'/javawi2/servlet/WIFetch?page=probeQF',
	'/javawi2/servlet/WIFetch?page=snpQF',
	'/javawi2/servlet/WIFetch?page=snpQF',
	'/javawi2/servlet/WIFetch?page=snpQF',
	'/javawi2/servlet/WIFetch?page=snpQF']

# prime the cache with the given urls
for req in pages:
	httpReader.getURL(host + req)
