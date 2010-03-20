#!/bin/sh

if [ `uname -s` != "CLIX" ]
then
  echo "This script should only be run on a Clipper."
  echo "Use the bdf_to_fb.sh script on Sun Stations."
  exit 1
fi

PATH=$PATH:/usr/bin/X11

#FONTDIR=`pwd`
#FONT_DEST=${FONT_DEST:-`pwd`}
if [ -z "$FONT_DEST" ]
then
  FONT_DEST=`pwd`
fi

#  FONT_SRC=${FONT_SRC:-../fonts_bdf}
if [ -z "$FONT_SRC" ]
then
  FONT_SRC=../fonts_bdf
fi

# Make sure we're in the right location.
cd $FONT_SRC

echo "Compiling fonts from `pwd` into $FONT_DEST"

for file in *.bdf
do
  snf_file=`echo $file | sed 's/\.bdf$/.snf/'`
  echo "bdftosnf <$file >$FONT_DEST/$snf_file"
  bdftosnf <$file >$FONT_DEST/$snf_file
done

echo "Making Font Directory File"
mkfontdir $FONT_DEST
