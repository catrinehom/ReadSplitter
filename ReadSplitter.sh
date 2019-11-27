#!/usr/bin/env bash

#Program: ReadSplitter
#Description: This program can find ID corresponding to reads from a input references in your MinION data and split your fastq file based on that.
#Version: 1.0
#Author: Catrine Ahrens Høm

#Usage:
    ## ReadSplitter.sh [-i] <MinION reads in fastq format> [-r] <Reference(s) of wanted contigs in fasta format>
    ## -i, fastq path
    ## -r, reference path
    ## ID.txt will be available after run.
    ## match_ID.fastq and nomatch_ID.fastq after run.

#This pipeline consists of 5 steps:
    ## STEP 1:  Unicycler (Skipped if assembly file is supplied)
    ## STEP 2:  Find the contigs which match references
    ## STEP 3:  Choose these contigs in fasta format
    ## STEP 4:  Align fastq reads against contigs
    ## STEP 5:  Find IDs for aligned fastq reads


###########################################################################
# GET INPUT
###########################################################################
# load an enviroment (to be deleted in final pipeline)
source activate unicycler_v0.4.7_no_stall

# Start timer for logfile
SECONDS=0

# How to use program
usage() { echo "Usage: $0 [-i <fastq filename>] [-r <references filename>] [-o <outputname>]" 1>&2; exit 1; }


# Parse flags
while getopts ":i:r:o:h" opt; do
    case "${opt}" in
        i)
            i=${OPTARG}
            ;;
        r)
            r=${OPTARG}
            ;;
        o)
            o=${OPTARG}
            ;;
        h)
            usage
            ;;
        *)
            echo "Invalid option: ${OPTARG}"
            usage
            ;;
    esac
done
shift $((OPTIND-1))

# Check if required flags are empty
if [ -z "${i}" ] || [ -z "${r}" ] || [ -z "${o}" ]; then
    echo "i, r and o are required flags"
    usage
fi


# Make output directory
[ -d $o ] && echo "Output directory: ${o} already exists. Files will be overwritten." || mkdir $o

# Make logfile and empty it
touch ${o}/${o}.log
cat /dev/null > ${o}/${o}.log

date=$(date '+%Y-%m-%d %H:%M:%S')
echo ""
echo "" >> ${o}/${o}.log
echo "Starting ReadSplitter ($date)"
echo "Starting ReadSplitter ($date)" >> ${o}/${o}.log
echo "---------------------------------------------"
echo "---------------------------------------------" >> ${o}/${o}.log
echo "ReadSplitter is a pipeline to find read ID's from reads from Nanopore MinION sequencing matching input references and split your fastq file based on that."
echo "ReadSplitter is a pipeline to find read ID's from reads from Nanopore MinION sequencing matching input references and split your fastq file based on that." >> ${o}/${o}.log
echo ""
echo "" >> ${o}/${o}.log

# Check format and that the files exists
./ErrorHandling.py -i $i -r $r -o $o

# Check if python script exited with an error
if [ $? -eq 0 ]
then
  echo "Error handling of input done."
  echo "Error handling of input done." >> ${o}/${o}.log
else
  # Redirect stdout from echo command to stderr.
  echo "Script exited due to input error."
  echo "Script exited due to input error." >> ${o}/${o}.log
  exit 1
fi

# Print files used
echo "Input used is ${i}"
echo "References used is ${r}"
echo "Input used is ${i}" >> ${o}/${o}.log
echo "References used is ${r}" >> ${o}/${o}.log

echo "Time stamp: $SECONDS seconds."
echo "Time stamp: $SECONDS seconds." >> ${o}/${o}.log
echo ""
echo "" >> ${o}/${o}.log

###########################################################################
# STEP 1:  KMA READS AGAINST CONTIGS
###########################################################################

echo "Starting STEP 1: KMA reads against contigs."
echo "Starting STEP 1: KMA reads against contigs." >> ${o}/${o}.log

mkdir $o/databases

#Command used to index plasmid database:
kma index -i $r -o $o/databases/reads_database

#Command to run KMA:
kma -i $i -o $o/reads_alignment -t_db $o/databases/reads_database -mrs 0.1 -bcNano -mp 20 -mem_mode

echo "Time stamp: $SECONDS seconds."
echo "Time stamp: $SECONDS seconds." >> ${o}/${o}.log
echo ""
echo "" >> ${o}/${o}.log

###########################################################################
# STEP 2:  FIND IDs AND SPLIT
###########################################################################

echo "Starting STEP 2: Find IDs"
echo "Starting STEP 2: Find IDs" >> ${o}/${o}.log

./IDSplitter.py -i $o/reads_alignment.frag.gz -f $i -o $o

# Check if python script exited with an error
if [ $? -eq 0 ]
then
  echo "IDs found! match_ID.fastq and nomatch_ID.fastq are saved in ${o} directory."
  echo "IDs found! match_ID.fastq and nomatch_ID.fastq are saved in ${o} directory." >> ${o}/${o}.log
else
  echo "No IDs found! No match_ID.fastq is made, your original file is all the no match fastq."
  echo "No IDs found! No match_ID.fastq is made, your original file is all the no match fastq." >> ${o}/${o}.log
fi

echo "Time stamp: $SECONDS seconds."
echo "Time stamp: $SECONDS seconds." >> ${o}/${o}.log
