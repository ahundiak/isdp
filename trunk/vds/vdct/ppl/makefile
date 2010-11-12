# $Id: makefile,v 1.1.1.1 2001/01/04 21:08:01 cvs Exp $ 

#/***************************************************************************
# * I/VDS
# *
# * File:        vdct/ppl/makefile
# *
# * Description:
# *
# * Dependencies:
# *
# * Revision History:
# *      $Log: makefile,v $
# *      Revision 1.1.1.1  2001/01/04 21:08:01  cvs
# *      Initial import to CVS
# *
# Revision 1.1  1999/05/30  14:32:16  pinnacle
# ct
#
# *
# * History:
# * MM/DD/YY  AUTHOR DESCRIPTION
# * 05/29/99  ah     Creation
# ***************************************************************************/

target: pplmkfile
#	grmake -r -k -f pplmkfile

pplmkfile: vdictppl.m
	ksh ${VDS}/etc/bin/mkmkppl vdictppl.m pplmkfile $(VDS)

clean:
	@rm -f pplmkfile *.e

