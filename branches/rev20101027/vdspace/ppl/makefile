# $Id: makefile,v 1.1.1.1 2001/01/04 21:09:23 cvs Exp $

# -------------------------------------------------------------------
# I/VDS
#
# File:	vdspace/ppl/makefile 
#
# Description:
#
# Dependencies:
#
# Revision History:
#	$Log: makefile,v $
#	Revision 1.1.1.1  2001/01/04 21:09:23  cvs
#	Initial import to CVS
#	
# Revision 1.1  1997/05/08  15:43:20  pinnacle
# rep bin w/txt
#
# Revision 1.2  1995/11/24  17:41:28  pinnacle
# Replaced: vdspace/ppl/makefile for:  by azuurhou for vds.240
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
#
# History:
#	MM/DD/YY	AUTHOR		DESCRIPTION
#
# -------------------------------------------------------------------

target: mkfile
#	grmake -r -k -f mkfile

mkfile: vdspaceppl.m
	ksh ${VDS}/etc/bin/mkmkppl vdspaceppl.m mkfile $(VDS)

