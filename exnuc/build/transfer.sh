#
#	Script to link high-level makefiles from the source tree
#	to an object tree.
#
set -e
ARGV0=`basename $0`
USAGE="Usage: $ARGV0 srcdir destdir file ...\n\
srcdir\t\tsource directory\n\
destdir\t\tdestination directory\n\
file ...\tlist of files to be transfered"

if test $# -lt 2 -o ! -d "$1" -o ! -d "$2"
then
	echo $USAGE >&2
	exit 2
fi
SRC=$1
DEST=$2
shift 2

for FILE in $*
do
	if test ! -s $SRC/$FILE
	then
		echo "$ARGV0: $SRC/$FILE: no such file" >&2
		exit 2
	fi
	#echo "\tcp $SRC/$FILE $DEST/$FILE"
	cp $SRC/$FILE $DEST/$FILE
done
