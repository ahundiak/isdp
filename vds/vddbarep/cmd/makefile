# $Id: makefile,v 1.1.1.1 2001/01/04 21:08:33 cvs Exp $

# -------------------------------------------------------------------
# I/VDS
#
# File:	vds/vddbarep/cmd/makefile 
#
# Description:
#
# Dependencies:
#
# Revision History:
#	$Log: makefile,v $
#	Revision 1.1.1.1  2001/01/04 21:08:33  cvs
#	Initial import to CVS
#	
# Revision 1.1  1997/05/08  15:30:18  pinnacle
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

sl: VDCmdRpts.S 

VDCmdRpts.S : VDCmdRpts.sl \
	${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
	${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	slic -C -p${VDS}/spec VDCmdRpts.sl

mkfile : vddbarep.m
	grmakemake vddbarep.m mkfile

