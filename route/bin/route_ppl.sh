#
#	shell program to compile a ppl file and put the result in ppl/bin 
#	directory of the I/ROUTE product.  The shell script only looks at
#	the product data file in /usr/ip32 for product dependancies.  The
#	shell program takes a list of PPL files as arguments:
#
#	sample invocation:	ppl.sh ../act_para/set_parameters.u
#

ROUTE=`echopath ROUTE`

EXNUC=`echopath EXNUC`

GRNUC=`echopath GRNUC`

VDS=`echopath VDS`


$GRNUC/bin/cci $* -p$EXNUC/bin/omcpp -s -q -Xnoptrchk\
	-I$EXNUC/include	\
	-I$GRNUC/include \
	-I$VDS/include \
	-I$ROUTE/include 
	
for F in $*
	do
	if [ -w ${F%.u}.e ]
	then	echo "\t\tMoving ${F%.u}.e to $ROUTE/ppl/bin/${F%.u}.e"
		/bin/mv ${F%.u}.e $ROUTE/ppl/bin
	fi
done
