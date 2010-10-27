# $Id: makefile,v 1.1.1.1 2001/01/04 21:07:43 cvs Exp $
# -------------------------------------------------------------------
# I/VDS
#
# File:		vdat/report/makefile 
#
# Description:
#
# Dependencies:
#
# Revision History:
#	$Log: makefile,v $
#	Revision 1.1.1.1  2001/01/04 21:07:43  cvs
#	Initial import to CVS
#	
# Revision 1.1  1997/12/31  13:47:44  pinnacle
# Moved from vdastree
#
# Revision 1.2  1997/11/04  18:03:32  pinnacle
# Replaced: vdastree/report/makefile for:  by v250_int for vds
#
# Revision 1.1  1997/11/04  17:43:20  pinnacle
# Created: vdastree/report/makefile by v250_int for vds
#
#
# History:
#	MM/DD/YY	AUTHOR	DESCRIPTION
#	12/30/97	ah	moved to vdat
#
# -------------------------------------------------------------------------

target: sl\
	mkfile
	grmake -r -k -f mkfile

sl:	${VDS}/config/commands/VDGnCmpRep

${VDS}/config/commands/VDGnCmpRep : VDCmdReport.t \
	${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
	${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	${EXNUC}/bin/slic -p${VDS}/spec VDCmdReport.t

mkfile: vdastrep.m
	grmakemake vdastrep.m mkfile
