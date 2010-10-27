#/* $Id: makefile,v 1.2 2001/01/08 19:07:23 art Exp $  */

#/***************************************************************************
# * I/VDS
# *
# * File:        vdtable/cmd/makefile
# *
# * Description: 
# *
# * Dependencies:
# *
# * Revision History:
# * $Log: makefile,v $
# * Revision 1.2  2001/01/08 19:07:23  art
# * ah
# *
# *
# * History:
# * MM/DD/YY  AUTHOR  DESCRIPTION
# * 01/04/01  ah      Creation
# *
# ***************************************************************************/
target: pplmkfile \
	mkfile
	grmake -r -k -f mkfile
#	grmake -r -k -f pplmkfile

mkfile:	vdtable.m
	grmakemake vdtable.m mkfile

pplmkfile: vdtblppl.m
	ksh $(VDS)/etc/bin/mkmkppl vdtblppl.m pplmkfile $(VDS)
