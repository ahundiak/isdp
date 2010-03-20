#!/bin/sh
# This script is used to generate and check the ANSI prototype header
# files for UMS.
# History
# 06/29/92   dmb     From now on, prototypes will be hand generated.
#                    Modified this script to check prototypes, not generate
#                    them. Stop if files are different.
# 08/29/92   dmb     Adapted for xfb from xfi.
# 09/01/92   dmb     Slighgt modifications for single directory components.
# set -x


###########################################################################
## Extract all function declarations from source code to create
##    EGdec_p_all.h
###########################################################################
# First, make sure there's a workspace available.
if [ ! -d ./NEW_PROTO ]
then
  mkdir ./NEW_PROTO
fi

#FILE_LIST="`\ls *.c | sed '/glob.c/d'`"
FILE_LIST="`\ls *.c`"
# echo "\$FILE_LIST is $FILE_LIST"

mkptypes -e -A $FILE_LIST >./NEW_PROTO/EGdec_p_all.h


###############################################################
### Extract private functions from EGdec_p_all.h create EGdec_p_pri.h
###############################################################

# Put header at beginning of EGdec_p_pri.h ###
cat pri_hdr >./NEW_PROTO/EGdec_p_pri.h

#  Get private functions
   cat ./NEW_PROTO/EGdec_p_all.h 		>>./NEW_PROTO/EGdec_p_pri.h
#   egrep -e ' \*_| _|/\*' ./NEW_PROTO/EGdec_p_all.h 		>>./NEW_PROTO/EGdec_p_pri.h
#egrep -v -e ' \*_| _|/\*' ./NEW_PROTO/EGdec_p_all.h | grep .	>>./NEW_PROTO/EGdec_p_pub.h
# Put footer at beginning of EGdec_p_pri.h ###
cat pri_ftr >>./NEW_PROTO/EGdec_p_pri.h

################################################################
### Check generated prototype files against the official copies.
################################################################

PROTO_FILE_LIST="EGdec_p_all.h \
                 EGdec_p_pri.h"

STOP_MAKE=n
for file in $PROTO_FILE_LIST
do
#    echo "Checking $file."

  if [ -f ./$file ]
  then
#    diff -b ./NEW_PROTO/$file ./$file     >/dev/null 2>&1
#    if [ $? -eq 0 ]

    if cmp -s ./NEW_PROTO/$file ./$file >/dev/null 2>&1
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
    rm -f ./NEW_PROTO/$file
  else
    STOP_MAKE=y
    echo ./NEW_PROTO/$file is DIFFERENT FROM ./$file.
    echo "Updating ./CHECK_PROTO/$file."

    if [ ! -d ./CHECK_PROTO ]
    then
      mkdir ./CHECK_PROTO
    fi
    rm -f ./CHECK_PROTO/$file

    mv -f ./NEW_PROTO/$file ./CHECK_PROTO/$file

    diff ./CHECK_PROTO/$file ./$file

  fi
done

if [ "$STOP_MAKE" = "y" ]
then
  exit 1
else
  exit 0
fi
