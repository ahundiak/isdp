# $Id: makefile,v 1.1.1.1 2001/01/04 21:09:31 cvs Exp $

# -------------------------------------------------------------------
# I/VDS
#
# File:	vds/vdudp/cmd/makefile 
#
# Description:
#
# Dependencies:
#
# Revision History:
#	$Log: makefile,v $
#	Revision 1.1.1.1  2001/01/04 21:09:31  cvs
#	Initial import to CVS
#	
# Revision 1.1  1997/05/08  15:46:08  pinnacle
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
	grmake -r -k -f mkfile


sl: VDCmdPath.S \
	VDCmdPathLd.S \
	VDCmdPathRd.S \
	VDCmdPathWr.S \
	VDCmdPathAc.S \
	VDCmdPathSt.S \
	VDCmdPathSr.S \
	VDCmdPathRv.S 

VDCmdPath.S : VDCmdPath.sl \
	${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
        ${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	slic -C -p${VDS}/spec VDCmdPath.sl

VDCmdPathLd.S : VDCmdPathLd.sl \
	${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
        ${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	slic -C -p${VDS}/spec VDCmdPathLd.sl

VDCmdPathRd.S : VDCmdPathRd.sl \
	${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
        ${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	slic -C -p${VDS}/spec VDCmdPathRd.sl

VDCmdPathWr.S : VDCmdPathWr.sl \
	${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
        ${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	slic -C -p${VDS}/spec VDCmdPathWr.sl

VDCmdPathAc.S : VDCmdPathAc.sl \
	${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
        ${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	slic -C -p${VDS}/spec VDCmdPathAc.sl

VDCmdPathSt.S : VDCmdPathSt.sl \
	${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
        ${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	slic -C -p${VDS}/spec VDCmdPathSt.sl

VDCmdPathSr.S : VDCmdPathSr.sl \
	${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
        ${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	slic -C -p${VDS}/spec VDCmdPathSr.sl

VDCmdPathRv.S : VDCmdPathRv.sl \
	${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
        ${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	slic -C -p${VDS}/spec VDCmdPathRv.sl

mkfile: vdudpcmd.m
	grmakemake vdudpcmd.m mkfile
