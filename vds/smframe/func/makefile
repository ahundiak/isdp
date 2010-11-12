# $Id: makefile,v 1.1.1.1 2001/01/04 21:07:35 cvs Exp $

# -------------------------------------------------------------------
# I/VDS
#
# File:	vds/smframe/func/makefile 
#
# Description:
#
# Dependencies:
#
# Revision History:
#	$Log: makefile,v $
#	Revision 1.1.1.1  2001/01/04 21:07:35  cvs
#	Initial import to CVS
#	
# History:
#	MM/DD/YY	AUTHOR		DESCRIPTION
#
# -------------------------------------------------------------------

target: mkfile 
	grmake -r -f mkfile


mkfile : smframefc.m
	grmakemake smframefc.m mkfile

clean:
	@rm -f mkfile *.o *.c

