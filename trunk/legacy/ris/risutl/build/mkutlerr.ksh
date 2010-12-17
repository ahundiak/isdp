#!/bin/ksh

UMSCC=umscompile
RISUMSCC=$RISDEVDIR/risums/unix/bin/$BINDIR/risumscc
[ -x $RISUMSCC ] && UMSCC=$RISUMSCC

MSG_DIR=$RISDEVDIR/risutl/config/english/messages
MSG_FILE=$MSG_DIR/utl.msg
TXT_FILE=$MSG_DIR/utl.txt

ERR_DIR=$RISDEVDIR/risutl/include
ERR_FILE=$ERR_DIR/utl_err.h

INF_DIR=$RISDEVDIR/risutl/internal
INF_FILE=$INF_DIR/utl_inf.h

COPYRIGHT="\
/*\n\
**  Copyright 1993, Intergraph Corporation, All Rights Reserved\n\
*/\n\
"

TEMP_FILE=/usr/tmp/temp$$
NEW_FILE=/usr/tmp/new$$

mergetxt utl
if [ $? != 0 ]
then
	return 1
fi

$UMSCC -m $MSG_FILE -p $TEMP_FILE $TXT_FILE
sed 's/0x0/(int)0x8/' $TEMP_FILE > $NEW_FILE
sed -n '/RISUTL_I_/p' $NEW_FILE > $TEMP_FILE
cmp -s $TEMP_FILE $INF_FILE
if [[ $? != 0 ]]  
then
	echo "\tMaking a new $INF_FILE"
	if [[ ! -d $INF_DIR ]]
	then
		echo "\tCreating directory $INF_DIR"
		mkdir -p $INF_DIR
	fi
	mv $TEMP_FILE $INF_FILE
	touch 0923000085 $INF_FILE
else
	echo "\t$INF_FILE was up to date"
	rm -f $TEMP_FILE 
fi

echo $COPYRIGHT > $TEMP_FILE
sed -n '/RISUTL_E_/p' $NEW_FILE >> $TEMP_FILE
cmp -s $TEMP_FILE $ERR_FILE
if [[ $? != 0 ]] 
then
	echo "\tMaking a new $ERR_FILE"
	if [[ ! -d $ERR_DIR ]]
	then
		echo "\tCreating directory $ERR_DIR"
		mkdir -p $ERR_DIR
	fi
	mv $TEMP_FILE $ERR_FILE
	touch 0923000085 $ERR_FILE
else
	echo "\t$ERR_FILE was up to date"
	rm -f $TEMP_FILE
fi
rm -f $NEW_FILE
