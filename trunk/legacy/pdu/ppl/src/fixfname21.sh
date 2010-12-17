#
#
#				DISCLAIMER
#
#   THE FOLLOWING PROGRAM IS CONSIDERED UNOFFICIAL AND IS TO BE USED
#   AS AN EXAMPLE ONLY. THIS PROGRAM IS NOT SUPPORTED BY INTERGRAPH
#   CORPORATION. 
#
#	Usage:	fixfname21.sh directory 
#	
#	PURPOSE:
#	
#       To perform a batch object space replacement of '-' character 
#       with '.' in all file name references.
#
#	It is important to note the following:
#
#	1. Back up all the files before running the script.
#
#	2. Move all the files to be fixed to a single directory.
#	   This directory should not contain any extraneous files
#	   other than the already ems converted design files. File
#          permissions should be set to "-rw-rw-r--" for all files.
#
#       3. The variable EMS needs to be set to the right ems path.
#          (i.e. EMS=/usr/ip32/ems).
#
#	4. The shell script fixfname21.sh and the ppl program fixfnameb21.e
#          should all reside in another separate directory.
#
#	   script:
#
#		fixfname21.sh mydir
#
#
#

if [ "$#" -lt 1 ]
then
	echo "Usage: fixfname21.sh <dirname> "

	exit;
fi

EMS=/usr/ip32/ems

for file in `\ls  $1/*-* 2> /dev/null`
do
	echo $file
	\mv $file `echo $file | tr - .`
done

for file in `\ls  $1/* 2> /dev/null`
do
	echo $file
	$EMS/bin/ems -b -f $file -C' "ci=fixfnameb21" '
done
