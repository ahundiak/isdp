echo
echo "\t\t cci compilation $*"


$GRNUC/bin/cci $* -p$EXNUC/bin/omcpp -Xnoptrchk -DENV5 -s -q \
        -I$PDU/include                  \
        -I$PDM/include                  \
        -I$PDM/pdmapi/include                  \
	-I$GRNUC/ppl/include		\
	-I$GRNUC/include		\
 	-I$EXNUC/include 		\
        -I$ROUTE/include                   \
        -I$VDS/include                   \
        -I$STRUCT/include                   \
        -I$MODEL/include                   \
        -I$BS/include                   \
        -I$NPAL/include                   \
        -I$PPM/include                   \
        -I$NFM/include                   \
        -I$FORMS/include                   \
 	-I../include	 		\
	-I$GRNUC/unix_include/sun5       \
	-tEms


for F in $*
	do
	if [ -w ${F%.u}.e ]
	then	echo "\t\tMoving ${F%.u}.e to ../bin/${F%.u}.e"
		/bin/mv ${F%.u}.e ../bin
	fi
done
