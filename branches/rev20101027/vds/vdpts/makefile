# $Id: makefile,v 1.1.1.1 2001/01/04 21:09:05 cvs Exp $
 
# -------------------------------------------------------------------
# I/VDS
#
# File: vds/vdpts/makefile
#
# Description:
#
# Dependencies:
#
# Revision History:
#       $Log: makefile,v $
#       Revision 1.1.1.1  2001/01/04 21:09:05  cvs
#       Initial import to CVS
#
# Revision 1.1  1997/05/30  09:18:02  pinnacle
# initial revision
#
# Revision 1.4  1995/12/15  14:58:52  pinnacle

target: sl mkfile
	grmake -r -k -f mkfile

sl:	${VDS}/config/commands/VDPlPts
 
${VDS}/config/commands/VDPlPts : VDCmdPlPts.t VDCmdPlPts.S   \
	${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h           \
	${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	$(EXNUC)/bin/slic -p${VDS}/spec VDCmdPlPts.t
 
mkfile: vdcptscmd.m
	grmakemake vdcptscmd.m mkfile



