# $Id: makefile,v 1.1.1.1 2001/01/04 21:07:58 cvs Exp $

# -------------------------------------------------------------------
# I/VDS
#
# File:	vds/vdconvert/cmd/makefile 
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
# Revision 1.1  1997/05/08  15:27:32  pinnacle
# rep bin w/txt
#
# Revision 1.2  1995/07/24  16:42:48  pinnacle
# Replaced: vdconvert/cmd/makefile for:  by hverstee for vds.240
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

target: sl \
	mkfile
	grmake -r -k -f mkfile

sl: VDCmdupdbox.S \
	SMCmdCvtCmp.S \
	SMCmdCvtFrm.S \
	VDrtupdcls.S


VDCmdupdbox.S : VDCmdupdbox.sl \
	${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
	${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h 
	slic -C -p${VDS}/spec VDCmdupdbox.sl

SMCmdCvtCmp.S : SMCmdCvtCmp.sl \
	${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
	${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h 
	slic -C -p${VDS}/spec SMCmdCvtCmp.sl

SMCmdCvtFrm.S : SMCmdCvtFrm.sl \
	${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
	${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h 
	slic -C -p${VDS}/spec SMCmdCvtFrm.sl

VDrtupdcls.S : VDrtupdcls.sl \
	${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
	${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	slic -C -p${VDS}/spec VDrtupdcls.sl

mkfile: vdconvert.m
	grmakemake vdconvert.m mkfile

