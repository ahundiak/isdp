# $Id: make_PLOAD,v 1.2 2002/04/12 20:48:34 ramarao Exp $

# -------------------------------------------------------------------
# I/VDS
#
# File:	vds/vdpocket/cmd/makefile 
#
# Description:
#
# Dependencies:
#
# Revision History:
#	$Log: make_PLOAD,v $
#	Revision 1.2  2002/04/12 20:48:34  ramarao
#	Moved elinmaster.sl file from emsfixes/grnuc to vdpocket/cmd directory.
#	
#	Revision 1.1  2002/01/18 15:27:35  ylong
#	*** empty log message ***
#	
#	Revision 1.1.1.1  2001/01/04 21:09:00  cvs
#	Initial import to CVS
#	
# Revision 1.1  1997/05/08  15:39:18  pinnacle
# rep bin w/txt
#
# Revision 1.6  1996/01/30  17:06:00  pinnacle
# Replaced: vdpocket/cmd/makefile for:  by azuurhou for vds.240
#
# Revision 1.5  1995/12/14  18:21:04  pinnacle
# Replaced: vdpocket/cmd/makefile for:  by azuurhou for vds.240
#
# Revision 1.4  1995/05/01  16:29:48  pinnacle
# Replace: vdpocket/cmd/makefile by azuurhou for OPE
#
# Revision 1.3  1995/04/28  14:56:52  pinnacle
# Replace: vdpocket/cmd/makefile by tdumbach for OPE
#
# Revision 1.2  1994/12/06  16:16:40  pinnacle
# Replaced:  vdpocket/cmd/makefile r#
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
#	12/15/95	adz		Delete VDCmdElInMV.
#	01/30/96	adz		Slic reference path missing.
#
# -------------------------------------------------------------------

target:	sl \
	mkfile
	grmake -r -k -f mkfile

sl:	VDCmdSlEl.S \
	VDCmdMVel.S \
	VDCmdQYmgr.S \
	VDCmdQYnpt.S \
	VDCmdPushCs.S \
	SMCmdPusHl.S \
	elinmaster.S \
	${VDS}/config/commands/VDQryCrt \
	${VDS}/config/commands/VDQrySel

VDCmdSlEl.S : VDCmdSlEl.sl \
	${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
	${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	${EXNUC}/bin/slic -C -p ${VDS}/spec VDCmdSlEl.sl

VDCmdMVel.S : VDCmdMVel.sl \
	${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
	${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	${EXNUC}/bin/slic -C -p ${VDS}/spec VDCmdMVel.sl

VDCmdQYmgr.S: VDCmdQYmgr.sl \
	${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
	${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	${EXNUC}/bin/slic -C -p ${VDS}/spec VDCmdQYmgr.sl

VDCmdQYnpt.S: VDCmdQYnpt.sl \
	${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
	${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	${EXNUC}/bin/slic -C -p ${VDS}/spec VDCmdQYnpt.sl

VDCmdPushCs.S : VDCmdPushCs.sl \
	${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
	${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	${EXNUC}/bin/slic -C -p ${VDS}/spec VDCmdPushCs.sl

SMCmdPusHl.S : SMCmdPusHl.sl \
	${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
	${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	${EXNUC}/bin/slic -C -p ${VDS}/spec SMCmdPusHl.sl

elinmaster.S : SMCmdPusHl.sl ${VDS}/include/VDmsg.h
	${EXNUC}/bin/slic -isTC elinmaster.sl

${VDS}/config/commands/VDQrySel: VDCmdQYsel.t \
	${GRNUC}/include/grmsg.h \
	${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
	${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	${EXNUC}/bin/slic -C -p ${VDS}/spec VDCmdQYsel.t

${VDS}/config/commands/VDQryCrt: VDCmdQYcrt.t \
	${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
	${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	${EXNUC}/bin/slic -C -p ${VDS}/spec VDCmdQYcrt.t

mkfile:	vdpockcmd.m
	grmakemake vdpockcmd.m mkfile
