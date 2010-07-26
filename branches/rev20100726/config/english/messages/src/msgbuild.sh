#!/bin/ksh
#	Script to convert .mb files to .msg and .h files.
#

##############################################################################

function if_out_of_date
{
	if test ! -f $1
	then
		echo 1
	elif test $2 -nt $1
	then
		echo 1
	else
		echo 0
	fi
}
#
#	main
#

set -e

ARGV0=`basename $0`
USAGE="usage: $ARGV0 msgfile includedir mbfile ...\n\
msgfile\tpath name of the .msg file\n\
includedir\tdirectory to put .h files in\n\
mbfile ...\tlist of .mb files to process\n\
"

#
#	check the command line
#

MSGBUILD=umscompile

if test $# -lt 3
then
	echo $USAGE >&2
	exit 2
fi

if test ! -d $1
then
  echo $USAGE >&2
  echo "The message file path ($1) must be a directory" >&2
  exit 2
else
  MSG_DIR=$1
  shift 1
fi

if test ! -d $1
then
  echo $USAGE >&2
  echo "The include file path ($1) must be a directory" >&2
  exit 2
else
  INCLUDE_DIR=$1
  shift 1
fi

if test -z "$EXNUC"
then
	echo "$ARGV0: EXNUC not set" >&2
	exit 2
fi

echo "\tBuilding .msg and .h files ...\n"
echo "\t.msg files will be in:  $MSG_DIR"
echo "\t.h files will be in:    $INCLUDE_DIR"
echo

PWD=`pwd`
for MB in $*
do
  echo "\tusing component file:   $MB"
  if test ! -f $MB
  then
    echo "$ARGV0: $MB: no such file" >&2
    exit 2
  fi

  BASE=`basename $MB \.mb`
  H=$INCLUDE_DIR/$BASE.h
  MSG=$MSG_DIR/$BASE.msg

#
# If no .h/.msg exists or the .mb file is newer
# than an existing .h/.msg then create a new .h/.msg
#

  BUILD_H=`if_out_of_date $H $MB`
  BUILD_MSG=`if_out_of_date $MSG $MB`

  if test $BUILD_H = 1 -o $BUILD_MSG = 1
  then
    $MSGBUILD -m $MSG -p $H $MB
  fi

done
