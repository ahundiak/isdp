#!/bin/sh

if [ `uname -s` != "SunOS" ]
then
  echo "This script should only be run on a Sun Station."
  echo "Use the bdf_to_snf.sh script on Clippers."
  exit 1
fi

PATH=$PATH:/usr/openwin/bin
LD_LIBRARY_PATH=/usr/lib/X11
export LD_LIBRARY_PATH

#  FONT_SRC=${FONT_SRC:-../fonts_bdf}
if [ -z "$FONT_SRC" ]
then
  FONT_SRC=../fonts_bdf
fi

# dmb:05/23/91:According to the man pages, there may be some
#interaction here we need to watch out for.
#FONTDIR=`pwd`
#FONT_DEST=${FONT_DEST:-`pwd`}
if [ -z "$FONT_DEST" ]
then
  FONT_DEST=`pwd`
fi

echo "Compiling fonts into directory $FONT_DEST"
#echo "Converting dutch fonts ..."

convertfont -n dutch801.14 -o dch801.14 -f 16 $FONT_SRC/dch801.14.bdf
convertfont -n dutch801.18 -o dch801.18 -f 16 $FONT_SRC/dch801.18.bdf
convertfont -n dutch801.22 -o dch801.22 -f 16 $FONT_SRC/dch801.22.bdf
convertfont -n dutch801.24 -o dch801.24 -f 16 $FONT_SRC/dch801.24.bdf
convertfont -n dutch801.30 -o dch801.30 -f 16 $FONT_SRC/dch801.30.bdf
convertfont -n dutch801.36 -o dch801.36 -f 16 $FONT_SRC/dch801.36.bdf

convertfont -n dutch801b.14 -o dch801b.14 -f 16 $FONT_SRC/dch801b.14.bdf
convertfont -n dutch801b.18 -o dch801b.18 -f 16 $FONT_SRC/dch801b.18.bdf
convertfont -n dutch801b.22 -o dch801b.22 -f 16 $FONT_SRC/dch801b.22.bdf
convertfont -n dutch801b.24 -o dch801b.24 -f 16 $FONT_SRC/dch801b.24.bdf
convertfont -n dutch801b.30 -o dch801b.30 -f 16 $FONT_SRC/dch801b.30.bdf
convertfont -n dutch801b.36 -o dch801b.36 -f 16 $FONT_SRC/dch801b.36.bdf

convertfont -n dutch801i.14 -o dch801i.14 -f 16 $FONT_SRC/dch801i.14.bdf
convertfont -n dutch801i.18 -o dch801i.18 -f 16 $FONT_SRC/dch801i.18.bdf
convertfont -n dutch801i.22 -o dch801i.22 -f 16 $FONT_SRC/dch801i.22.bdf
convertfont -n dutch801i.24 -o dch801i.24 -f 16 $FONT_SRC/dch801i.24.bdf
convertfont -n dutch801i.30 -o dch801i.30 -f 16 $FONT_SRC/dch801i.30.bdf
convertfont -n dutch801i.36 -o dch801i.36 -f 16 $FONT_SRC/dch801i.36.bdf

#echo "Converting swiss fonts ..."

convertfont -n swiss742.14 -o sws742.14 -f 16 $FONT_SRC/sws742.14.bdf
convertfont -n swiss742.18 -o sws742.18 -f 16 $FONT_SRC/sws742.18.bdf
convertfont -n swiss742.22 -o sws742.22 -f 16 $FONT_SRC/sws742.22.bdf
convertfont -n swiss742.24 -o sws742.24 -f 16 $FONT_SRC/sws742.24.bdf
convertfont -n swiss742.30 -o sws742.30 -f 16 $FONT_SRC/sws742.30.bdf
convertfont -n swiss742.36 -o sws742.36 -f 16 $FONT_SRC/sws742.36.bdf

convertfont -n swiss742b.14 -o sws742b.14 -f 16 $FONT_SRC/sws742b.14.bdf
convertfont -n swiss742b.18 -o sws742b.18 -f 16 $FONT_SRC/sws742b.18.bdf
convertfont -n swiss742b.22 -o sws742b.22 -f 16 $FONT_SRC/sws742b.22.bdf
convertfont -n swiss742b.24 -o sws742b.24 -f 16 $FONT_SRC/sws742b.24.bdf
convertfont -n swiss742b.30 -o sws742b.30 -f 16 $FONT_SRC/sws742b.30.bdf
convertfont -n swiss742b.36 -o sws742b.36 -f 16 $FONT_SRC/sws742b.36.bdf

convertfont -n swiss742i.14 -o sws742i.14 -f 16 $FONT_SRC/sws742i.14.bdf
convertfont -n swiss742i.18 -o sws742i.18 -f 16 $FONT_SRC/sws742i.18.bdf
convertfont -n swiss742i.22 -o sws742i.22 -f 16 $FONT_SRC/sws742i.22.bdf
convertfont -n swiss742i.24 -o sws742i.24 -f 16 $FONT_SRC/sws742i.24.bdf
convertfont -n swiss742i.30 -o sws742i.30 -f 16 $FONT_SRC/sws742i.30.bdf
convertfont -n swiss742i.36 -o sws742i.36 -f 16 $FONT_SRC/sws742i.36.bdf

#echo "Converting mono fonts ..."

convertfont -n mono821.14 -o mon821.14 -f 16 $FONT_SRC/mon821.14.bdf
convertfont -n mono821.18 -o mon821.18 -f 16 $FONT_SRC/mon821.18.bdf
convertfont -n mono821.22 -o mon821.22 -f 16 $FONT_SRC/mon821.22.bdf
convertfont -n mono821.24 -o mon821.24 -f 16 $FONT_SRC/mon821.24.bdf
convertfont -n mono821.30 -o mon821.30 -f 16 $FONT_SRC/mon821.30.bdf
convertfont -n mono821.36 -o mon821.36 -f 16 $FONT_SRC/mon821.36.bdf

convertfont -n mono821b.14 -o mon821b.14 -f 16 $FONT_SRC/mon821b.14.bdf
convertfont -n mono821b.18 -o mon821b.18 -f 16 $FONT_SRC/mon821b.18.bdf
convertfont -n mono821b.22 -o mon821b.22 -f 16 $FONT_SRC/mon821b.22.bdf
convertfont -n mono821b.24 -o mon821b.24 -f 16 $FONT_SRC/mon821b.24.bdf
convertfont -n mono821b.30 -o mon821b.30 -f 16 $FONT_SRC/mon821b.30.bdf
convertfont -n mono821b.36 -o mon821b.36 -f 16 $FONT_SRC/mon821b.36.bdf

convertfont -n mono821i.14 -o mon821i.14 -f 16 $FONT_SRC/mon821i.14.bdf
convertfont -n mono821i.18 -o mon821i.18 -f 16 $FONT_SRC/mon821i.18.bdf
convertfont -n mono821i.22 -o mon821i.22 -f 16 $FONT_SRC/mon821i.22.bdf
convertfont -n mono821i.24 -o mon821i.24 -f 16 $FONT_SRC/mon821i.24.bdf
convertfont -n mono821i.30 -o mon821i.30 -f 16 $FONT_SRC/mon821i.30.bdf
convertfont -n mono821i.36 -o mon821i.36 -f 16 $FONT_SRC/mon821i.36.bdf


convertfont -n fix.7 -o fix.7 -f 16 $FONT_SRC/fix.7.bdf
convertfont -n fix.15 -o fix.15 -f 16 $FONT_SRC/fix.15.bdf

echo "Making Font Families File"
bldfamily -f 16
