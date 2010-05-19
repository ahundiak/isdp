# $Id: makefile,v 1.1.1.1 2001/01/04 21:07:58 cvs Exp $

# -------------------------------------------------------------------
# I/VDS
#
# File:	vds/vdcoll/cmd/makefile 
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
# Revision 1.1  1997/05/08  15:26:42  pinnacle
# rep bin w/txt
#
# Revision 1.3  1995/05/09  15:58:54  pinnacle
# Replace: vdcoll/cmd/makefile by tdumbach for OPE
#
# Revision 1.2  1994/12/08  20:43:02  pinnacle
# Replaced:  vdcoll/cmd/makefile r#
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

sl:	VDCmdDpQrDf.S

VDCmdDpQrDf.S : VDCmdDpQrDf.sl \
	${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
	${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	$(EXNUC)/bin/slic -C -p${VDS}/spec VDCmdDpQrDf.sl

mkfile:	vdcollcmd.m
	grmakemake vdcollcmd.m mkfile
