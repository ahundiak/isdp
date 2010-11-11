# $Id: makefile,v 1.1.1.1 2001/01/04 21:08:43 cvs Exp $

# -------------------------------------------------------------------
# I/VDS
#
# File:	vds/vdequip/ppl/makefile 
#
# Description:
#
# Dependencies:
#
# Revision History:
#	$Log: makefile,v $
#	Revision 1.1.1.1  2001/01/04 21:08:43  cvs
#	Initial import to CVS
#	
# Revision 1.1  1997/05/08  15:33:38  pinnacle
# rep bin w/txt
#
# Revision 1.2  1995/09/26  15:52:54  pinnacle
# Replaced: vdequip/ppl/makefile for:  by sundar for vds.240
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

mkfile: VDSequipppl.m
	ksh ${VDS}/etc/bin/mkmkppl VDSequipppl.m mkfile $(VDS)

clean:
	@rm -f mkfile *.e

