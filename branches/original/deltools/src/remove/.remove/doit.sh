#!/bin/ksh

name=$1
dir=$2
base=${2##*/}
size=$3

case $PLATFORM in
Solaris)
	case `uname -p` in
	sparc) 
	    RMSCRIPT=remove.ssl
	    ;;
	i386)
	    RMSCRIPT=remove.isl
	    ;;
	esac
	SLFLAG='-L'
	DU=/usr/bin/du
	PDIR=$INGRHOME
	;;
SunOS_4)
	RMSCRIPT=remove.sun
	SLFLAG='-h'
	DU=/usr/bin/du
	PDIR=/usr/ip32
	;;
CLIX)
	RMSCRIPT=remove.sh
	SLFLAG='-L'
	DU=/bin/du
	PDIR=/usr/ip32
	;;
IRIX4)
	RMSCRIPT=remove.sgi
	SLFLAG='-L'
	DU=/bin/du
	PDIR=/usr/ip32
	;;
IRIX5)
	RMSCRIPT=remove.sgi
	SLFLAG='-L'
	DU=/bin/du
	PDIR=$INGRHOME
	;;
SCO)
	RMSCRIPT=remove.sco
	SLFLAG='-L'
	DU=/bin/du
	PDIR=/usr/ip32
	;;
RS6000)
	RMSCRIPT=remove.rs6
	SLFLAG='-L'
	DU=/usr/bin/du
	PDIR=/usr/ip32
	;;
# mvr:04/30/94
HP_UX)
        RMSCRIPT=remove.hp
        SLFLAG='-h'
        DU=/bin/du
        PDIR=/usr/ip32
        ;;
esac

[ ! -f $dir/product.def ] && echo "Error: No product.def in $dir." && exit 1
[ ! -f $dir/$RMSCRIPT ] && echo "Error: No removal script in $dir." && exit 1

echo "Invoking the remove script for $name..."
echo
echo "-------------------------------------------------------------------------------"
(
	cd $dir
	. ./product.def >/dev/null 2>&1
	export IDname IDtitle IDnumber IDdate IDversion
	DELdir=$dir
	DELsize=$size
	export DELdir DELsize
	$SHELL ./$RMSCRIPT $1 $2
)
rstat=$?
echo "-------------------------------------------------------------------------------"

if [ $rstat = 0 ]
then
    echo "Remove script for $name finished..."

    # remove the directory, but only if it is empty (ignore error from rmdir)

    #
    # But first make sure we're not in the directory anymore
    #

    cd /tmp
    rmdir $dir >/dev/null 2>&1

    #remove any symbolic links in $PDIR as well.
    [ $SLFLAG $PDIR/$base ] && rm -f $PDIR/$base >/dev/null 2>&1

    if [ -d $dir ]
    then
	set -- `$DU -s $dir`
	used=$1
	[ $PLATFORM = SunOS_4 ] && used=`expr $used \* 2`

	echo
	if [ "$justdoit" = "y" ]
	then
	    ans=y
	else
	    echo "The directory $dir still exists (using $used blocks.)"
	    if [ $PLATFORM != SunOS_4 ]
	    then
		echo "Do you wish to remove it and the files it contains (y/n)? [y]: \c"
	    else
		/usr/bin/echo -n "Do you wish to remove it and the files it contains (y/n)? [y]: "
	    fi
	    read ans
	fi
	case ${ans:=y} in
	[yY]*)
	    echo "Removing $dir..."
	    rm -fr $dir
	    ;;
	*)
	    echo "Directory $dir not removed."
	    ;;
	esac
    fi

    # invoke dates to clean-up the ingrconfig file.
    dates >/dev/null 2>&1
    exit 0
else
    echo "Remove script for $name DID NOT COMPLETE SUCCESSFULLY."
    if [ -d $dir ]
    then
	set -- `$DU -s $dir`
	used=$1
	[ $PLATFORM = SunOS_4 ] && used=`expr $used \* 2`

	echo "The directory $dir still exists (using $used blocks)."
	echo "It will NOT be removed." 
    fi
    exit 1
fi
