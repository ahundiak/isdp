#!/bin/sh
# This script is used to generate and check the ANSI prototype header
# files for UMS.
# History
# 06/29/92   dmb     From now on, prototypes will be hand generated.
#                    Modified this script to check prototypes, not generate
#                    them. Stop if files are different.
# 08/29/92   dmb     Adapted for xMB from xfi.
# 10/14/92   dmb     Filter out API_HANDLE_SHUTDOWN.

# set -x


###########################################################################
## Extract all function declarations from source code to create
##    XMBproto_all.h
###########################################################################

#FILE_LIST="`\ls *.c | sed '/glob.c/d'`"
FILE_LIST="`\ls *.c`"
# echo "\$FILE_LIST is $FILE_LIST"

mkptypes -e -A $FILE_LIST |
  sed '/API_HANDLE_SHUTDOWN/d' >XMBproto_all.h


###############################################################
### Extract private functions from XMBproto_all.h create XMBproto_pri.h
###############################################################

# Put header at beginning of XMBproto_pri.h ###
cat pri_hdr >XMBproto_pri.h

#  Get private functions
   cat XMBproto_all.h 		>>XMBproto_pri.h
#   egrep -e ' \*_| _|/\*' XMBproto_all.h 		>>XMBproto_pri.h
#egrep -v -e ' \*_| _|/\*' XMBproto_all.h | grep .	>>XMBproto_pub.h
# Put footer at beginning of XMBproto_pri.h ###
cat pri_ftr >>XMBproto_pri.h

################################################################
### Check generated prototype files against the official copies.
################################################################

PROTO_FILE_LIST="XMBproto_all.h \
                 XMBproto_pri.h"

STOP_MAKE=n
for file in $PROTO_FILE_LIST
do
#    echo "Checking $file."

  if [ -f ../include/$file ]
  then
#    diff -b $file ../include/$file     >/dev/null 2>&1
#    if [ $? -eq 0 ]

    if cmp -s $file ../include/$file >/dev/null 2>&1
    then
      FOUND_CHANGES=n
    else
      FOUND_CHANGES=y
    fi
  else
    FOUND_CHANGES=y
  fi

  if [ "$FOUND_CHANGES" = "n" ]
  then
    echo "No changes in $file."
    rm -f $file
  else
    STOP_MAKE=y
    echo $file is DIFFERENT FROM ../include/$file.
    echo "Updating ../include/CHECK_PROTO/$file."

    if [ ! -d ../include/CHECK_PROTO ]
    then
      mkdir ../include/CHECK_PROTO
    fi
    rm -f ../include/CHECK_PROTO/$file

    mv -f $file ../include/CHECK_PROTO/$file

    diff ../include/CHECK_PROTO/$file ../include/$file

  fi
done

if [ "$STOP_MAKE" = "y" ]
then
  exit 1
else
  exit 0
fi
