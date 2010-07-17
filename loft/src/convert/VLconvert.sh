#!/bin/ksh
# This shell script allows to convert design files from I/MANUF to I/LOFT.
# It can be used on several ways :
#
#	VLconvert.sh option [filename]
#
# 	option f : convert a specified design file
#		   example : VLconvert.sh f filename
#
#	option d : convert all the design files of the working directory
#		   example : VLconvert.sh d
#
#	option l : convert all the design files of the login directories
#		   example : VLconvert.sh l
#
#	option s : convert all the design files of the system directories
#		   example : VLconvert.sh s
#
#	filename : only used with option f

# Retrieve I/LOFT product path
if [ ! "$LOFT" ]; then
   LOFT=`echopath LOFT /usr/ip32/product_data`
   if [ ! "$LOFT" ]; then
      echo "<LOFT> entry not found in /usr/ip32/product_data"
      exit 1
   fi
fi
Isomfile="$LOFT/bin/IsOmFile"

# Retrieve I/MODEL product path
if [ ! "$MODEL" ]; then
   MODEL=`echopath MODEL /usr/ip32/product_data`
   if [ ! "$MODEL" ]; then
      echo "<MODEL> entry not found in /usr/ip32/product_data"
      exit 1
   fi
fi
Batch="$MODEL/bin/Model -p Loft -b -C \"ci=VLconvert\" -f "

# Retrieve <option>
Opt=$1
if [ "$Opt" != "f" -a "$Opt" != "d" -a "$Opt" != "l" -a "$Opt" != "s" ]; then
echo
echo "\tVLconvert.sh option [filename]"
echo
echo "\toption f : convert a specified design file"
echo "\t	   example : VLconvert.sh f filename"
echo
echo "\toption d : convert all the design files of the working directory"
echo "\t	   example : VLconvert.sh d"
echo
echo "\toption l : convert all the design files of the login directories"
echo "\t	   example : VLconvert.sh l"
echo
echo "\toption s : convert all the design files of the system directories"
echo "\t	   example : VLconvert.sh s"
echo
echo "\tfilename : only used with option f"
echo
   exit 2
fi

# Treat option <File>
if [ "$Opt" = "f" ]; then

   # Retrieve <filename>
   Filename=$2
   if [ ! "$Filename" ]; then
      echo "\tVLconvert.sh f \"filename\""
      exit 3
   else
      Find=$Filename
   fi
else

   # Treat option <Directory>
   if [ "$Opt" = "d" ]; then
      Find="*"
   else

      # Treat option <Login>
      if [ "$Opt" = "l" ]; then
         Find="~/*"
         Find=$HOME
      else

         # Treat option <System>
         if [ "$Opt" = "s" ]; then
            Find="/"
         fi
      fi
   fi
fi

# process files in <$Find>
find $Find -type f -exec $Isomfile {} \; -exec $Batch  {} \;
exit 0
