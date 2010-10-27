# $Id: makefile,v 1.1.1.1 2001/01/04 21:07:38 cvs Exp $

# -------------------------------------------------------------------
# I/VDS
#
# File:	vds/smsurf/cmd/makefile 
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
# Revision 1.1  1997/05/08  15:17:54  pinnacle
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

target: sl \
	mkfile
	grmake -r -f mkfile

sl: SMCmdCcCmbr.S \
	SMCmdSlCmbr.S \
	SMCmdTrBk.S \
	SMCmdSlShr.S \
	SMCmdTrCrBk.S \
	SMCmdPtCmbr.S \
	SMCmdPtShr.S \
	SMCmdLgBk.S \
	SMCmdLgCrBk.S \
	${VDS}/config/commands/SMPlBulkHd

${VDS}/config/commands/SMPlBulkHd : SMCmdBulkHd.t \
        ${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
        ${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	$(EXNUC)/bin/slic -C -p$(VDS)/spec SMCmdBulkHd.t

SMCmdCcCmbr.S : SMCmdCcCmbr.sl \
        ${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
        ${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	slic -C -p$(VDS)/spec SMCmdCcCmbr.sl

SMCmdSlCmbr.S : SMCmdSlCmbr.sl \
        ${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
        ${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	slic -C -p$(VDS)/spec SMCmdSlCmbr.sl

SMCmdTrBk.S : SMCmdTrBk.sl \
        ${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
        ${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	slic -C -p$(VDS)/spec SMCmdTrBk.sl

SMCmdSlShr.S : SMCmdSlShr.sl \
        ${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
        ${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	slic -C -p$(VDS)/spec SMCmdSlShr.sl

SMCmdTrCrBk.S : SMCmdTrCrBk.sl \
        ${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
        ${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	slic -C -p$(VDS)/spec SMCmdTrCrBk.sl
	
SMCmdPtCmbr.S : SMCmdPtCmbr.sl \
        ${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
        ${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	slic -C -p$(VDS)/spec SMCmdPtCmbr.sl

SMCmdPtShr.S : SMCmdPtShr.sl \
        ${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
        ${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	slic -C -p$(VDS)/spec SMCmdPtShr.sl

SMCmdLgBk.S : SMCmdLgBk.sl \
        ${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
        ${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	slic -C -p$(VDS)/spec SMCmdLgBk.sl

SMCmdLgCrBk.S : SMCmdLgCrBk.sl \
        ${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
        ${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	slic -C -p$(VDS)/spec SMCmdLgCrBk.sl

mkfile: smsurfcmd.m
	grmakemake smsurfcmd.m mkfile 
	
