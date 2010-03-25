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

TMP=/usr/tmp/temp.$SESSION.$loop
loop=`expr $loop + 1`
TMP2=/usr/tmp/temp.$SESSION.$loop
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
	echo "action=\`shell $RM/mk_conf.sh $loop $*\`" >> $TMP
    else
	echo "action=close" >> $TMP
    fi
    echo "" >> $TMP
    echo "name=Remove $name" >> $TMP
    echo "itemmsg=Are you sure you want to remove $name?" >> $TMP
    if [ $# -gt 0 ]
    then
	echo "action=\`run $SHELL $RM/doit.sh $name $dir $size; shell $RM/mk_conf.sh $loop $*\`" >> $TMP
    else
	echo "action=\`run $SHELL $RM/doit.sh $name $dir $size\`close" >> $TMP
    fi
    echo "OPEN MENU $TMP"
fi
