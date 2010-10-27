# $Id: VDclient.sh,v 1.1.1.1 2001/01/04 21:07:19 cvs Exp $
#!/bin/ksh
#***********************************************************************
# I/VDS
#
# File:		batch/VDclient.sh
#
# Description:	This  shell script is to create the pipe queue on client with
#		priority = 16. Execute this script on command line with the
#		queue name to be created, destination queue on server machine
#		and server name as command line argument.
#		This script must be executed in superuser mode.
#
# Dependencies:
#
# Revision History
#	$Log: VDclient.sh,v $
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
# Revision 1.4  1996/05/22  06:30:16  pinnacle
# Replaced: batch/VDclient.sh for:  by rgade for vds.240
#
# Revision 1.3  1995/12/13  00:13:16  pinnacle
# Replaced: batch/VDclient.sh for:  by azuurhou for vds.240
#
# Revision 1.2  1995/12/12  16:42:56  pinnacle
# Replaced: batch/VDclient.sh for:  by azuurhou for vds.240
#
# Revision 1.1  1995/07/25  21:00:18  pinnacle
# Created: batch/VDclient.sh by azuurhou for vds.240
#
#
# Usage:	VDclient.sh <pipe_queue name> <server queue> <server>
#
# History:
#	MM/DD/YY	AUTHOR		DESCRIPTION
#	07/17/95	G.Ravichandra   Creation
#
#******************************************************************************
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
# Check the list of input arguments.
#

if [ $# != 3 ] ; then
  echo "Usage: VDclient.sh <pipe_queue_name> <queue_name_server> <server>"
  exit 0
fi

#
# Create the queue.
#
if [ `uname -s` = "CLIX" ] ; then

qmgr <<!
create pipe_queue $1 priority=31 dest=($2@$3) server=(/usr/lib/nqs/pipeclient)
enable queue $1
start queue $1
!

else


qmgr <<!
create pipe_queue $1 priority=31 dest=($2@$3) server=(/opt/ingr/lib/nqs/pipeclient)
enable queue $1
start queue $1
!


fi
#

# Inform about result.
#
echo "\n\tVDclient.sh : queue $1 created"

