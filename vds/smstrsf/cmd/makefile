# $Id: makefile,v 1.2 2001/01/08 18:58:03 art Exp $

# -------------------------------------------------------------------
# I/VDS
#
# File:	vds/smstrsf/cmd/makefile 
#
# Description:
#
# Dependencies:
#
# Revision History:
#	$Log: makefile,v $
#	Revision 1.2  2001/01/08 18:58:03  art
#	ah
#	
# Revision 1.1  1997/05/08  15:17:16  pinnacle
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
	pplmkfile  \
	mkfile  
	grmake -r -k -f mkfile 
	grmake -r -k -f pplmkfile

sl: SMCmdStrSf.S

SMCmdStrSf.S : SMCmdStrSf.sl \
        ${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
        ${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	slic -C -p${VDS}/spec SMCmdStrSf.sl

mkfile : smstrsfcmd.m
	grmakemake smstrsfcmd.m mkfile

pplmkfile: smstrsfppl.m
	ksh $(VDS)/etc/bin/mkmkppl smstrsfppl.m pplmkfile $(VDS)
