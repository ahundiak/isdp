# $Id: makefile,v 1.1.1.1 2001/01/04 21:07:43 cvs Exp $ 

#/***************************************************************************
# * I/VDS
# *
# * File:        vdat/ppl/makefile
# *
# * Description:
# *
# * Dependencies:
# *
# * Revision History:
# *      $Log: makefile,v $
# *      Revision 1.1.1.1  2001/01/04 21:07:43  cvs
# *      Initial import to CVS
# *
# Revision 1.1  1998/02/09  22:45:38  pinnacle
# AssyTree
#
# *
# * History:
# *      MM/DD/YY  AUTHOR DESCRIPTION
# *      02/09/98  ah     Creation
# ***************************************************************************/

target: pplmkfile
	grmake -r -k -f pplmkfile

pplmkfile: vdiatppl.m
	ksh ${VDS}/etc/bin/mkmkppl vdiatppl.m pplmkfile $(VDS)
