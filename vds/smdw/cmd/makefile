# $Id: makefile,v 1.1.1.1 2001/01/04 21:07:34 cvs Exp $

# -------------------------------------------------------------------
# I/VDS
#
# File:	vds/smdw/cmd/makefile 
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
# Revision 1.1  1997/05/08  15:00:38  pinnacle
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

sl: SMCmdDw.S \
	SMCmdGrp.S 


SMCmdDw.S : SMCmdDw.sl \
        ${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
        ${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	$(EXNUC)/bin/slic -C -p${VDS}/spec SMCmdDw.sl

SMCmdGrp.S : SMCmdGrp.sl \
        ${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
        ${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	$(EXNUC)/bin/slic -C -p${VDS}/spec SMCmdGrp.sl

mkfile : smdwcmd.m
	grmakemake smdwcmd.m mkfile
