# $Id: VDserver.sh,v 1.1.1.1 2001/01/04 21:07:19 cvs Exp $
#!/bin/ksh
#***********************************************************************
# I/VDS
#
# File:		batch/VDserver.sh
#
# Description:	This shell script creates the batch queue on server with
#		priority = 16. Execute this script on command line with 
#		the queue name to be created, as command line argument.
#
# Dependencies:	Script must be executed in superuser mode.
#
# Usage:	VDserver.sh <batch_queue_name>
#
# Revision History
#	$Log: VDserver.sh,v $
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
# Revision 1.3  1995/12/13  00:12:50  pinnacle
# Replaced: batch/VDserver.sh for:  by azuurhou for vds.240
#
# Revision 1.2  1995/12/12  16:44:04  pinnacle
# Replaced: batch/VDserver.sh for:  by azuurhou for vds.240
#
# Revision 1.1  1995/07/25  21:00:32  pinnacle
# Created: batch/VDserver.sh by azuurhou for vds.240
#
#
# History:
#	MM/DD/YY	AUTHOR		DESCRIPTION
#       07/17/95        G.Ravichandra   Creation
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
	echo "\n\tUsage: VDserver.sh <batch_queue_name>"
	exit 0
fi

#
# Create the server queue.
#
qmgr <<!
create batch_queue $1 priority=16
set unrestricted_access $1
set per_process permfile_limit=(99999999b) $1
enable queue $1
start queue $1
!

#
# Inform about result.
#
echo "\n\tVDserver.sh : queue $1 created\n\n"
