#!/bin/ksh
# $Id: makefile,v 1.2 2001/01/30 20:06:27 build Exp $
# ====
# $Log: makefile,v $
# Revision 1.2  2001/01/30 20:06:27  build
# Add a header
#
#
#===============


target:	sl \
	mkfile
	grmake -r -k -f mkfile

sl :	VDPCmdEnab.S \
	VDPCmdShEn.S \
	${VDS}/config/commands/VDPEnabItm \
	${VDS}/config/commands/VDPShEnIt

${VDS}/config/commands/VDPEnabItm: VDPCmdEnab.t \
	${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
	${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	slic -p${VDS}/spec VDPCmdEnab.t

${VDS}/config/commands/VDPShEnIt: VDPCmdShEn.t \
	${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
	${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	slic -p${VDS}/spec VDPCmdShEn.t

mkfile:	vdpenbcmd.m
	grmakemake vdpenbcmd.m mkfile
