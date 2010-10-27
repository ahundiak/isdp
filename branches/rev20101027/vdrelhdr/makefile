#/* $Id: makefile,v 1.2 2001/01/08 19:05:31 art Exp $  */

#/***************************************************************************
# * I/VDS
# *
# * File:        vdrelhdr/makefile
# *
# * Description: 
# *
# * Dependencies:
# *
# * Revision History:
# * $Log: makefile,v $
# * Revision 1.2  2001/01/08 19:05:31  art
# * ah
# *
# *
# * History:
# * MM/DD/YY  AUTHOR  DESCRIPTION
# * 01/03/01  ah      Creation
# *
# ***************************************************************************/
target: pplmkfile \
	mkfile
	grmake -r -k -f mkfile
#	grmake -r -k -f pplmkfile

mkfile:	vdrelhdr.m
	grmakemake vdrelhdr.m mkfile

pplmkfile: vdrelppl.m
	ksh $(VDS)/etc/bin/mkmkppl vdrelppl.m pplmkfile $(VDS)
