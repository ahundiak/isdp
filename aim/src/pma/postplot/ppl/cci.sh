echo "\t\t cci compilation"


$GRNUC/bin/cci $* -p$EXNUC/bin/omcpp -Xnoptrchk -s -q \
	-I$GRNUC/ppl/include		\
	-I$GRNUC/include		\
	-I$GRNUC/src/assoc/include_priv \
	-I$FORMS/include             \
 	-I$EXNUC/include 		\
        -I$ROUTE/include                   \
        -I$VDS/include                   \
        -I$VDS/vdinclude                   \
        -I$STRUCT/include                   \
        -I$MODEL/include                   \
        -I$BS/include                   \
	-I$BS/include/prototypes     \
        -I$PDUDP/include                   \
        -I$PDMDP/include                   \
        -I$PPM/include                   \
        -I$NFM/include                   \
        -I$NFMDP/include                   \
	-I/usr/e4r/include             \
 	-I../include	 		\
	-tEms


for F in $*
	do
	if [ -w ${F%.u}.e ]
	then	echo "\t\tMoving ${F%.u}.e to ../bin/${F%.u}.e"
		/bin/mv ${F%.u}.e ../bin
	fi
done
