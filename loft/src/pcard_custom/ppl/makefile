# $Id: makefile,v 1.4 2002/04/02 23:13:50 ad Exp $
# *************************************************************************
# I/LOFT
#
#  File:        src/pcard_custom/ppl//makefile
#
#  Description:
#
#  Dependencies:
#
#  Revision History:
#       $Log: makefile,v $
#       Revision 1.4  2002/04/02 23:13:50  ad
#       Change option to chmod to avoid Fatal Error in makefile
#
#       Revision 1.3  2001/02/06 19:46:08  build
#       OK
#
#       Revision 1.2  2001/02/02 14:33:30  ramarao
#       Copies all .u and include files to src/api directory.
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
	cp $(LOFT)/src/pcard_custom/include/*.h $(PCARD)/.

pplmkfile: pcardppl.m
	ksh $(LOFT)/etc/bin/mkmkppl pcardppl.m pplmkfile $(LOFT)
