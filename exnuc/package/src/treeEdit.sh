#
#	Skeletal script for processing all
#	directory.itb files in a directory tree.
#

ARGV0=$(basename $0)

if test -z "$TARGET"
then
	echo "$ARGV0: TARGET env variable not set" >&2
	exit 2
fi

ITBLIST=$(find . -name directory.itb -print)

for ITB in $ITBLIST
do
	if test -f $TARGET/$ITB
	then
		echo "overwrite $TARGET/$ITB [n] ?\c"
		read
		if test "$REPLY" != "y" -a "$REPLY" != "Y"
		then
			continue
		fi
	fi
	set -x
	$* < $ITB > $TARGET/$ITB
	set +x
done
