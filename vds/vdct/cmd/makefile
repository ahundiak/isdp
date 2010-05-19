#/* $Id: makefile,v 1.1.1.1 2001/01/04 21:07:58 cvs Exp $  */

#/***************************************************************************
# * I/VDS
# *
# * File:        vdct/cmd/makefile
# *
# * Description: 
# *
# * Dependencies:
# *
# * Revision History:
# * $Log: makefile,v $
# * Revision 1.1.1.1  2001/01/04 21:07:58  cvs
# * Initial import to CVS
# *
# Revision 1.1  1999/05/30  14:30:52  pinnacle
# ct
#
# *
# * History:
# * MM/DD/YY  AUTHOR  DESCRIPTION
# * 05/29/99  ah      Creation
# *
# ***************************************************************************/
target: pplmkfile \
	mkfile
	grmake -r -k -f mkfile
	grmake -r -k -f pplmkfile

mkfile:	vdictcmd.m
	grmakemake vdictcmd.m mkfile

pplmkfile: vdictppl.m
	ksh $(VDS)/etc/bin/mkmkppl vdictppl.m pplmkfile $(VDS)
