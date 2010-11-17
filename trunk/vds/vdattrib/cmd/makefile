# $Id: makefile,v 1.1.1.1 2001/01/04 21:07:44 cvs Exp $

# -------------------------------------------------------------------
# I/VDS
#
# File:	vds/vdattrib/cmd/makefile 
#
# Description:
#
# Dependencies:
#
# Revision History:
#	$Log: makefile,v $
#	Revision 1.1.1.1  2001/01/04 21:07:44  cvs
#	Initial import to CVS
#	
# Revision 1.2  1997/06/12  20:06:42  pinnacle
# CR179527294: changed makefile to slic a .t file instead of a .sl file
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
#
# History:
#	MM/DD/YY	AUTHOR	DESCRIPTION
#
#	06/11/97	ejm	Discontinued using VDCmdUsrAtt.sl, replaced
#				with VDCmdUsrAtt.t and VDCmdUsrAtti.I
#				Changed lines were: 
#				    sl: VDCmdUsrAtt.S
#				    VDCmdUsrAtt.S : VDCmdUsrAtt.sl \
#				       slic -C -p${VDS}/spec VDCmdUsrAtt.sl
# -------------------------------------------------------------------------

target: sl \
	mkfile
	grmake -r -k -f mkfile

sl: ${VDS}/config/commands/VDMdUsrAtt

${VDS}/config/commands/VDMdUsrAtt: VDCmdUsrAtt.S VDCmdUsrAtt.t \
	${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
        ${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	slic -C -p${VDS}/spec VDCmdUsrAtt.t

mkfile: vdattrib.m
	grmakemake vdattrib.m mkfile

clean:
	@rm -f mkfile *.o *.c
