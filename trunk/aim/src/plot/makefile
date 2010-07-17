# -------------------------------------------------------------------
# I/AIM
#
# File:		src/ppl/makefile 
#
# Description:
#
# Dependencies:
#
# Revision History:
#	$Log: makefile,v $
#	Revision 1.2  2002/05/22 21:17:25  ylong
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

pplmkfile: plotppl.m
	ksh ${AIM}/etc/bin/mkmkppl plotppl.m pplmkfile ${AIM}
