# $Id: makefile,v 1.1.1.1 2001/01/04 21:07:58 cvs Exp $

# -------------------------------------------------------------------
# I/VDS
#
# File:	vds/vdcheckin/ppl/makefile 
#
# Description:
#
# Dependencies:
#
# Revision History:
#	$Log: makefile,v $
#	Revision 1.1.1.1  2001/01/04 21:07:58  cvs
#	Initial import to CVS
#	
# Revision 1.1  1997/05/08  15:25:58  pinnacle
# rep bin w/txt
#
# Revision 1.2  1995/09/26  14:35:14  pinnacle
# Replaced: vdcheckin/ppl/makefile for:  by sundar for vds.240
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

mkfile: vdchkppl.m
	ksh ${VDS}/etc/bin/mkmkppl vdchkppl.m mkfile $(VDS)

clean:
	@rm -f mkfile *.e

