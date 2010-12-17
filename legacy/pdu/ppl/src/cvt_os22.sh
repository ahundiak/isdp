#
#
#				DISCLAIMER
#
#   THE FOLLOWING PROGRAM IS CONSIDERED UNOFFICIAL AND IS TO BE USED
#   AS AN EXAMPLE ONLY. THIS PROGRAM IS NOT SUPPORTED BY INTERGRAPH
#   CORPORATION. 
#
#	Usage:	cvt_os22.sh directory 
#	
#	PURPOSE:
#	
#       To perform a batch object space conversion for PDU 14-to-22. This
#       program will handle atomic as well as assembly conversion.
#
#	It is important to note the following:
#
#	1. Back up all the files before conversion.
#
#	2. Move all the files to be converted to a single directory.
#	   This directory should not contain any extraneous files
#	   other than the already ems converted design files. File
#          permissions should be set to "-rw-rw-r--" for all files.
#
#       3. The variable EMS needs to be set to the right ems path.
#          (i.e. EMS=/usr/ip32/ems).
#
#	4. The shell script cvt_os22.sh, cvt_os22.e and login.info
#          should all reside in another separate directory.
#
#       5. The format of the ascii file login.info is as follows:
#
#          first line: PDM environment name.
#          second line: PDM user name.
#          third line: user password.
#
#	   script:
#
#		cvt_os22.sh mydir
#
#
#

if [ "$#" -lt 1 ]
then
	echo "Usage: cvt_os22.sh <dirname> "

	exit;
fi

EMS=/usr/ip32/ems

for file in `\ls  $1/* 2> /dev/null`
do
	echo $file
	$EMS/bin/ems -b -f $file -C' "ci=cvt_os22" '
done
