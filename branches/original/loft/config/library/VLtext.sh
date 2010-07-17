#!/bin/ksh
#
#***********************************************************************
# I/LOFT
#
# File:		config/library/VLtext.sh
#
# Description:
#		Script to copy the VLtext macro-library in $LOFT/ppl/bin
#
# Dependencies:
#		Local libraries and design files.
#
# History:
#	MM/DD/YY	AUTHOR		DESCRIPTION
#
#***********************************************************************
# 

path="`dirname $0`"

man_dut="VLtext_dut"
man_eng="VLtext_eng"
man_fra="VLtext_fra"
man_pol="VLtext_pol"
man_txt="VLtext"

dut_path="$path/$man_dut"
eng_path="$path/$man_eng"
fra_path="$path/$man_fra"
pol_path="$path/$man_pol"
tgt_path="$path/../../ppl/bin/$man_txt"

# Ask user choice
echo "Templates texts will be (Dutch/English/French/Polish/eXit) ? [X] : \c"
read resp
if [ -z "$resp" ]; then
   resp="X"
fi

if [ $resp = "x" -o $resp = "X" ]; then
   echo "Exit with no modifications"
   exit 0
fi

if [ $resp = "d" -o $resp = "D" ]; then
   if [ -f $dut_path ]; then
      copyOS $dut_path $tgt_path
      echo "Library [$dut_path] copied in [$tgt_path]"
      exit 0
   else
      echo "Library [$dut_path] not found"
      exit 1
   fi
fi

if [ $resp = "e" -o $resp = "E" ]; then
   if [ -f $eng_path ]; then
      copyOS $eng_path $tgt_path
      echo "Library [$eng_path] copied in [$tgt_path]"
      exit 0
   else
      echo "Library [$eng_path] not found"
      exit 2
   fi
fi

if [ $resp = "f" -o $resp = "F" ]; then
   if [ -f $fra_path ]; then
      copyOS $fra_path $tgt_path
      echo "Library [$fra_path] copied in [$tgt_path]"
      exit 0
   else
      echo "Library [$fra_path] not found"
      exit 3
   fi
fi

if [ $resp = "p" -o $resp = "P" ]; then
   if [ -f $pol_path ]; then
      copyOS $pol_path $tgt_path
      echo "Library [$pol_path] copied in [$tgt_path]"
      exit 0
   else
      echo "Library [$pol_path] not found"
      exit 4
   fi
fi

exit 5
