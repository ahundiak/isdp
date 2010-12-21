# $Id: makefile,v 1.1.1.1 2001/01/04 21:08:50 cvs Exp $

# -------------------------------------------------------------------
# I/VDS
#
# File:	vds/vdgraphics/cmd/makefile 
#
# Description:
#
# Dependencies:
#
# Revision History:
#	$Log: makefile,v $
#	Revision 1.1.1.1  2001/01/04 21:08:50  cvs
#	Initial import to CVS
#	
# Revision 1.1  1997/05/08  15:34:32  pinnacle
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

target: mkfile
	grmake -r -k -f mkfile 

slx: VDCmdgrset.S \
	VDCmdsetop.S \
	VDCmdCpSurf.S



VDCmdCpSurf.S : VDCmdCpSurf.sl \
        ${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
        ${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	$(EXNUC)/bin/slic -C -p${VDS}/spec VDCmdCpSurf.sl

VDCmdgrset.S : VDCmdgrset.sl \
	${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
	${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	$(EXNUC)/bin/slic -C -p${VDS}/spec VDCmdgrset.sl

VDCmdsetop.S : VDCmdsetop.sl \
	${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
	${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	$(EXNUC)/bin/slic -C -p${VDS}/spec VDCmdsetop.sl

mkfile : vdgraphcmd.m
	grmakemake vdgraphcmd.m mkfile

clean:
	@rm -f mkfile *.o *.c

