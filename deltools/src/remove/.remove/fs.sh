#!/bin/ksh
# shell script that returns info about free space.

case $PLATFORM in
SunOS_4)
    DF=/usr/bin/df
    d="----------------------------------------------------------------------"
    typeset -L13 FSNAME="File System"
    typeset -L22 DEV="Device"
    typeset -R6 fpcnt="% Used"
    typeset -R8 total="Total"
    typeset -R7 free="Free" used="Used"

    echo "NOTE: File system usage reported in 512-byte blocks"
    echo ""
    echo "$FSNAME$DEV$free + $used = $total $fpcnt"
    echo "$d"

    set -- `$DF`
    while [ $# -gt 0 ]
    do
	[ $1 = Filesystem ] && shift 7
	DEV="$1"
	FSNAME="$6"
	total=`expr $2 \* 2`
	free=`expr $4 \* 2`
	used=`expr $3 \* 2`
	fpcnt=$5
	echo "$FSNAME$DEV$free + $used = $total$fpcnt"
	shift 6
    done
    echo "$d"
    ;;
# mvr:05/05/94 bdf used for hp 
HP_UX)
    DF=/usr/bin/bdf
    d="----------------------------------------------------------------------"
    typeset -L13 FSNAME="File System"
    typeset -L22 DEV="Device"
    typeset -R6 fpcnt="% Used"
    typeset -R8 total="Total"
    typeset -R7 free="Free" used="Used"

    echo "NOTE: File system usage reported in 512-byte blocks"
    echo ""
    echo "$FSNAME$DEV$free + $used = $total $fpcnt"
    echo "$d"

    set -- `$DF`
    while [ $# -gt 0 ]
    do
	[ $1 = Filesystem ] && shift 7
	DEV="$1"
	FSNAME="$6"
	total=`expr $2 \* 2`
	free=`expr $4 \* 2`
	used=`expr $3 \* 2`
	fpcnt=$5
	echo "$FSNAME$DEV$free + $used = $total$fpcnt"
	shift 6
    done
    echo "$d"
    ;;
IRIX)
    DF=/bin/df
    d="----------------------------------------------------------------------"
    typeset -L13 FSNAME="File System"
    typeset -L22 DEV="Device"
    typeset -R6 fpcnt="% Used"
    typeset -R8 total="Total"
    typeset -R7 free="Free" used="Used"

    echo "$FSNAME$DEV$free + $used = $total $fpcnt"
    echo "$d"

    set -- `$DF`
    while [ $# -gt 0 ]
    do
	[ $1 = Filesystem ] && shift 8
	DEV="$1"
	FSNAME="$7"
	total=$3
	free=$5
	used=$4
	fpcnt=$6
	echo "$FSNAME$DEV$free + $used = $total$fpcnt"
	shift 7
    done
    echo "$d"
    ;;
*)
    DF=/bin/df
    d="----------------------------------------------------------------------"
    typeset -L13 FSNAME="File System"
    typeset -L22 DEV="Device"
    typeset -R6 fpcnt="% Used"
    typeset -R8 total="Total"
    typeset -R7 free="Free" used="Used"

    echo "$FSNAME$DEV$free + $used = $total $fpcnt"
    echo "$d"

    set -- `$DF -t`
    while [ $# -gt 0 ]
    do
	FSNAME="$1"
	DEV="$2"
	[ "$3" = "):" ] && DEV="$2):" && shift
	total=$8
	free=$3
	used=`expr $8 - $3`
	fpcnt=`expr 100 - 100 \* $3 / $8`
	echo "$FSNAME$DEV$free + $used = $total$fpcnt%"
	shift 11
    done
    echo "$d"
    ;;
esac
