# ReadSplitter

<span style="color: red"> #Under development! </span>

ReadSplitter is a pipeline to find split a fastq file with reads from Nanopore MinION sequencing based on whether they map to your reference. 

## Requirements

- [KMA](https://bitbucket.org/genomicepidemiology/kma/src/master/) 

## Installation

The following instructions will install the latest version of ReadSplitter:

```
git clone https://github.com/catrinehom/ReadSplitter.git

cd ReadSplitter/

chmod a+x ReadSplitter.py
chmod a+x ErrorHandling.py
chmod a+x IDSplitter.py

```

### Move to bin 
You might want to move the program to your bin to make the program globally excecutable. 
The placement of your bin depends on your system configuration, but common paths is:

```
/usr/local/bin/
```
OR
```
~/bin/
```

Example of move to bin:

```
mv ReadSplitter.sh /usr/local/bin/
mv ErrorHandling.py /usr/local/bin/
mv IDSplitter.py /usr/local/bin/

```

## Usage

To run full pipeline:

```
./ReadSplitter.sh [-i <fastq filename>] [-r <references filename>] [-o <output filename>]
```

