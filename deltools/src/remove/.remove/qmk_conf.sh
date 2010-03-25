#!/bin/ksh
if [ $# -lt 4 ]
then
    # Nothing was selected
    # sabotage the creation of the menu
    echo "\`message -b \"You must MARK products for removal before pressing <Return>\"\`"
    exit
fi

loop=$1
name=$2
dir=$3
size=$4
shift 4

case $PLATFORM in
Solaris | SunOS_4 )
    DU=/usr/bin/du
    ;;
# 04/30/94 hp added to the list 
CLIX | IRIX5 | IRIX4 | SCO | RS6000 | HP_UX )
    DU=/bin/du
    ;;
esac
export DU

TMP=/usr/tmp/temp.$SESSION.$loop
loop=`expr $loop + 1`
TMP2=/usr/tmp/temp.$SESSION.$loop

if [ "$NOFMLI" = "y" ]
then
    if [ "$justdoit" = "y" ]
    then
	size=`$DU -s $dir | cut -f 1`
	[ $PLATFORM = SunOS_4 ] && size=`expr $size \* 2`

	$RM/doit.sh $name $dir $size
	exit $?
    else
	case $PLATFORM in 
	SunOS_4)
	    /usr/bin/echo -n "Are you sure you want to remove $name? [n]: "
	    ;;
	*)
	    echo "Are you sure you want to remove $name? [n]: \c"
	    ;;
	esac
	read ans
	case ${ans:=n} in
	[yY]*)
	    echo "Removing $name ... " 
	    size=`$DU -s $dir | cut -f 1`
	    [ $PLATFORM = SunOS_4 ] && size=`expr $size \* 2`
	    $RM/doit.sh $name $dir $size
	    exit $?
	    ;;
	*)
	    echo "Product $name not removed."
	    exit 0
	    ;;
	esac
    fi
else
    if [ "$justdoit" = "y" ]
    then
	echo "run $SHELL $RM/ldoit.sh $name $dir $size $*"
    else
	echo "menu=$name - Confirm Removal" > $TMP
	echo "lifetime=shortterm" >> $TMP
	echo "help=OPEN TEXT $RM/help.0t confirm.0m" >> $TMP
	echo "name=Do not remove $name" >> $TMP
	echo "itemmsg=Are you sure you want to remove $name?" >> $TMP
	if [ $# -gt 0 ]
	then
	    echo "action=\`shell $RM/qmk_conf.sh $loop $*\`" >> $TMP
	else
	    echo "action=close" >> $TMP
	fi
	echo "" >> $TMP
	echo "name=Remove $name" >> $TMP
	echo "itemmsg=Are you sure you want to remove $name?" >> $TMP

	size=`$DU -s $dir | cut -f 1`
	[ $PLATFORM = SunOS_4 ] && size=`expr $size \* 2`

	if [ $# -gt 0 ]
	then
	    echo "action=\`run $SHELL $RM/doit.sh $name $dir $size; shell $RM/qmk_conf.sh $loop $*\`" >> $TMP
	else
	    echo "action=\`run $SHELL $RM/doit.sh $name $dir $size\`close" >> $TMP
	fi
	echo "OPEN MENU $TMP"
    fi
fi
