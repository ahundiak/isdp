# $Id: makefile,v 1.1.1.1 2001/01/04 21:07:19 cvs Exp $

# -------------------------------------------------------------------
# I/VDS
#
# File:	vds/cimacros/general/cmd/makefile 
#
# Description:
#
# Dependencies:
#
# Revision History:
#	$Log: makefile,v $
#	Revision 1.1.1.1  2001/01/04 21:07:19  cvs
#	Initial import to CVS
#	
# Revision 1.1  1997/05/08  15:49:34  pinnacle
# rep bin w/txt
#
# Revision 1.2  1995/09/25  21:15:00  pinnacle
# Replaced: cimacros/general/cmd/makefile for:  by sundar for vds.240
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
	grmake -r -k -f mkfile

mkfile: commands.m
	ksh ${VDS}/etc/bin/mkmkppl commands.m mkfile $(VDS)
