# $Id: makefile,v 1.3 2002/05/22 21:18:48 ylong Exp $
# -------------------------------------------------------------------
# I/AIM
#
# File:		src/vrml/makefile 
#
# Description:
#
# Dependencies:
#
# Revision History:
#	$Log: makefile,v $
#	Revision 1.3  2002/05/22 21:18:48  ylong
#	*** empty log message ***
#	
#	Revision 1.2  2002/05/06 19:45:54  ahundiak
#	*** empty log message ***
#	
#	Revision 1.1.1.1  2001/06/01 20:06:28  tlstalli
#	Creating aim module
#	
#	
# History:
#	MM/DD/YY	AUTHOR		DESCRIPTION
#
# -------------------------------------------------------------------

target: pplmkfile 
	grmake -r -k -f pplmkfile

pplmkfile: vrmlppl.m
	ksh ${AIM}/etc/bin/mkmkppl vrmlppl.m pplmkfile ${AIM}
