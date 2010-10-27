# $Id: makefile,v 1.1.1.1 2001/01/04 21:08:36 cvs Exp $

# -------------------------------------------------------------------
# I/VDS
#
# File:	vds/vddgninfo/cmd/makefile 
#
# Description:
#
# Dependencies:
#
# Revision History:
#	$Log: makefile,v $
#	Revision 1.1.1.1  2001/01/04 21:08:36  cvs
#	Initial import to CVS
#	
#
# History:
#	MM/DD/YY	AUTHOR		DESCRIPTION
#	06/07/97	yzhu		creation date
#
# -------------------------------------------------------------------

target: sl \
	${VDS}/config/commands/VDDgnStp	\
	mkfile 
	grmake -r -k -f mkfile

sl 	:VDCmdDgnPrm.S	
	
VDCmdDgnPrm.S : VDCmdDgnPrm.sl \
	${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
	${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	slic -CT -p$(VDS)/spec VDCmdDgnPrm.sl

mkfile : vddgnparcmd.m
	grmakemake vddgnparcmd.m mkfile

