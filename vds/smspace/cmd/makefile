# $Id: makefile,v 1.1.1.1 2001/01/04 21:07:37 cvs Exp $

# -------------------------------------------------------------------
# I/VDS
#
# File:	vds/smspace/cmd/makefile 
#
# Description:
#
# Dependencies:
#
# Revision History:
#	$Log: makefile,v $
#	Revision 1.1.1.1  2001/01/04 21:07:37  cvs
#	Initial import to CVS
#	
# History:
#	MM/DD/YY	AUTHOR		DESCRIPTION
#
# -------------------------------------------------------------------

target: sl \
	mkfile
	grmake -r -k -f mkfile 

sl: SMCmdVol.S \
	SMCmdLtdVol.S \
	SMCmdSkVol.S \
	SMCmdSpltSf.S \
	SMCmdSpltVl.S \
	SMCmdSfBnd.S \
	SMCmdVolBnd.S 

SMCmdVol.S : SMCmdVol.sl \
	${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
        ${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	slic -C -p$(VDS)/spec SMCmdVol.sl

SMCmdLtdVol.S : SMCmdLtdVol.sl \
	${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
        ${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	slic -C -p$(VDS)/spec SMCmdLtdVol.sl

SMCmdSkVol.S : SMCmdSkVol.sl \
	${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
        ${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	slic -C -p$(VDS)/spec SMCmdSkVol.sl

SMCmdSpltSf.S : SMCmdSpltSf.sl \
	${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
        ${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	slic -C -p$(VDS)/spec SMCmdSpltSf.sl

SMCmdSpltVl.S : SMCmdSpltVl.sl \
	${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
        ${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	slic -C -p$(VDS)/spec SMCmdSpltVl.sl

SMCmdSfBnd.S : SMCmdSfBnd.sl \
	${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
	${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	slic -C -p$(VDS)/spec SMCmdSfBnd.sl

SMCmdVolBnd.S : SMCmdVolBnd.sl \
	${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
	${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	slic -C -p$(VDS)/spec SMCmdVolBnd.sl

mkfile : smspacecom.m
	grmakemake smspacecom.m mkfile


clean:
	@rm -f mkfile *.o *.c

