# $Id: VDMoveFile.sh,v 1.1.1.1 2001/01/04 21:07:19 cvs Exp $
#!/bin/ksh

#***********************************************************************
# I/VDS
#
# File:         batch/VDMoveFile.sh
#
# Description:  This shell script waits for NQS to finish the remote batch
#		job and then copies files from <NQS_dir> directory to <usr_dir>.
#		We need this because NQS (rje) sends/gets files from the 
#		<NQS_dir> (most likely /tmp) directory on the client machine. 
#		The permissions on <NQS_dir> are wide open (ugo=rwx).
#		This shell lets the user get ownership of the received files. 
#
# Usage :       VDMoveFile.sh   <NQS_dir>
#                               <usr_dir>
#                               <flag_file>
#                               <time_stamp>
#                               <file1>
#                               <file2>
#				................
#
# where:
#
# <NQS_dir> 	NQS working directory on the client node. 
# <usr_dir> 	user working directory. Files are copied here.
# <flag_file>   This is the last file NQS sends back (NQS_error_file).
# <time_stamp>  The copy process begins when flag_file is newer than this one.
#		time_stamp must be created before the call to this shell. 
# <file1> 	File to get copied from <tmp_dir> to <pwdName>.
# <file2> 	File to get copied from <tmp_dir> to <pwdName>.
# ..................
#  
#****************************************************************************
#
# Revision History
#       $Log: VDMoveFile.sh,v $
#       Revision 1.1.1.1  2001/01/04 21:07:19  cvs
#       Initial import to CVS
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.4  1997/04/16  13:32:24  pinnacle
# Replaced: batch/VDMoveFile.sh for:  by kddinov for vds.241
#
# Revision 1.3  1997/04/08  20:48:56  pinnacle
# Replaced: batch/VDMoveFile.sh for:  by kddinov for vds.241
#
# Revision 1.2  1997/04/02  23:07:08  pinnacle
# Replaced: batch/VDMoveFile.sh for:  by kddinov for vds.241
#
#
#----------------------------------------------------------------------------
# HISTORY
# 3/97	KDD	creation 
#****************************************************************************

NUM_INPUTS=5			# minimum number of inputs 

#----------------------------------------------------------------------------
#  Utilities 
#----------------------------------------------------------------------------
Usage () {
  echo "Usage: $0 <NQS_dir> <usr_dir> <flag_file> <time_stamp> <file1> ...." 
}

#----------------------------------------------------------------------------
#  Main program 
#----------------------------------------------------------------------------

if [ "$#" -lt "$NUM_INPUTS" ]; then
        Usage;
	exit 1
fi

NQS_dir=$1
usr_dir=$2
NQS_error_file=$3
Time_Stamp_File=$4

#-------------------
# Wait until NQS_error_file gets newer date (& time) than Time_Stamp_File.
#-------------------
while [ ! -f $NQS_error_file ]; 
do
	sleep 60;
done 

DONE=""
while [ "$DONE" = "" ];
do
	sleep 60
	DONE="`find $NQS_error_file -newer $Time_Stamp_File -print`"
done

#-------------------
# Copy files $5, $6, .......
#-------------------
GET_FILE=1

for i in $*
do
     if [ "$GET_FILE" -ge "$NUM_INPUTS" ]; then
        cp $NQS_dir/$i $usr_dir/$i
     fi 

     GET_FILE="`echo $GET_FILE + 1 | bc `"

#    if [ "$i" != "$1" ] && [ "$i" != "$2" ] && [ "$i" != "$3" ]; then
#	cp $NQS_dir/$i $usr_dir
#    fi
done 

set +xv 

echo "NQS batch job is done"

exit 0


