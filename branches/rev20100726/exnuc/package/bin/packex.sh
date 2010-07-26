#!/bin/sh
#
#	Creates the cpio files needed for newprod.  Expects to read
#	a series of files created by prepackaging.
#
################################################################################
#	Tunables:
#

CPIOEXT=.p	#	Default filename extension for cpio files.
SHEXT=.ish	#	Filename extension for cpio install scripts.
OEXT=.x		#	Filename extension for cpio stderr output.
SIZEEXT=Size	#	Filename extension for the size of each cpio file.

################################################################################

ARGV0="`basename $0`"
USAGE="Usage: $ARGV0 [-e ext] -o dir prepack.env ...\n\
-e ext\t\tExtension for cpio files.  Default [$CPIOEXT].\n\
-o dir\t\tDestination directory for cpio files.\n\
prepack.env ...\tList of prepackage environment files.\n\
"

OPTIONS="o:e:"
set -- `getopt $OPTIONS $* 2>/dev/null`
if test $? != 0
then
	echo $USAGE >&2
	exit 2
fi
set -e

#
#	Validate the command line args.
#

DEST=
for ARG in $*
do
	case $ARG
	in
	-o)	DEST=$2;	shift 2;;
	-e)	CPIOEXT=$2;	shift 2;;
	--)	shift;		break;;
	esac
done
if test -z "$DEST" -o ! -d "$DEST" -o -z "$CPIOEXT" -o -z "$*"
then
	echo $USAGE >&2
	exit 2
fi

#
#	Loop and create all the cpio files.
#

while test -n "$*"
do
	ENVFILE=$1			#  Prepackaging env file.
	CPIO=`basename $ENVFILE .env`	#  Cpio name as found in the itb.
	PFILE=${CPIO}${CPIOEXT}		#  Name of the cpio file to create.
	SHFILE=${CPIO}${SHEXT}		#  Post-install shell script for PFILE.
	OFILE=${CPIO}${OEXT}		#  Cpio verbose output for PFILE.
	SIZEFILE=${CPIO}${SIZEEXT}	#  Cpio size.

	echo
	echo "________________________________________________________________________________"
	echo
	echo "Creating $DEST/$PFILE"
	echo
	echo "Extracting variables: $ENVFILE"

	#
	#	Read in the environment variables created by
	#	prepackaging.
	#

	eval `cat $ENVFILE`

	#
	#	Create the post-install file.  It contains the chmod, chown,
	#	and chgrp commands for each file in the cpio file.
	#

	echo
	echo "Creating $DEST/$SHFILE"

	cat $ENVFILE > $DEST/$SHFILE

	#
	#	The following cat echos all the lines up to "EOF" into
	#	the post-install script.  EOF is quoted to disable
	#	parameter substitution.  The lines are echoed verbatim.
	#

	cat <<- "EOF" >> $DEST/$SHFILE
	for FILE in $FILELIST
	do
	        FNAME="`echo $FILE | cut -d: -f1`"
	        FMODE="`echo $FILE | cut -d: -f2`"
	        chmod $FMODE $FNAME
	        chgrp $GROUP $FNAME
	        chown $OWNER $FNAME
	done
	EOF

	echo "rm -f $SHFILE" >> $DEST/$SHFILE
	chmod +x $DEST/$SHFILE

	#
	#	Create the cpio file
	#

	echo
	echo "Packaging files from $SOURCE"
	(
	set -e
	cd $SOURCE
	for FILE in $FILELIST
	do
		FILE=`echo $FILE | cut -d: -f1`
		if test ! -f $FILE -a ! -d $FILE
		then
			echo "$ARGV0: ERROR: $SOURCE/$FILE: no such file" >&2
			exit 2
		else
			echo $FILE
		fi
	done | cpio -ocv | compress -c > $DEST/$PFILE
	) 2>$DEST/$OFILE
	cat $DEST/$OFILE

	set +e
	if test -n "`fgrep ERROR $DEST/$OFILE`"
	then
		echo "$ARGV0: ERROR: creating $DEST/$PFILE" >&2
		rm -f $DEST/$PFILE
		exit 2
	fi
	set -e

	#
	#	The last line of the cpio stderr output will contain the
	#	number of blocks in the cpio file.
	#

	SIZE=`tail -1l $DEST/$OFILE | cut -d' ' -f1`
	echo "${CPIO}Size=$SIZE" > $DEST/$SIZEFILE
	SIZELIST="$SIZELIST $SIZE"

	echo "________________________________________________________________________________"
	shift
done

#	Create the install scripts cpio file
#			*.ish files

echo
echo "Packaging *.ish files from $DEST"
(
set -e
cd $DEST
for FILE in `\ls *.ish`
do
	if test ! -f $FILE -a ! -d $FILE
	then
		echo "$ARGV0: ERROR: $DEST/$FILE: no such file" >&2
		exit 2
	else
		echo $FILE
	fi
done | cpio -ocv | compress -c > $DEST/ish${CPIOEXT}
) 2>$DEST/ish$OEXT
cat $DEST/ish$OEXT

set +e
if test -n "`fgrep ERROR $DEST/ish$OEXT`"
then
	echo "$ARGV0: ERROR: creating $DEST/ish${CPIOEXT}" >&2
	rm -f $DEST/ish${CPIOEXT}
	exit 2
fi
set -e
