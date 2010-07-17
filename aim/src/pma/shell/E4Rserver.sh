# $Id: E4Rserver.sh,v 1.1 2002/05/31 16:32:13 tlstalli Exp $
#!/bin/ksh
#***********************************************************************
# EX4RVW241
#
# File:		batch/E4Rserver.sh
#
# Description:	This shell script creates the batch queue on server with
#		priority = 31. Execute this script on command line with 
#		the queue name to be created, as command line argument.
#
# Dependencies:	Script must be executed in superuser mode.
#
# Usage:	E4Rserver.sh <batch_queue_name>
#
#	REFERENCE
#	$Log: E4Rserver.sh,v $
#	Revision 1.1  2002/05/31 16:32:13  tlstalli
#	Backup of PMA process from EXTR
#	
#	Revision 1.1.1.1  2001/01/04 21:13:23  cvs
#	Initial import to CVS
#	
# Revision 1.1  1998/04/30  10:43:50  pinnacle
# EXTR 2.5.1
#
# Revision 1.1  1997/11/24  20:02:36  pinnacle
# shell script for the creation of the server queue.
#
#
#*****************************************************************************
#
# Check if we are in the super-user mode.
#
uid=`id|awk '{print $1'}`
if [ "$uid" != "uid=0(root)" ] ; then
        echo "\n\tSorry: must be super-user to execute $0"
        exit 0 ;
fi

#
# Check the list of input arguments.
#
if [ $# != 1 ] ; then
	echo "\n\tUsage: E4R.sh <batch_queue_name>"
	exit 0
fi

#
# Create the server queue.
#
qmgr <<!
create batch_queue $1 priority=31
set unrestricted_access $1
set per_process permfile_limit=(99999999b) $1
enable queue $1
start queue $1
!

#
# Inform about result.
#
echo "\n\tE4Rserver.sh : queue $1 created\n\n"
