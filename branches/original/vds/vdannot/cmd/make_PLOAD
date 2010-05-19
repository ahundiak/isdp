# $Id: make_PLOAD,v 1.1 2001/09/14 15:06:09 ylong Exp $

# -------------------------------------------------------------------
# I/VDS
#
# File:	vds/vdannot/cmd/makefile 
#
# Description:
#
# Dependencies:
#
# Revision History:
#	$Log: make_PLOAD,v $
#	Revision 1.1  2001/09/14 15:06:09  ylong
#	highlight selected table
#	
#	Revision 1.1.1.1  2001/01/04 21:07:40  cvs
#	Initial import to CVS
#	
# Revision 1.1  1997/05/08  15:21:14  pinnacle
# rep bin w/txt
#
# Revision 1.3  1995/07/14  14:05:48  pinnacle
# Replaced: vdannot/cmd/makefile for:  by yzhu for vds.240
#
# Revision 1.2  1995/01/05  18:36:26  pinnacle
# Replaced: vdannot/cmd/makefile by tdumbach r#
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

target: sl\
	mkfile
	grmake -r -k -f mkfile

sl:	VDCmdFtxt.S \
	VDCmdRvItem.S \
	VDCmdDeItPr.S \
	${VDS}/config/commands/VDCrFrTx \
	${VDS}/config/commands/VDRdFrmTxt \
	${VDS}/config/commands/VDWrFrmTxt \
	${VDS}/config/commands/VDDeItPrDf

${VDS}/config/commands/VDWrFrmTxt : frmtxt_wrt.t \
	${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
	${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	$(EXNUC)/bin/slic -p${VDS}/spec frmtxt_wrt.t

${VDS}/config/commands/VDRdFrmTxt : frmtxt_read.t \
	${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
	${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	$(EXNUC)/bin/slic -p${VDS}/spec frmtxt_read.t


${VDS}/config/commands/VDCrFrTx : frmtxt_crt.t \
	${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
	${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	$(EXNUC)/bin/slic -p${VDS}/spec frmtxt_crt.t

${VDS}/config/commands/VDDeItPrDf : VDDeItmPre.t \
	${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
	${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	$(EXNUC)/bin/slic -p${VDS}/spec VDDeItmPre.t

VDCmdFtxt.S : VDCmdFtxt.sl \
	frmtxt_crt.t frmtxt_read.t frmtxt_wrt.t \
	${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
        ${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	$(EXNUC)/bin/slic -p${VDS}/spec VDCmdFtxt.sl

VDCmdRvItem.S : VDCmdRvItem.sl \
	${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
        ${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	slic -C -p${VDS}/spec VDCmdRvItem.sl

VDCmdDeItPr.S : VDCmdDeItPr.sl \
	${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
	${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	$(EXNUC)/bin/slic -C -p${VDS}/spec VDCmdDeItPr.sl

mkfile : vdannotcmd.m
	grmakemake vdannotcmd.m mkfile

