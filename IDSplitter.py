#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Program: ReadSplitter
Description: 
Version: 1.0
Author: Catrine Ahrens Høm
"""
import sys
import re
import gzip
from argparse import ArgumentParser

###########################################################################
# FUNCTIONS
###########################################################################

def CheckGZip(filename):
    '''
    This function checks if the input file is gzipped.
    '''
    gzipped_type = b'\x1f\x8b'
    
    infile = open(filename,'rb')
    filetype = infile.read(2)
    infile.close()
    if filetype == gzipped_type:
        return True
    else:
        return False
    
def OpenFile(filename,mode):
    '''
    This function opens the input file in chosen mode.
    '''
    try:
        if CheckGZip(filename):
            infile = gzip.open(filename,mode) 
        else:
            infile = open(filename,mode)   
    except IOError as error:
        sys.exit('Can\'t open file, reason:',str(error),'\n') 
    return infile



###########################################################################
# GET INPUT
###########################################################################

# Input from command line
parser = ArgumentParser()
parser.add_argument('-i', '--input', dest='input',help='Input file to find IDs from ".frag"')
parser.add_argument('-f', '--fastq', dest='fastq',help='Fastq file with raw reads')
parser.add_argument('-o', dest='o', help='Output filename')
args = parser.parse_args()

# Define input as variables
alignmentfrag = args.input
fastq = args.fastq
o = args.o

# Open log file
logname = o+"/"+o+".log"
logfile = OpenFile(logname,"a+") 

# Define ID pattern
ID_pattern = re.compile(b'\s([\w-]+)\srunid=')


# Open input file
infile = OpenFile(alignmentfrag,'rb')

# Open fastq file
fastq_infile = OpenFile(fastq,'rb')

 
# Open output file for matching reads:
match_outfilename = o+"/"+'match_IDs.fastq'
    
try:
    match_outfile = open(match_outfilename,'w')
except IOError as error:
    sys.stdout.write('Could not write file due to: '+str(error))
    sys.exit(1)

# Open output file for mot matching reads:    
nomatch_outfilename = o+"/"+'nomatch_IDs.fastq'
    
try:
    nomatch_outfile = open(nomatch_outfilename,'w')
except IOError as error:
    sys.stdout.write('Could not write file due to: '+str(error))
    sys.exit(1)
    
###########################################################################
# FIND IDS 
###########################################################################
    
# Make a set of IDs to make sure they are unique
ID_set = set()

# Search after ID and write dict
for line in infile:
    ID_result = re.search(ID_pattern,line)
    if ID_result != None: 
        ID_set.add('@'+ID_result.group(1).decode('ascii'))

# Check if any ID is found
if not ID_set:
    logfile.write('No IDs found in '+alignmentfrag+'!')
    print('No IDs found in '+alignmentfrag+'!')


###########################################################################
# WRITE RESULT TO FILE
###########################################################################

for line in fastq_infile:
    line = line.decode('ascii')
    if line[0] == '@':
        if line.split()[0] in ID_set:
            flag = True
        else:
            flag = False
    if flag == True:
        print(line,file=match_outfile, end = '')
    if flag == False:
        print(line,file=nomatch_outfile, end = '')

        


# Close files
nomatch_outfile.close()
match_outfile.close()         
infile.close()
fastq_infile.close()

