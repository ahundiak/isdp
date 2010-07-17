# $Id: makefile,v 1.1.1.1 2001/01/04 21:12:05 cvs Exp $
#**********************************************************************
# I/ROUTE
#
# File:		config/english/menus/src/ makefile
#
# Description:
#	menu makefile - should be executed in this directory
#
# Dependencies:
#
# Revision History:
#	$Log: makefile,v $
#	Revision 1.1.1.1  2001/01/04 21:12:05  cvs
#	Initial import to CVS
#	
# Revision 1.2  1995/12/09  00:06:24  pinnacle
# Replaced: config/english/menus/src/makefile for:  by r240_int for route240
#
# Revision 1.1  1995/12/05  23:17:40  pinnacle
# Created: config/english/menus/src/makefile by r240_int for route240
#
#
# History:
#	12/05/95	tlb		Revised to use CPP_COMP, GENMENU
#					Simplified using make rule
#	12/08/95	tlb		Add clean
#
#**********************************************************************

MENUS 	= VRhdepkt.menu VRhdvpkt.menu VRhelpkt.menu VRhofpkt.menu 	\
	  VRhrdpkt.menu VRhtdpkt.menu VRhtepkt.menu VRhtrpkt.menu 	\
	  VRpan.menu    VRpcopkt.menu VRpelpkt.menu VRpflpkt.menu 	\
	  VRpinpkt.menu VRppepkt.menu VRprdpkt.menu VRpsppkt.menu	\
	  VRptepkt.menu VRpuspkt.menu VRpvlpkt.menu

CPP_OPT	= -P -Dems
#------------------

target:		${MENUS} 

clean:	
	@\rm *.menu
#----------------------------
.SUFFIXES:	.otl .menu

.otl.menu:
	$(CPP_COMP) $(CPP_OPT) $< | \
			awk '{ if ($$0 != "") print $$0 }' > $*.cpp
	@ $(GENMENU) $*.cpp ../$*.menu 
	@cp ../$*.menu .
	-rm -f $*.cpp
