#!/bin/sh
# This script is used to generate and check the ANSI prototype header
# files for UMS.
# History
# 03/15/91   dmb     Written.
# 04/16/91   dmb     Added logic to update files in include directory
#                    only when changes have been made.
# 05/03/91   dmb     Rearranged logic on if test because Sun
#                    does not know how to handle 'if ! cmd'. Script
#                    was failing silently due to output redirection.
# 10/09/91   dmb     Changed file selection list.
# 01/06/92   dmb     Time doesn't work unless wr're in ksh.
#                    Actually, I think the problem is the sub-shell
#                    syntax. Some cleanup.
# 01/25/92   jaj     Added inclusion of header & footer to public
#                    include file.
# 06/29/92   dmb     From now on, prototypes will be hand generated.
#                    Modified this script to check prototypes, not generate
#                    them. Stop if files are different.
# 07/07/92   dmb     Adapted from XFI to UMS.
# set -x


###########################################################################
## Extract all function declarations from source code and create pums_all.h
###########################################################################

FILE_LIST="`\ls [UCg]*.c'`"
# echo "\$FILE_LIST is $FILE_LIST"

#mkptypes -e -A $FILE_LIST >pums_all.h
mkptypes -e -p UMS_PROTO $FILE_LIST >pums_all.h

###############################################################
### Extract private functions from pums_all.h create pums_pri.h
###############################################################

# Put header at beginning of pums_pri.h ###
cat pri_hdr >pums_pri.h

#  Get private functions
egrep -e '_UMS|UMC|getopt|/\*' pums_all.h >>pums_pri.h

# Put footer at beginning of pums_pri.h ###
cat pri_ftr >>pums_pri.h


###############################################################
### Extract public functions from pums_all.h create pums_pub.h
###############################################################
# Put header at beginning of pums_pub.h ###
cat pub_hdr >pums_pub.h

#  Get public functions
egrep -v -e '_UMS|UMC|UMSgetopt' pums_all.h | grep 'extern' >>pums_pub.h

# Put footer at beginning of pums_pub.h ###
cat pub_ftr >>pums_pub.h


################################################################
### Check generated prototype files against the official copies.
################################################################

PROTO_FILE_LIST="pums_all.h \
                 pums_pri.h \
                 pums_pub.h"

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
