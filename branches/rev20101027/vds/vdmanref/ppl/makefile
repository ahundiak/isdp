# $Id: makefile,v 1.1.1.1 2001/01/04 21:08:56 cvs Exp $

# -------------------------------------------------------------------
# I/VDS
#
# File:		vdmanref/ppl/makefile 
#
# Description:
#
# Dependencies:
#
# Revision History:
#	$Log: makefile,v $
#	Revision 1.1.1.1  2001/01/04 21:08:56  cvs
#	Initial import to CVS
#	
#
# History:
#	MM/DD/YY	AUTHOR		DESCRIPTION
#       12/17/97      Adz & Ming        Creation
#
# -------------------------------------------------------------------

target: mkfile 
#	grmake -r -k -f mkfile

mkfile: manref.m
	ksh ${VDS}/etc/bin/mkmkppl manref.m mkfile $(VDS)
