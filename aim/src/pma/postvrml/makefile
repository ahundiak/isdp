# $Id: makefile,v 1.1 2002/05/31 16:31:45 tlstalli Exp $

# -------------------------------------------------------------------
# File:		makefile 
#
# Description:
#
# Dependencies:
#
# Revision History:
#	$Log: makefile,v $
#	Revision 1.1  2002/05/31 16:31:45  tlstalli
#	Backup of PMA process from EXTR
#	
#	Revision 1.1.1.1  2001/01/04 21:13:25  cvs
#	Initial import to CVS
#	
#
# History:
#	MM/DD/YY	AUTHOR		DESCRIPTION
#
# -------------------------------------------------------------------

target: mkfile 
	grmake -r -k -f mkfile

mkfile: plotppl.m
	ksh /usr/plot/etc/bin/aim_mkppl plotppl.m mkfile /usr/plot
