echo
echo "\t\t cci compilation $*"


$GRNUC/bin/cci $* -p$EXNUC/bin/omcpp -Xnoptrchk $MKDOPT -s -q \
        -I$GRNUC/unix_include/isl       \
	-I$OPENWINHOME/share/include \
        -I$PDU/include                  \
        -I$PDM/include                  \
        -I$PDM/pdmapi/include           \
	-I$GRNUC/include		\
	-I$GRNUC/raster/include		\
 	-I$EXNUC/include 		\
        -I$MODEL/include                   \
        -I$BS/include                   \
        -I$NPAL/include                   \
        -I$NFM/include                   \
        -I$FORMS/include                   \
 	-I../include	 		\
	-tEms


for F in $*
	do
	if [ -w ${F%.u}.e ]
	then	echo "\t\tMoving ${F%.u}.e to ../bin/${F%.u}.e"
		/bin/mv ${F%.u}.e ../bin
	fi
done
