# $Id: makefile,v 1.1.1.1 2001/01/04 21:09:32 cvs Exp $

# -------------------------------------------------------------------
# I/VDS
#
# File:	vds/vdvvol/cmd/makefile 
#
# Description:
#
# Dependencies:
#
# Revision History:
#	$Log: makefile,v $
#	Revision 1.1.1.1  2001/01/04 21:09:32  cvs
#	Initial import to CVS
#	
# Revision 1.1  1997/05/08  15:46:54  pinnacle
# rep bin w/txt
#
# Revision 1.1  1994/12/06  20:30:48  pinnacle
# Created:   vdvvol/cmd/makefile r#
#
#
#
# History:
#	MM/DD/YY	AUTHOR		DESCRIPTION
#
# -------------------------------------------------------------------

target:	sl \
	mkfile
	grmake -r -k -f mkfile

sl:	VDCmdMngVV.S

VDCmdMngVV.S : VDCmdMngVV.sl \
	${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
	${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	$(EXNUC)/bin/slic -C -p${VDS}/spec VDCmdMngVV.sl

mkfile:	vdvvolcmd.m
	grmakemake vdvvolcmd.m mkfile
