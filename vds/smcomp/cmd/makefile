# $Id: make_PLOAD,v 1.1 2001/11/07 14:27:53 ylong Exp $

# -------------------------------------------------------------------
# I/VDS
#
# File:	vds/smcomp/cmd/make_PLOAD 
#
# Description:
#
# Dependencies:
#
# Revision History:
#	$Log: make_PLOAD,v $
#	Revision 1.1  2001/11/07 14:27:53  ylong
#	SP14 for TR3064
#	
#	Revision 1.1.1.1  2001/01/04 21:07:33  cvs
#	Initial import to CVS
#	
# Revision 1.5  1998/02/13  17:24:28  pinnacle
# Replaced: smcomp/cmd/makefile for:  by rchennup for vds
#
# Revision 1.4  1998/01/16  15:58:38  pinnacle
# oops
#
# Revision 1.3  1998/01/15  19:23:24  pinnacle
# makefile problem
#
# Revision 1.1  1997/05/08  15:01:06  pinnacle
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
# MM/DD/YY  AUTHOR  DESCRIPTION
# 01/15/98  ah      COComputAll.u no longer exists though the
#                   makefile was still trying to compile it
#                   I removed references to it
# -------------------------------------------------------------------

target: sl \
	mkfile
	grmake -r -k -f mkfile

sl: SMCmdComp.S \
	SMCmdCmpStp.S \
	SMCmdPost.S

SMCmdComp.S : SMCmdComp.sl \
        ${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
        ${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	slic -C -p${VDS}/spec SMCmdComp.sl

SMCmdCmpStp.S : SMCmdCmpStp.sl \
        ${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
        ${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	slic -C -p${VDS}/spec SMCmdCmpStp.sl

SMCmdPost.S : SMCmdPost.sl \
	${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
	${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	slic -C -p${VDS}/spec SMCmdPost.sl

mkfile : smcompcmd.m
	grmakemake smcompcmd.m mkfile
