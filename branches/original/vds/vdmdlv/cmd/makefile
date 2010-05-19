# $Id: makefile,v 1.1.1.1 2001/01/04 21:08:56 cvs Exp $

# -------------------------------------------------------------------
# I/VDS
#
# File:	vds/vdmdlv/cmd/makefile 
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
# Revision 1.1  1997/05/08  15:37:42  pinnacle
# rep bin w/txt
#
# Revision 1.1  1994/12/06  21:22:32  pinnacle
# Created:   vdmdlv/cmd/makefile r#
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

sl:	VDCmdMngMV.S

VDCmdMngMV.S : VDCmdMngMV.sl \
	${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
	${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	$(EXNUC)/bin/slic -C -p${VDS}/spec VDCmdMngMV.sl

mkfile:	vdmdlvcmd.m
	grmakemake vdmdlvcmd.m mkfile
