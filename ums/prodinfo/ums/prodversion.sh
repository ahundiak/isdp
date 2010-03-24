#!/bin/sh
##################################################################
# prodversion.sh
# This script sets the product version number, build and release dates.
###################################################################

###################################################################
# Instructions: Set product release date and version
###################################################################

# 1. Set Product Release Date here:
PROD_DATE="29-NOV-1994"

# 2. Set Product Version here:
PROD_VERSION="02.01.06.00"

###################################################################

###################################################################
# History
# 03/30/91   dmb     Stole Jeff's IFORMS utility. Thanx, Capt'n!
# 04/25/91   dmb     Added automatic date facility. Need utilities to use
#                    this for updating lower prodversion.sh, README, 
#                    product.def files
# 05/02/91   dmb     Replaced automatic date generation with one-liner.
#                    Converted to use /bin/sh, added verbose switch,
#                    and cleaned up unused symbols.
# 05/25/91   dmb     Rearranged to make editing easier. 
#
# dmb:05/02/91:Perhaps this should be a data file and we should have a 
# separate setprodinfo.sh utility that sets the date and version as
# requested. What would that impact?
#  build.sh
#  update_file.sh ?
###################################################################

Verbose=''
for arg in $*
do
  case $arg
  in
    -v )
       Verbose=y
       shift
       ;;
    * )
       echo "$0: Unrecognized argument $1" >&2
       exit 1
  esac
done

# Use this to default product release date to today's date:
#PROD_DATE="`date '+%d-%h-19%y' | tr '[a-z]' '[A-Z]'`"

# Compute the short version string from the real version number.
# I think this is obsolete, but we'll check on that later.
SHORT_PROD_VERSION="`echo $PROD_VERSION | sed 's/\.//g'`"

# Product Build Date: This should always be today's date
PROD_BUILD_DATE="`date '+%d-%h-19%y' | tr '[a-z]' '[A-Z]'`"

export PROD_DATE PROD_VERSION SHORT_PROD_VERSION 

if [ "$Verbose" ]
then
  echo "PROD_DATE = $PROD_DATE"
  echo "PROD_VERSION = $PROD_VERSION"
  echo "SHORT_PROD_VERSION = $SHORT_PROD_VERSION"
fi
