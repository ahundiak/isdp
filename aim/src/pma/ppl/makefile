# $Id: makefile,v 1.1 2002/05/31 16:32:03 tlstalli Exp $

# -------------------------------------------------------------------
# I/EXTR4RVW
#
# File:		pma/ppl/makefile 
#
# Description:
#
# Dependencies:
#
# Revision History:
#	$Log: makefile,v $
#	Revision 1.1  2002/05/31 16:32:03  tlstalli
#	Backup of PMA process from EXTR
#	
#	Revision 1.2  2001/01/26 20:27:52  build
#	*** empty log message ***
#	
#	Revision 1.1.1.1  2001/01/04 21:13:23  cvs
#	Initial import to CVS
#	
# Revision 1.1  1997/10/17  21:30:56  pinnacle
# initial revision
#
# Revision 1.1  1996/03/16  16:35:44  pinnacle
# Created: ./pma/ppl/makefile by tlstalli for extr4rvw
#
#
# History:
#	MM/DD/YY	AUTHOR		DESCRIPTION
#
# -------------------------------------------------------------------

target: pplmkfile 
	grmake -r -k -f pplmkfile

pplmkfile: PDU_E4RB.m
	ksh ${EXTR4RVW}/etc/bin/pdue4rb_mkppl PDU_E4RB.m pplmkfile $(EXTR4RVW)
