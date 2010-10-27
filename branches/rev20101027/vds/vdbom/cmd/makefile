# $Id: make_PLOAD,v 1.1 2002/04/12 16:47:31 ylong Exp $

# -------------------------------------------------------------------
# I/VDS
#
# File:	vds/vdtbl/cmd/makefile 
#
# Description:
#
#   makefile for vdtbl commands directory
#
# Dependencies:
#
# Revision History:
#	$Log: make_PLOAD,v $
#	Revision 1.1  2002/04/12 16:47:31  ylong
#	*** empty log message ***
#	
#
# History:
#	MM/DD/YY	AUTHOR		DESCRIPTION
#	04/04/01	ylong		Created for 263 pload
# -------------------------------------------------------------------
# 
# TGT = vdctblcmd
#include ${VDS_PATH}/etc/makefiles/lib_only.h
#

target: sl \
	mkfile
	grmake -r -k -f mkfile

sl:	${VDS}/config/commands/VDCrBOM \
	${VDS}/config/commands/VDMdBOM


${VDS}/config/commands/VDCrBOM : VDCmdCrBom.t \
	${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
	${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	$(EXNUC)/bin/slic -p${VDS}/spec VDCmdCrBom.t

${VDS}/config/commands/VDMdBOM : VDCmdModBom.t \
	${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
	${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	$(EXNUC)/bin/slic -p${VDS}/spec VDCmdModBom.t


mkfile : VDbomcmd.m
	grmakemake VDbomcmd.m mkfile
