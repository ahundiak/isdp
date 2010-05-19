# $Id: VDSPost.sh,v 1.1.1.1 2001/01/04 21:07:19 cvs Exp $
#!/bin/ksh
#***********************************************************************
# I/VDS
#
# File:		batch/VDserver.sh
#
# Description:	This shell script creates the pipe queue on server with
#		priority = 31. Execute this script on command line with 
#		the queue name to be created, and the destinaton batch queue, 
#		as command line argument.
#
# Dependencies:	Script must be executed in superuser mode.
#
# Usage:	VDSPost.sh <pipe_queue_name> <batch_queue_name@destination>
#
# Revision History
#	$Log: VDSPost.sh,v $
#	Revision 1.1.1.1  2001/01/04 21:07:19  cvs
#	Initial import to CVS
#	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1997/04/03  15:27:56  pinnacle
# Shell script that creates pipe queue on a Clix client.
#
# Revision 1.3  1995/12/13  00:12:50  pinnacle
# Replaced: batch/VDSpost.sh for:  by Tawana L. Stalling for vds.241
#
#
# History:
#	MM/DD/YY	AUTHOR			DESCRIPTION
#       11/11/96        Tawana L. Stalling	Creation
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
if [ $# != 2 ] ; then
	echo "\n\tUsage: VDSPost.sh <pipe_queue_name> <batch_queue_name@destination>"
	exit 0
fi

#
# Create the server queue.
#
qmgr <<!
create pipe_queue $1 priority=31 server=(/usr/lib/nqs/pipeclient) destination=$2
enable queue $1
start queue $1
!

#
# Inform about result.
#
echo "\n\tVDSPost.sh : queue $1 destination $2 created\n\n"
