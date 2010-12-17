#
#
#				DISCLAIMER
#
#   THE FOLLOWING PROGRAM IS CONSIDERED UNOFFICIAL AND IS TO BE USED
#   AS AN EXAMPLE ONLY. THIS PROGRAM IS NOT SUPPORTED BY INTERGRAPH
#   CORPORATION. 
#
#	Usage:	stamp_del.sh directory 
#	

if [ "$#" -lt 1 ]
then
	echo "Usage: stamp_del.sh <dirname> "

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
	$EMS/bin/ems -b -f $file -C' "ci=stamp_del" '
done
