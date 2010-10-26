# $Id: makefile,v 1.1.1.1 2001/01/04 21:08:55 cvs Exp $

# -------------------------------------------------------------------
# I/VDS
#
# File:		vdloft/ppl/makefile 
#
# Description:
#
# Dependencies:
#
# Revision History:
#	$Log: makefile,v $
#	Revision 1.1.1.1  2001/01/04 21:08:55  cvs
#	Initial import to CVS
#	
# Revision 1.1  1997/05/08  15:37:14  pinnacle
# rep bin w/txt
#
# Revision 1.1  1996/03/24  19:30:50  pinnacle
# Created: ./vdloft/ppl/makefile by azuurhou for vds.240
#
#
# History:
#	MM/DD/YY	AUTHOR		DESCRIPTION
#
# -------------------------------------------------------------------

target: mkfile 
#	grmake -r -k -f mkfile

mkfile: vdloftppl.m
	ksh ${VDS}/etc/bin/mkmkppl vdloftppl.m mkfile $(VDS)
