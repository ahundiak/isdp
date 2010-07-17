# $Id: makefile,v 1.1 2002/05/31 16:28:33 tlstalli Exp $

# -------------------------------------------------------------------
# I/EXTR4RVW
#
# File:		src/ppl/makefile 
#
# Description:
#
# Dependencies:
#
# Revision History:
#	$Log: makefile,v $
#	Revision 1.1  2002/05/31 16:28:33  tlstalli
#	Backup of PMA process from EXTR
#	
#	Revision 1.2  2001/01/26 20:17:47  build
#	*** empty log message ***
#	
#	Revision 1.1.1.1  2001/01/04 21:13:22  cvs
#	Initial import to CVS
#	
# Revision 1.1  1997/10/17  15:26:46  pinnacle
# initial revision
#
# Revision 1.1  1996/03/16  16:35:44  pinnacle
# Created: ./src/ppl/makefile by tlstalli for extr4rvw
#
#
# History:
#	MM/DD/YY	AUTHOR		DESCRIPTION
#
# -------------------------------------------------------------------

target: pplmkfile 
	grmake -r -k -f pplmkfile

pplmkfile: aimppl.m
	ksh ${EXTR4RVW}/etc/bin/aim_mkppl aimppl.m pplmkfile $(EXTR4RVW)
