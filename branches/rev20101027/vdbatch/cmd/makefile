# $Id: makefile,v 1.1.1.1 2001/01/04 21:07:56 cvs Exp $

# -------------------------------------------------------------------
# I/VDS
#
# File:		vdbatch/cmd/makefile
#
# Description:
#
# Dependencies:
#
# Revision History:
#	$Log: makefile,v $
#	Revision 1.1.1.1  2001/01/04 21:07:56  cvs
#	Initial import to CVS
#	
# Revision 1.1  1997/05/08  15:22:08  pinnacle
# rep bin w/txt
#
# Revision 1.2  1995/07/25  21:18:54  pinnacle
# Replaced: vdbatch/cmd/makefile for:  by azuurhou for vds.240
#
# Revision 1.1  1995/07/25  21:02:10  pinnacle
# Created: vdbatch/cmd/makefile by azuurhou for vds.240
#
#
# History:
#	MM/DD/YY	AUTHOR		DESCRIPTION
#	07/23/95	adz		creation date
#
# -------------------------------------------------------------------

target: sl \
	mkfile
	grmake -r -k -f mkfile

sl: VDCmdBatDrw.S

VDCmdBatDrw.S : VDCmdBatDrw.sl \
        ${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
        ${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	$(EXNUC)/bin/slic -C -p${VDS}/spec VDCmdBatDrw.sl

mkfile : vdbatchcmd.m
	grmakemake vdbatchcmd.m mkfile

