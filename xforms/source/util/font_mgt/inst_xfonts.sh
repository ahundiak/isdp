#!/bin/sh
# Descrption:
#  This script will install the xforms fonts on either Clippers or Suns.
#  
# Instructions:
#  1. Become superuser.
#  2. Change to the delivered font directory.
#  3. Run this script.
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
#  06/07/91   dmb     Removed -f $INSTALLED_FONT_DIR/$file test before
#                     removing the file since this was evaluating to
#                     false when the real file had been removed.
#                     Also cleaned up a bit...
#                     
#

# Set defaults
DELIVERED_FONT_DIR=`pwd`
#INSTALLED_FONT_DIR=/usr/lib/X11/fonts/xforms

case `uname -s`
in
  CLIX )
    PATH=$PATH:/usr/bin/X11
    MKFONTDIR_CMD=mkfontdir
    IGNORE_STRING='fonts.'
    FONT_FILES_EXPR='*.snf'
    FONT_DIR_FILE=fonts.dir
    FONT_ALIAS_FILE=fonts.alias
    INSTALLED_FONT_DIR=/usr/lib/X11/fonts/misc
    ;;
  SunOS )
    PATH=$PATH:/usr/openwin/bin
    MKFONTDIR_CMD=bldfamily
    IGNORE_STRING='.list'
    FONT_FILES_EXPR='*.fb'
    FONT_DIR_FILE=Families.list
    FONT_ALIAS_FILE=Synonyms.list
    INSTALLED_FONT_DIR=/usr/openwin/lib/fonts
    ;;
esac

# Make sure TMPDIR is defined.
if [ -z "$TMPDIR" ]
then
  TMPDIR=/usr/tmp
  export TMPDIR
fi

# Make sure the installed font directory is there.
if [ ! -d $INSTALLED_FONT_DIR ]
then
  mkdir -p $INSTALLED_FONT_DIR
fi

# Symbolically link all files into the installed font directory.
cd $DELIVERED_FONT_DIR
for file in $FONT_FILES_EXPR
do
  rm -f $INSTALLED_FONT_DIR/$file
  echo "SymLink $DELIVERED_FONT_DIR/$file $INSTALLED_FONT_DIR/$file"
  ln -s $DELIVERED_FONT_DIR/$file $INSTALLED_FONT_DIR/$file
done

# Go to the installed font directory.
cd $INSTALLED_FONT_DIR

# Update the X font directory file.
echo "Updating $FONT_DIR_FILE file in $INSTALLED_FONT_DIR ..."
$MKFONTDIR_CMD

# Update any font alias files here?
#echo "Updating $FONT_ALIAS_FILE file in $INSTALLED_FONT_DIR ..."


# dmb:05/23/91:This section is not needed if all fonts are installed in 
#  X server default locations. 
## Update the font path for the server.
#if xset q | grep "$INSTALLED_FONT_DIR" >/dev/null
#then
#  echo "Found font path $INSTALLED_FONT_DIR for xforms"
#else
#  echo "Adding font path $INSTALLED_FONT_DIR/ for xforms"
#  # Explicitly add '/' - force both Clipper and Sun style font path
#  # to end in '/'
#  xset +fp $INSTALLED_FONT_DIR/
#fi

# This must be done for the server to notice the changes.
echo "Rehashing the font path"
xset fp rehash
