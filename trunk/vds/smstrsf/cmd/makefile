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
# History:
#	MM/DD/YY	AUTHOR		DESCRIPTION
#
# -------------------------------------------------------------------

target: sl \
	pplmkfile  \
	mkfile  
	grmake -r -k -f mkfile 
#	grmake -r -k -f pplmkfile

sl: SMCmdStrSf.S

SMCmdStrSf.S : SMCmdStrSf.sl \
        ${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
        ${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	slic -C -p${VDS}/spec SMCmdStrSf.sl

mkfile : smstrsfcmd.m
	grmakemake smstrsfcmd.m mkfile

pplmkfile: smstrsfppl.m
	ksh $(VDS)/etc/bin/mkmkppl smstrsfppl.m pplmkfile $(VDS)

clean:
	@rm -f mkfile pplmkfile *.e *.o *.c

