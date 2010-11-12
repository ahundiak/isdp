# $Id: makefile,v 1.1.1.1 2001/01/04 21:07:38 cvs Exp $

# -------------------------------------------------------------------
# I/VDS
#
# File:	vds/smspace/vol/makefile 
#
# Description:
#
# Dependencies:
#
# Revision History:
#	$Log: makefile,v $
#	Revision 1.1.1.1  2001/01/04 21:07:38  cvs
#	Initial import to CVS
#	
# History:
#	MM/DD/YY	AUTHOR		DESCRIPTION
#
# -------------------------------------------------------------------

target: mkfile
	grmake -r -k -f mkfile 

mkfile : smspacevol.m
	grmakemake smspacevol.m mkfile

clean:
	@rm -f mkfile *.o
	@rm -f SMLtdVol.c SMSpltSrfi.c SMVBSMac.c SMLtdVoli.c SMSpltSrfMac.c SMSkVolMac.c
	@rm -f SMLtdVolMac.c SMSpltSrf.c SMVolBySplt.c SMSketchVol.c SMVolBySplti.c SMSketchVoli.c
