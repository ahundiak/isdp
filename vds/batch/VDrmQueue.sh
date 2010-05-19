# $Id: VDrmQueue.sh,v 1.1.1.1 2001/01/04 21:07:19 cvs Exp $
#!/bin/ksh
#***********************************************************************
# I/VDS
#
# File:		batch/VDrmQueue.sh
#
# Description:	This script deletes the pipe and batch queue on user
#		request.	
#
# Dependencies:
#
# Usage:	Must be super-user to execute.
#
# Revision History
#	$Log: VDrmQueue.sh,v $
#	Revision 1.1.1.1  2001/01/04 21:07:19  cvs
#	Initial import to CVS
#	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.3  1995/12/13  00:14:22  pinnacle
# Replaced: batch/VDrmQueue.sh for:  by azuurhou for vds.240
#
# Revision 1.2  1995/12/12  16:51:38  pinnacle
# Replaced: batch/VDrmQueue.sh for:  by azuurhou for vds.240
#
# Revision 1.1  1995/07/25  21:00:46  pinnacle
# Created: batch/VDrmQueue.sh by azuurhou for vds.240
#
#
# History:
#	MM/DD/YY	AUTHOR		DESCRIPTION
#       07/19/95	G.Ravichandra   Creation
#
#*****************************************************************************
#
#-----------------------------------------------------------------------------
#
delreqque() {
	RC=0
qmgr <<!
abort queue $NAME
disable queue $NAME
purge queue $NAME
delete queue $NAME
!
return ${RC}
}
#
#-----------------------------------------------------------------------------
#
#
# Check if we are in the super-user mode.
#
uid=`id|awk '{print $1'}`
if [ "$uid" != "uid=0(root)" ] ; then
        echo "\n\tSorry: must be super-user to execute $0"
        exit 0 ;
fi

#
# Give the list of existing queue names.
#
rc=0
echo "\n\t**************QUEUE MENU***************** "
echo "\tQUEUE NAME         TYPE "
echo "\t******************************************"
qstat -p|awk -F@ '/@/{print "\t" $1 "\t\t " "PIPE"}'
qstat -b|awk -F@ '/@/{print "\t" $1 "\t\t " "BATCH"}'
echo "\t------------------------------------------"
echo "\n\tEnter the name : \c"
read NAME
while [ "$NAME" == "" ] ; do
	echo "\tQueue name expected."
	echo "\n\tEnter the name : \c"
	read NAME
	echo "NAME: $NAME"
done

#
# Check if queue is still interactive.
#
if ( qstat -a $NAME | grep "REQUEST ID">/dev/null ); then
	echo "\n\t***Queue has pending requests ! "
	echo "\t\tDo you want to procced say y(YES) or n(no)::"
	read FLG

	if([ $FLG = "y" ]); then
		delreqque
	else
		exit 0
	fi 
else
	delreqque
fi
exit ${rc}
