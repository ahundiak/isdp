# $Id: makefile,v 1.1.1.1 2001/01/04 21:08:53 cvs Exp $

# -------------------------------------------------------------------
# I/VDS
#
# File:	vds/vdlocate/cmd/makefile 
#
# Description:
#
# Dependencies:
#
# Revision History:
#	$Log: makefile,v $
#	Revision 1.1.1.1  2001/01/04 21:08:53  cvs
#	Initial import to CVS
#	
# Revision 1.1  1997/05/08  15:36:32  pinnacle
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

target: sl\
	mkfile
	grmake -r -k -f mkfile

sl: VDS_LOCATE.S\
    VDCmdLcNm.S \
    VDCmdRdLcNm.S \
    VDCmdWtLcNm.S 


VDS_LOCATE.S : VDS_LOCATE.sl \
	${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
        ${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	slic VDS_LOCATE.sl

VDCmdLcNm.S : VDCmdLcNm.sl \
	${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
        ${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	slic -C -p${VDS}/spec VDCmdLcNm.sl

VDCmdRdLcNm.S : VDCmdRdLcNm.sl \
	${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
        ${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	slic -C -p${VDS}/spec VDCmdRdLcNm.sl

VDCmdWtLcNm.S : VDCmdWtLcNm.sl \
	${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
        ${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	slic -C -p${VDS}/spec VDCmdWtLcNm.sl


mkfile: vdloccmd.m
	grmakemake vdloccmd.m mkfile

