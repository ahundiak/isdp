#!/bin/ksh
###########################################################################
#
#	shell program to compile a ppl file and put the result in ppl/bin 
#	directory of the I/LOFT product.  The shell script only looks at
#	the product data file in /usr/ip32 for product dependancies.  The
#	shell program takes a list of PPL files as arguments:
#
#	sample invocation:	ppl.sh ../act_para/set_parameters.u
###########################################################################
#

function echopath {
    item=$1
    pdata=$2
    me=$3

    path=`awk '/ '$item' / {print $5}' $pdata`

    echo $path
    exit 0
}

echo "$*"

$GRNUC/bin/cci $* -p$EXNUC/bin/omcpp -s -q \
	-I$GRNUC/unix_include/$(CPUTYPE)
	-I/usr/include \
	-I$BS/include \
	-I$EXNUC/include \
	-I$GRNUC/include \
	-I$MODEL/include \
	-I$ASSOC/include \
	-I$VDS/include \
	-I$STRUCT/include \
	-I$LOFT/include \
	-I$LOFT/include/private
	
for F in $*
	do
	if [ -w ${F%.u}.e ]
	then	echo "\t\tMoving ${F%.u}.e to $LOFT/ppl/bin/${F%.u}.e"
		/bin/mv ${F%.u}.e $LOFT/ppl/bin
	fi
done
