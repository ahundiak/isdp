# $Id: makefile,v 1.1.1.1 2001/01/04 21:08:53 cvs Exp $

# -------------------------------------------------------------------
# I/VDS
#
# File:	vds/vdlocate/func/makefile 
#
# Description:
#
# Dependencies:
#
# Revision History:
#	$Log: makefile,v $
#	Revision 1.1.1.1  2001/01/04 21:08:53  cvs
#	Initial import to CVS
#	
# Revision 1.1  1997/05/08  15:36:40  pinnacle
# rep bin w/txt
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

target: VDSexp.c \
	mkfile
	grmake -r -k -f mkfile


VDSexp.c : vdsexp.l
	makelex

mkfile: vdlocfc.m
	grmakemake vdlocfc.m mkfile

