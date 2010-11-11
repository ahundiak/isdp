# $Id: makefile,v 1.1.1.1 2001/01/04 21:08:36 cvs Exp $

# -------------------------------------------------------------------
# I/VDS
#
# File:	vds/vddetail/cmd/makefile 
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
# Revision 1.1  1997/05/08  15:30:28  pinnacle
# rep bin w/txt
#
# Revision 1.2  1995/07/29  16:15:28  pinnacle
# Replaced: vddetail/cmd/makefile for:  by azuurhou for vds.240
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/11  22:42:50  pinnacle
# updated files
#
#
# History:
#	MM/DD/YY	AUTHOR		DESCRIPTION
#
# -------------------------------------------------------------------

target: sl \
	mkfile
	grmake -r -k -f mkfile

sl: VDCmdDetail.S \
	VDCmdMdDet.S \
	VDCmdMdDvDp.S 

VDCmdDetail.S : VDCmdDetail.sl \
	VDSdr_vw_pl.t \
	VDSvw_pl.t \
        ${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
        ${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	$(EXNUC)/bin/slic -p${VDS}/spec VDCmdDetail.sl
	$(EXNUC)/bin/slic -C -p${VDS}/spec VDSdr_vw_pl.t
	$(EXNUC)/bin/slic -C -p${VDS}/spec VDSvw_pl.t

VDCmdMdDet.S : VDCmdMdDet.sl \
	${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
	${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	$(EXNUC)/bin/slic -C -p${VDS}/spec VDCmdMdDet.sl

VDCmdMdDvDp.S : VDCmdMdDvDp.sl \
	${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
	${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	$(EXNUC)/bin/slic -C -p${VDS}/spec VDCmdMdDvDp.sl

mkfile : vddetlcmd.m
	grmakemake vddetlcmd.m mkfile

clean:
	@rm -f mkfile *.o *.c
