#/* $Id: makefile,v 1.1.1.1 2001/01/04 21:09:31 cvs Exp $  */

#/***************************************************************************
# * I/VDS
# *
# * File:        vdunwrap/makefile
# *
# * Description:
# *
# * Dependencies:
# *
# * Revision History:
# *      $Log: makefile,v $
# *      Revision 1.1.1.1  2001/01/04 21:09:31  cvs
# *      Initial import to CVS
# *
# Revision 1.1  1999/10/26  19:31:06  pinnacle
# ah
#
# *
# * History:
# * MM/DD/YY  AUTHOR  DESCRIPTION
# * 07/19/99  ah      creation
# *
# ***************************************************************************/

target: pplmkfile \
	mkfile
	grmake -r -k -f mkfile
#	grmake -r -k -f pplmkfile

mkfile:	vdiunwrap.m
	grmakemake vdiunwrap.m mkfile

pplmkfile: pplunwrap.m
	ksh $(VDS)/etc/bin/mkmkppl pplunwrap.m pplmkfile $(VDS)

clean:
	@rm -f mkfile pplmkfile *.e *.o *.c

