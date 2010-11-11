# $Id: makefile,v 1.1.1.1 2001/01/04 21:08:36 cvs Exp $

# -------------------------------------------------------------------
# I/VDS
#
# File:	vds/vddetail/func/makefile 
#
# Description:
#
# Dependencies:
#
# Revision History:
#	$Log: makefile,v $
#	Revision 1.1.1.1  2001/01/04 21:08:36  cvs
#	Initial import to CVS
#	
# History:
#	MM/DD/YY	AUTHOR		DESCRIPTION
#
# -------------------------------------------------------------------

target: mkfile
	grmake -r -k -f mkfile

mkfile : vddetlfnc.m
	grmakemake vddetlfnc.m mkfile

clean:
	@rm -f mkfile *.o *.c

