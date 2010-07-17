echo ISOGEN EXTRACTION, Batch mode
echo

#echo "number of arguments:" $#
if [ $# -ne 9 -a $# -ne 13 -a $# -ne 17 ]
then
	echo "batch_iso: bad argument count"
	echo "Usage:"
	echo "first argument  : VDS design file name"
	echo "second argument : Output iso file name"
	echo "third argument  : IGDS seed file"
	echo "forth argument  : Defautls file" 
	echo "fofth argument  : Number of disconnected sections"
	echo "sixth argument  : Line sequence number (ALL for all)"
	echo "seventh argument: Fluid code (-1 for all)"
	echo "heigth argument : Block number (ALL for all)"
	echo "ninth argument  : piping material class (ALL for all)"
	echo
	echo "simple evocation: iso.sh file.dgn iso_name bimpseed.dgn defaults.dat 0 seq1 ALL -1 ALL"
	exit 1
fi

echo Design file         : $1
echo Iso name            : $2
#echo line sequence number: $6
echo 


if [ ! -f $4 ]
 then echo  echo defaults file: $4 not found
fi

if [ ! -f $3 ]
 then echo  echo IGDS seed file: $3 not found
fi

# micro station directory 
MS_DIR=/usr2/ip32/mstation

ISODFTS=$4
ISOSEED=$3

MS_FNTLB=$MS_DIR/fontlib
MS_EXE=$MS_DIR/
MS_RSRC=$MS_DIR/

export ISODFLTS MS_DIR MS_FNTLB MS_EXE MS_RSRC ISOSEED

if test -s big_file 
 then rm big_file
fi 

if test -s att_file 
 then rm att_file
fi 

if test -s $2.idf 
 then 
 	rm $2.idf
fi 

if test -s $2.h 
 then rm $2.h
fi

if [ $# -eq 9 ]
 then $VDS/bin/vds -b -f $1 -C "\"ci=COopt\" $2 $3 $4 $5 $6 $7 $8 $9 RESET TERMINATE \"exit\" n"
elif [ $# -eq 13 ]
 then $VDS/bin/vds -b -f $1 -C "\"ci=COopt\" $2 $3 $4 $5 $6 $7 $8 $9 ${10} ${11} ${12} ${13} RESET TERMINATE \"exit\" n"
elif [ $# -eq 17 ]
 then $VDS/bin/vds -b -f $1 -C "\"ci=COopt\" $2 $3 $4 $5 $6 $7 $8 $9 ${10} ${11} ${12} ${13} ${14} ${15} ${16} ${17} RESET TERMINATE \"exit\" n"
fi

exit 1
