# $Id: makefile,v 1.1.1.1 2001/01/04 21:07:33 cvs Exp $

# -------------------------------------------------------------------
# I/VDS
#
# File:	vds/smdrwcomp/cmd/makefile 
#
# Description:
#
# Dependencies:
#
# Revision History:
#	$Log: makefile,v $
#	Revision 1.1.1.1  2001/01/04 21:07:33  cvs
#	Initial import to CVS
#	
# Revision 1.1  1997/05/08  14:59:56  pinnacle
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

sl: SMCmdDrwCmp.S 

SMCmdDrwCmp.S : SMCmdDrwCmp.sl \
        ${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
        ${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	$(EXNUC)/bin/slic -C -p${VDS}/spec SMCmdDrwCmp.sl

mkfile : smdrwcpcmd.m
	grmakemake smdrwcpcmd.m mkfile
