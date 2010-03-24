#	Used to bulk load itbs from an ls listing.
#
# HISTORY:
# 27-Sep-91 jww  Put a filter on the "find" line to remove directory.itbs.
# 27-Sep-91 jww  Added -d switch to overwrite directory.itbs.

ARGV0="`basename $0`"
USAGE="Usage: $ARGV0 [-r] [-d] -c cpio -r rtmode -d dpmode -b build\n\
-r\t\tRecursively descend subtrees and create directory.itb files.\n\
-d\t\tOverwrite any existing "directory.itb".\n\
-c cpio\t\tCpio key to be put in the directory.itb.\n\
-b build\tBuild key.\n\
"

OPTIONS="rdc:b:"
set -- `getopt $OPTIONS $* 2>/dev/null`
if test $? != 0
then
	echo $USAGE >&2
	exit 2
fi

#
#	Validate the command line args.
#

CPIO=
DIRLIST=.
BUILD=
OVERWRITE_DIR="n"
for ARG in $*
do
	case $ARG
	in
	-c)	CPIO=$2;				shift 2;;
	-r)	DIRLIST=$(find . -type d -print);	shift 1;;
	-b)	BUILD=$2;				shift 2;;
	-d)	OVERWRITE_DIR="y";				shift 1;;
	--)	shift;					break;;
	esac
done
if test -z "$CPIO" -o -z "$DIRLIST" -o -z "$BUILD"
then
	echo $USAGE >&2
	exit 2
fi

ITB=directory.itb
for DIR in $DIRLIST
do
(
	cd $DIR
	if test -f $ITB -a "$OVERWRITE_DIR" = "n"
	then
		echo "$ARGV0: $(pwd)/$ITB already exists" >&2
		exit 2
	fi
	echo "filename	cpio	rtmode	dpmode	build"	> $ITB
	echo "--------	----	------	------	-----"	>> $ITB
	for FILE in $(/bin/ls | sed '/directory.itb/d')
	do
		if test -d $FILE
		then
			CPIO_NAME=dir
		else
			CPIO_NAME=$CPIO
		fi
		echo "$FILE	$CPIO_NAME	555	777	$BUILD"	>> $ITB
	done
)
done
