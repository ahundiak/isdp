# Remove script for the fontserve product
#
# If this script has been invoked by the remove program delivered with
# deltools, the several arguments and variables, listed below, will be
# defined.  If these variables are not defined, this script will attempt
# to remove the product anyway after determining the file system where
# the product was installed.
#
# Arguments are:
#	$1 is the name of the product
# 	$2 is the product directory
#
# Defined variables are:
#	IDname		- name of product
#	IDtitle		- longer version of the name
#	IDnumber	- product number
#	IDdate		- date of the last delivered version
#	IDversion	- number of the last delivered version
#

NULL=/dev/null

ARG1=$1
ARG2=$2

USR_DIR="/usr/ip32/fontserve"
REAL_DIR="/usr/ip32/fontserve"

# This function generates a name for a temporary file based on the
# current minutes and seconds, a count of how many times this function
# has been called, and a random number.  It tries to determine the
# correct file system from the name of the original file, but it's
# only a guess.

function get_tmp_file
{
    oldfile="$1"
    if [ "$oldfile" = "" ]
    then
	oldfile="/usr/tmp"
    fi
    set `echo $oldfile | tr "/" " "`
    case $1 in
	usr)
	    TMP_FILE_DIR="/usr/tmp"
	    ;;
	usr?)
	    TMP_FILE_DIR="/$1/tmp"
	    ;;
	*)
	    TMP_FILE_DIR="/tmp"
    esac
    if [ "$FILE_COUNTER" -gt "0" ]
    then
	FILE_COUNTER=`expr $FILE_COUNTER \+ 1`
    else
	FILE_COUNTER="1"
    fi
    set `date | tr ":" " "`
    TMP_FILE=$TMP_FILE_DIR/.t$5$6$RANDOM.$FILE_COUNTER
}

# This is a function which removes the files associated with fontserve

function remove_fontserve
{
	rm -f /usr/lib/lib*FS_s.a
	rm -f /usr/lib/c100/lib*FS_s.a
	rm -f /usr/lib/c300/lib*FS_s.a
	rm -f /usr/lib/c400/lib*FS_s.a
	rm -f /usr/lib/c400safe/lib*FS_s.a
	cd /tmp
	rm -rf $USR_DIR >$NULL 2>&1
	rm -rf $REAL_DIR >$NULL 2>&1
}

function move_fontserve
{
    for arg in `find $USR_DIR $REAL_DIR -type f -print`
    do
	get_tmp_file $arg
	mv $arg $TMP_FILE
    done >$NULL 2>&1
}

# This will get the userid of the process into a shell variable.

set - `id | tr "(=)" "   "`
ID=$2
[ "$ID" != "0" ] && echo "Must be super-user to execute properly." && exit -1

if [ -z "$IDname" ]
then
    echo "This remove script was designed to be invoked from the remove"
    echo "program delivered with deltools (/usr/ip32/deltools/remove)."
    echo "It is possible that this script will not work properly if allowed"
    echo "to continue."
    echo ""
    echo "Continue anyway (y/n)? [n]: \c"
    read response
    case $response in
	y*|Y*)	;;		# going on
	*)	exit 0;;	# they must be giving up
    esac

    if [ -d $USR_DIR ]			# see if the directory exists
    then
	if [ -L $USR_DIR ]		
	then
		# If the directory is a symbolic link, get the directory
		# that fontserve was really delivered to.
	    WHOLE_PATH=`/bin/ls -ld $USR_DIR`
	    REAL_DIR=${WHOLE_PATH##*\-\>}    # grab everything after the "->"
	fi
	remove_fontserve
	move_fontserve
	remove_fontserve
	exit 0
    else
	echo "fontserve was not found.  Cannot remove."
	exit -1
    fi
fi

# prompt for confirmation on parts/whole of the product
echo "Confirm $IDname ($IDnumber) removal (y/n)? [y]: \c"
read response
: ${response:=y}

# do the removing
case $response in
y*|Y*)
    echo "Removing $IDname..."
    REAL_DIR=$ARG2
    remove_fontserve
    move_fontserve
    remove_fontserve
    ;;
*)
    echo "Nothing was removed."
    exit 1
    ;;
esac
exit 0
