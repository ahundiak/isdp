# $Id: makefile,v 1.1 2002/05/31 16:30:40 tlstalli Exp $

# -------------------------------------------------------------------
# File:		makefile 
#
# Description:
#
# Dependencies:
#
# Revision History:
#	$Log: makefile,v $
#	Revision 1.1  2002/05/31 16:30:40  tlstalli
#	Backup of PMA process from EXTR
#	
#	Revision 1.1  2001/01/26 17:14:52  build
#	*** empty log message ***
#	
#	
# Revision 1.1  1999/11/15  15:22:04  pinnacle
# initial revision
#
#
# History:
#	MM/DD/YY	AUTHOR		DESCRIPTION
#
# -------------------------------------------------------------------

target: pplmkfile 
	grmake -r -k -f pplmkfile

pplmkfile: plotppl.m
	ksh ${EXTR4RVW}/etc/bin/aim_mkppl plotppl.m pplmkfile ${EXTR4RVW}
