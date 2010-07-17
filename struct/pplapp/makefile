# $Id: makefile,v 1.2 2001/04/12 18:26:03 ramarao Exp $

# -------------------------------------------------------------------
# I/STRUCT
#
# File:	struct/pplapp/makefile 
#
# Description:
#
# Dependencies:
#
# Revision History:
#	$Log: makefile,v $
#	Revision 1.2  2001/04/12 18:26:03  ramarao
#	Fixed TR# 5015.
#	
#	Revision 1.1.1.1  2001/01/04 21:10:02  cvs
#	Initial import to CVS
#	
#
# History:
#	MM/DD/YY	AUTHOR		DESCRIPTION
#	01/20/00	ylong		creation
#	04/12/01	Rama Rao 	SP changes.
# -------------------------------------------------------------------

TGT = vsapps

target: pplmkfile
	grmake -r -k -f pplmkfile

pplmkfile: ${TGT}.m
	@if test ${ISDP_MAKE_SP} -eq 1; \
	then \
	   ksh $(STRUCT_PATH)/etc/bin/mkmkppl ${TGT}.m pplmkfile $(SP); \
	else \
	   ksh $(STRUCT_PATH)/etc/bin/mkmkppl ${TGT}.m pplmkfile $(STRUCT); \
	fi
