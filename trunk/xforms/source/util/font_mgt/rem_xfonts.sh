#!/bin/sh
# Descrption:
#  This script will remove the xforms fonts on either Clippers or Suns.
#
# Instructions:
#  1. Start the X server.
#  2. Become superuser.
#  3. Change to the delivered font directory.
#  4. Run this script.
#
# Notes:
#  - The decision to use the /usr/lib/X11/fonts/xforms as the default
#    is modeled after the MIT X standards.
#  - Font paths end with '/' by default on Clipper, and without '/'
#    by default on Sun, but the '/' is added on Sun if specified.
#    Since xset -fp requires that strings be matched exactly, we
#    must be sure to remove either style font path.
#  - It is only possible to remove the fonts for a single product from
#    the installed font directory if the delivered fonts are retained
#    in the delivered directory and used to generate the list of files
#    to remove from the installed font directory.
#    dmb:05/22/91:Maybe a delivered font list could be retained instead...
#
# History:
#  05/20/91   dmb     Written.
#  05/22/91   dmb     Use /usr/lib/X11/fonts/xforms as the XFORMS font
#                     directory on both boxes. This seems to be closer
#                     to the MIT standards and preserves the X server
#                     font directories for other applications. It also
#                     simplifies the font removal problem.
#  05/23/91   dmb     Backed off for now on attempt to avoid using the 
#                     X default font directories.
#  06/02/91   dmb     Modified to run under /bin/sh.
# 

# Set defaults
DELIVERED_FONT_DIR=`pwd`
#INSTALLED_FONT_DIR=/usr/lib/X11/fonts/xforms

# Look to see which box we're on and adapt accordingly.
case `uname -s`
in
  CLIX )
    PATH=$PATH:/usr/bin/X11
    MKFONTDIR_CMD=mkfontdir
    IGNORE_STRING='fonts.'
    FONT_DIR_FILE=fonts.dir
    FONT_ALIAS_FILE=fonts.alias
    FONT_FILES_EXPR='*.snf'
    INSTALLED_FONT_DIR=/usr/lib/X11/fonts/misc
    ;;
  SunOS )
    PATH=$PATH:/usr/openwin/bin
    MKFONTDIR_CMD=bldfamily
    IGNORE_STRING='.list'
    FONT_DIR_FILE=Families.list
    FONT_ALIAS_FILE=Synonyms.list
    FONT_FILES_EXPR='*.f[bf]'
    INSTALLED_FONT_DIR=/usr/openwin/lib/fonts
    ;;
esac

# Make sure the installed font directory is there.
if [ ! -d $INSTALLED_FONT_DIR ]
then
  echo "$0: Can not find installed font directory $INSTALLED_FONT_DIR."
  exit 2
fi

# dmb:05/23/91:Remove ONLY files delivered from product directory to the 
# installed font directory.
cd $DELIVERED_FONT_DIR
for file in $FONT_FILES_EXPR
do
  echo "Remove $INSTALLED_FONT_DIR/$file"
  rm -f $INSTALLED_FONT_DIR/$file
done

# dmb:05/23/91:Don't do this if we're delivering to X server's directory!
## Check directory contents.
#NUM_FILES=`\ls $INSTALLED_FONT_DIR | \
# sed -e "/$FONT_DIR_FILE/d" -e "/$FONT_ALIAS_FILE/d" | grep -c .`
#
#if [ "$NUM_FILES" -eq 0 ]
#then
#  # If the installed font directory is empty, first remove the 
#  # font path from the server, then remove the directory.
#
#  # Update the font path for the server.
#  if xset q | grep "$INSTALLED_FONT_DIR" >/dev/null
#  then
#    echo "Removing font path $INSTALLED_FONT_DIR."
#    xset -fp $INSTALLED_FONT_DIR,$INSTALLED_FONT_DIR/
#  else
#    echo "Font path $INSTALLED_FONT_DIR not found."
#  fi
#
#  echo "Removing empty installed font directory $INSTALLED_FONT_DIR."
#  rm -r $INSTALLED_FONT_DIR
#else
#  # If the directory is not empty, update the font directory file.
#
#  # Go to the installed font directory.
#  cd $INSTALLED_FONT_DIR
#
#  echo "Updating $FONT_DIR_FILE file ..."
#  $MKFONTDIR_CMD
#
#  # Update any X font.alias or Synonyms.list files here?
##  echo "Updating $FONT_ALIAS_FILE file ..."
#
#fi


# dmb:05/23/91:This is all we can do if we're delivering to X server's 
# directory!
# Go to the installed font directory.
cd $INSTALLED_FONT_DIR

echo "Updating $FONT_DIR_FILE file ..."
$MKFONTDIR_CMD

# This is required to get the server to notice the changes.
echo "Rehashing the font path"
xset fp rehash
