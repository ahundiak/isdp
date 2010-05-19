# $Id: makefile,v 1.1.1.1 2001/01/04 21:09:05 cvs Exp $

# -------------------------------------------------------------------
# I/VDS
#
# File:	vds/vdproject/cmd/makefile 
#
# Description:
#
# Dependencies:
#
# Revision History:
#	$Log: makefile,v $
#	Revision 1.1.1.1  2001/01/04 21:09:05  cvs
#	Initial import to CVS
#	
# Revision 1.1  1997/05/08  15:40:40  pinnacle
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

sl: VDCmdProj.S 

VDCmdProj.S : VDCmdProj.sl \
	${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
        ${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	slic -C -p${VDS}/spec VDCmdProj.sl

mkfile : vdprojcmd.m
	grmakemake vdprojcmd.m mkfile

