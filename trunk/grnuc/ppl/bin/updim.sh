# Update Dimensions
# Shell script for batch mode
# conversion of dimensioning files.
# Author: A.M.R.Chary
# Date: 23rd Jan, 1991
# 

if [ $# = "1" ]
then
	if [ "$1" = "-d" ]
	then
		drop_dims="TRUE"
	else
		echo "Usage: $0 [-d]"
		exit 1
	fi
elif [ $# = "0" ]
then
	drop_dims="FALSE"
else
	echo "Usage: $0 [-d]"
	exit 1
fi

echo
echo
echo "          *******************************************"
echo "                        Update Dimensions            "
echo "          *******************************************"
echo
echo
EMSDIR=`echopath EMS`
EXNUC=`echopath EXNUC`
echo
if [ ! -f $EMSDIR/bin/ems ]
then
	echo ERROR: Cannot find I/EMS
	exit 1
fi
echo Using I/EMS at $EMSDIR/bin/ems

if [ ! -f $EXNUC/bin/copyOS ]
then
	echo ERROR: Cannot find copyOS utility
	exit 1
fi

echo Make sure you have backup of all files before continuing!

if [ $drop_dims = "TRUE" ]
then
	echo WARNING: All dimensions will be dropped!!!
	export DROP_ALL_DIMS=TRUE
fi

echo

while true
do
	echo
	echo "Key in name of file which lists files to be updated: \c"
	read LIST
	if [ -f $LIST ]
	then
		break
	else
		echo "Cannot open \"$LIST\""
	fi
done

echo
echo "Please key in your full name: \c"
read NAME
echo
echo
echo $NAME to update:
echo
cat  $LIST | while read SRCFILE DSTFILE
do
	echo "$SRCFILE\c"
	if [ ! -f $SRCFILE ]
	then
		echo ": File Not Found"
	else
		echo " -> $DSTFILE"
	fi
done

echo

while true
do
	echo "Continue?[y/n]: \c"
	read OK

	if [ "$OK" = "y" -o "$OK" = "Y" ]
	then
		echo
		echo
		echo "\n$NAME\n" >> error.log
		echo "\n$NAME\n" >> update.log
		if [ $drop_dims = "TRUE" ]
		then
			echo "(All dimensions dropped)" >> error.log
			echo "(All dimensions dropped)" >> update.log
		fi

		cat $LIST | while read SRCFILE DSTFILE
		do
			echo

			if [ -f "$SRCFILE" ]
			then
			    echo Updating $SRCFILE
			    echo "\n\nUpdating $SRCFILE\n" >> error.log
			    echo "$SRCFILE:\c" >> update.log

			    if [ "$SRCFILE" != "$DSTFILE" ]
			    then
				    $EXNUC/bin/copyOS $SRCFILE $DSTFILE
			    fi

			    chmod +w $DSTFILE

			    $EMSDIR/bin/ems -b -f $DSTFILE \
				-C '"ci" dmsts "exit" y' >>error.log 2>&1
			else
			    echo $SRCFILE: File not found
			    echo $SRCFILE: File not found >> update.log
			    echo "\n\n$SRCFILE: File not found\n" >> error.log
			fi
		done

		exit 0

	elif [ "$OK" = "n" -o "OK" = "N" ]
	then
		exit 3
	fi
done
