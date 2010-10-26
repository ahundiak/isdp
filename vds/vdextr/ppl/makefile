# $Id: makefile,v 1.2 2001/05/04 20:41:30 anand Exp $ 

#/***************************************************************************
# * I/VDS
# *
# * File:        vdextr/ppl/makefile
# *
# * Description:
# *
# * Dependencies:
# *
# * Revision History:
# *      $Log: makefile,v $
# *      Revision 1.2  2001/05/04 20:41:30  anand
# *      TR 5143
# *
# *      Revision 1.1.1.1  2001/01/04 21:08:48  cvs
# *      Initial import to CVS
# *
# Revision 1.1  1999/06/01  20:39:50  pinnacle
# dynapipe
#
# *
# * History:
# * MM/DD/YY  AUTHOR DESCRIPTION
# * 06/01/99  ah     Creation
# SKIP PPL
# ***************************************************************************/

target: pplmkfile
#	grmake -r -k -f pplmkfile

pplmkfile: vdxppl.m
	ksh ${VDS_PATH}/etc/bin/mkmkppl vdxppl.m pplmkfile $(VDS_PATH)
