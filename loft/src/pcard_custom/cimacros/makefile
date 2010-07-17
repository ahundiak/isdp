# $Id: makefile,v 1.4 2002/04/02 23:15:32 ad Exp $
# *************************************************************************
# I/LOFT
#
#  File:        src/pcard_custom/cimacros//makefile
#
#  Description:
#
#  Dependencies:
#
#  Revision History:
#       $Log: makefile,v $
#       Revision 1.4  2002/04/02 23:15:32  ad
#       Update chmod with -f option to avoid Fatal Error.
#
#       Revision 1.3  2001/02/06 19:46:08  build
#       OK
#
#       Revision 1.2  2001/02/02 14:32:54  ramarao
#       Copies all .u files to src/api directory.
#
#
#  History:
#       MM/DD/YY   AUTHOR       DESCRIPTION
#       02/02/01   Rama Rao     File Creation
# ************************************************************************/
PCARD=$(LOFT)/api/pcard

target: pplmkfile
	grmake -r -k -f pplmkfile
	mkdir -p $(PCARD)
	chmod -f +w $(PCARD)/*
	cp *.u $(PCARD)/.

pplmkfile: pcardci.m
	ksh $(LOFT)/etc/bin/mkmkppl pcardci.m pplmkfile $(LOFT)
