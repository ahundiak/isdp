# Do not alter this SPC information: $Revision: 1.1.59.1 $
SUB=ap
SUBDIR=risapp
SKIPFILE=build/spc.skp
DATEFILE=tstamp_s.$SUB
LISTFILE=/usr/tmp/list$$

Usage()
{
	echo "Usage: bckup.ksh {-c|-z|-t|-l}"
	echo "    -z: create zip file"
	echo "    -c: create cpio file"
	echo "    -t: create tree"
	echo "    -l: list files only"
	exit 1
}

if [ $# != 1 ]
then
	Usage
fi

case $1 in
	-c) MODE=c;;
	-z)	MODE=z;;
	-t)	MODE=t;;
	-l)	MODE=l;;
	*)	Usage;;
esac

if [ ! "$RISDEVDIR" ]
then
	echo "\$RISDEVDIR" must be set
	exit 1
fi

cd $RISDEVDIR/$SUBDIR

getfiles -e -s $SKIPFILE -n $DATEFILE > $LISTFILE
sts=$?
if [ $sts != 0 ]
then
	echo getfiles returned $sts
	exit 1
fi

if [ $MODE = l ]
then
	cat $LISTFILE
else
	if [ ! "$RISSAVEDIR" ]
	then
		echo "\$RISSAVEDIR" must be set.
		exit 1
	fi
	if [ ! "$RIS_MAJ" ]
	then
		echo "\$RIS_MAJ" must be set.
		exit 1
	fi
	if [ ! "$RIS_MIN" ]
	then
		echo "\$RIS_MIN" must be set.
		exit 1
	fi
	if [ ! "$RIS_REL" ]
	then
		echo "\$RIS_REL" must be set.
		exit 1
	fi

	if [ ! -d $RISSAVEDIR ]
	then
		mkdir -p $RISSAVEDIR
		if [ $? != 0 ]
		then
			echo "Unable to create $RISDEVDIR"
			exit 1
		fi
	fi

	if [ $MODE = c -o $MODE = z ]
	then
		FILE=$RISSAVEDIR/${RIS_MAJ}${RIS_MIN}${RIS_REL}b.${SUB}${MODE}
		rm -f $FILE 2>/dev/null

		echo
		echo "\tMaking backup $FILE"

		case $MODE in 
			c) cat $LISTFILE | cpio -ovc | compress >$FILE;;
			z) cat $LISTFILE | zip $FILE -
		esac

		chmod 666 $FILE
	else
		echo
		echo "\tMaking $SUBDIR backup tree in $RISSAVEDIR"
		if [ -d $RISSAVEDIR/$SUBDIR ]
		then
			rm -r $RISSAVEDIR/$SUBDIR
			if [ $? != 0 ]
			then
				echo "Unable to remove previous backup tree: $RISDEVDIR/$SUBDIR"
				exit 1
			fi
		fi

		mkdir -p $RISSAVEDIR/$SUBDIR
		if [ $? != 0 ]
		then
			echo "Unable to create $RISDEVDIR/$SUBDIR"
			exit 1
		fi
		cat $LISTFILE | cpio -pvmud $RISSAVEDIR/$SUBDIR
		cp $LISTFILE $RISSAVEDIR/$SUBDIR/files.dat
	fi
fi

rm -f $LISTFILE 2>/dev/null
