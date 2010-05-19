# $Id: makefile,v 1.1.1.1 2001/01/04 21:09:23 cvs Exp $ 

#/***************************************************************************
# * I/VDS
# *
# * File:        vdsup/cmp/ppl/makefile
# *
# * Description:
# *
# * Dependencies:
# *
# * Revision History:
# *      $Log: makefile,v $
# *      Revision 1.1.1.1  2001/01/04 21:09:23  cvs
# *      Initial import to CVS
# *
# Revision 1.1  1997/12/17  21:56:38  pinnacle
# VDsupEtc
#
# Revision 1.2  1997/10/29  15:20:36  pinnacle
# Added Headers
#
# *
# * History:
# *      MM/DD/YY  AUTHOR DESCRIPTION
# *      12/17/97  ah     Creation
# ***************************************************************************/

target: pplmkfile
	grmake -r -k -f pplmkfile

pplmkfile: pplsup.m
	ksh ${VDS}/etc/bin/mkmkppl pplsup.m pplmkfile $(VDS)
