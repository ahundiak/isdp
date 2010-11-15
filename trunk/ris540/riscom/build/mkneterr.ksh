#! /bin/ksh

UMSCC=umscompile
RISUMSCC=$RISDEVDIR/risums/unix/bin/$BINDIR/risumscc
[ -x $RISUMSCC ] && UMSCC=$RISUMSCC

MSG_DIR=$RISDEVDIR/riscom/config/english/messages
MSG_FILE=$MSG_DIR/net.msg
TXT_FILE=$MSG_DIR/net.txt

ERR_DIR=$RISDEVDIR/riscom/include
ERR_FILE=$ERR_DIR/net_err.h

VAX_ERR_DIR=$RISDEVDIR/riscom/internal
VAX_ERR_FILE=$VAX_ERR_DIR/net_vax.h

COPYRIGHT="\
/*\n\
**  Copyright 1993, Intergraph Corporation, All Rights Reserved\n\
*/\n\
"

TEMP_FILE=/usr/tmp/temp$$
NEW_FILE=/usr/tmp/new$$

mergetxt net
if [ $? != 0 ]
then
    return 1
fi

$UMSCC -m $MSG_FILE -p $TEMP_FILE $TXT_FILE
echo $COPYRIGHT > $NEW_FILE
	sed 's/0x0/0x8/' $TEMP_FILE >> $NEW_FILE
cmp -s $NEW_FILE $ERR_FILE
if [[ $? != 0 ]] 
then 
	echo "\tMaking a new $ERR_FILE"
	if [[ ! -d $ERR_DIR ]]
	then
		echo "\tCreating directory $ERR_DIR"
		mkdir -p $ERR_DIR
	fi
	mv $NEW_FILE $ERR_FILE
	touch 0923000085 $ERR_FILE
else
	echo "\t$ERR_FILE was up to date"
	rm -f $NEW_FILE
fi
rm -f $TEMP_FILE

echo 'static struct net_vax_err' > $NEW_FILE
echo '{' >> $NEW_FILE
echo '\tint  code;' >> $NEW_FILE
echo '\tchar *key;' >> $NEW_FILE
echo '\tchar *msg;' >> $NEW_FILE
echo '} NET_vax_error[] =' >> $NEW_FILE
echo '{' >> $NEW_FILE
egrep -v '^#|^::|NET[ \t]461' $TXT_FILE | sed 's/"/\\"/g' > $TEMP_FILE
sed 's/\(NET_E_\)\([A-Z0-9_]*\)[	 ]*\(.*\)/\
	{\1\2,\
	 "NET:\2",\
	 "\3"},/' $TEMP_FILE >> $NEW_FILE
echo '};' >> $NEW_FILE
cmp -s $NEW_FILE $VAX_ERR_FILE
if [[ $? != 0 ]] 
then 
	echo "\tMaking a new $VAX_ERR_FILE"
	if [[ ! -d $VAX_ERR_DIR ]]
	then
		echo "\tCreating directory $VAX_ERR_DIR"
		mkdir -p $VAX_ERR_DIR
	fi
	mv $NEW_FILE $VAX_ERR_FILE
	touch 0923000085 $VAX_ERR_FILE
else
	echo "\t$VAX_ERR_FILE was up to date"
	rm -f $NEW_FILE
fi

rm -f $TEMP_FILE
