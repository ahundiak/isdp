# $Id: makefile,v 1.1.1.1 2001/01/04 21:07:34 cvs Exp $

# -------------------------------------------------------------------
# I/VDS
#
# File:	vds/smframe/cmd/makefile 
#
# Description:
#
# Dependencies:
#
# Revision History:
#	$Log: makefile,v $
#	Revision 1.1.1.1  2001/01/04 21:07:34  cvs
#	Initial import to CVS
#	
# Revision 1.1  1997/05/08  15:06:26  pinnacle
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
	grmake -r -f mkfile

sl: SMCmdPlMdFr.S \
	SMCmdDelFr.S \
	SMCmdModSct.S


SMCmdPlMdFr.S : SMCmdPlMdFr.sl \
        ${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
        ${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	slic -C -p${VDS}/spec SMCmdPlMdFr.sl

SMCmdDelFr.S : SMCmdDelFr.sl \
        ${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
        ${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	slic -C -p${VDS}/spec SMCmdDelFr.sl

SMCmdModSct.S : SMCmdModSct.sl \
        ${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
        ${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	slic -C -p${VDS}/spec SMCmdModSct.sl

mkfile : smframecmd.m
	grmakemake smframecmd.m mkfile

clean:
	@rm -f mkfile *.o *.c

