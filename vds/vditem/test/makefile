#/* $Id: makefile,v 1.1 2001/01/10 18:04:42 art Exp $  */

#/***************************************************************************
# * I/VDS
# *
# * File:        vds/vdct1/test/makefile
# *
# * Description: 
# *
# * Dependencies:
# *
# * Revision History:
# * $Log: makefile,v $
# * Revision 1.1  2001/01/10 18:04:42  art
# * sp merge
# *
# Revision 1.1  2000/08/15  18:27:10  pinnacle
# ah
#
# *
# * History:
# * MM/DD/YY  AUTHOR  DESCRIPTION
# * 08/14/00  ah      Creation
# *
# ***************************************************************************/
target: pplmkfile \
	mkfile
	grmake -r -k -f mkfile
#	grmake -r -k -f pplmkfile

mkfile:	vdittest.m
	grmakemake vdittest.m mkfile

pplmkfile: vdittestppl.m
	ksh $(VDS)/etc/bin/mkmkppl vdittestppl.m pplmkfile $(VDS)

clean:
	@rm -f mkfile pplmkfile *.e *.o *.c
