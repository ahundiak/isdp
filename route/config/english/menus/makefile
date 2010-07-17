# $Id: makefile,v 1.2 2001/01/26 15:05:48 build Exp $
#**********************************************************************
# I/ROUTE
#
# File:	config/english/menus/makefile
#
# Description:
#	menu makefile - should be executed in this directory
#		IMROUTE 	required for sitchprod
#		PANEL_MENU	required for loading
#
# Dependencies:
#
# Revision History:
#	$Log: makefile,v $
#	Revision 1.2  2001/01/26 15:05:48  build
#	*** empty log message ***
#	
#	Revision 1.1.1.1  2001/01/04 21:12:05  cvs
#	Initial import to CVS
#	
# Revision 1.7  1996/03/23  18:53:00  pinnacle
# Replaced: config/english/menus/makefile for:  by azuurhou for route240
#
# Revision 1.6  1995/12/12  19:00:20  pinnacle
# Replaced: config/english/menus/makefile for:  by r240_int for route240
#
# Revision 1.5  1995/12/09  00:06:38  pinnacle
# Replaced: config/english/menus/makefile for:  by r240_int for route240
#
# Revision 1.4  1995/12/08  20:59:00  pinnacle
# Replaced: config/english/menus/makefile for:  by r240_int for route240
#
# Revision 1.3  1995/12/05  23:16:48  pinnacle
# Replaced: config/english/menus/makefile for:  by r240_int for route240
#
#
# History:
#	12/05/95	tlb		Revised to use src/makefile
#	12/08/95	tlb		Revised to produce PANEL_MENU. IMROUTE
#	12/08/95	tlb		Add clean
#	12/12/95	tlb		Use existing names in VRco.h
#	12/08/98	Alwin		removed "src". Make all.
#
#**********************************************************************
SRC=$(ROUTE)/config/english/menus/src

MENUS 	= VRHDEPKT_MENU VRHDVPKT_MENU VRHELPKT_MENU VRHOFPKT_MENU       \
          VRHRDPKT_MENU VRHTDPKT_MENU VRHTEPKT_MENU VRHTRPKT_MENU       \
          VRPCOPKT_MENU VRPELPKT_MENU VRPFLPKT_MENU VRPINPKT_MENU 	\
	  VRPPEPKT_MENU VRPRDPKT_MENU VRPSPPKT_MENU VRPTEPKT_MENU 	\
	  VRPUSPKT_MENU VRPVLPKT_MENU PANEL_MENU    IMROUTE

target:	${MENUS}

PANEL_MENU:	$(SRC)/VRpan.menu
	@\cp $(SRC)/VRpan.menu PANEL_MENU
	@./gen_pantbl
	@./gen_getcmdpath

IMROUTE:	PANEL_MENU
	@\cp PANEL_MENU IMROUTE

VRHDEPKT_MENU:	$(SRC)/VRhdepkt.menu
	@\cp $(SRC)/VRhdepkt.menu VRHDEPKT_MENU

VRHDVPKT_MENU:	$(SRC)/VRhdvpkt.menu
	@\cp $(SRC)/VRhdvpkt.menu VRHDVPKT_MENU

VRHELPKT_MENU:	$(SRC)/VRhelpkt.menu
	@\cp $(SRC)/VRhelpkt.menu VRHELPKT_MENU

VRHOFPKT_MENU:	$(SRC)/VRhofpkt.menu
	@\cp $(SRC)/VRhofpkt.menu VRHOFPKT_MENU

VRHRDPKT_MENU:	$(SRC)/VRhrdpkt.menu
	@\cp $(SRC)/VRhrdpkt.menu VRHRDPKT_MENU

VRHTDPKT_MENU:	$(SRC)/VRhtdpkt.menu
	@\cp $(SRC)/VRhtdpkt.menu VRHTDPKT_MENU

VRHTEPKT_MENU:	$(SRC)/VRhtepkt.menu
	@\cp $(SRC)/VRhtepkt.menu VRHTEPKT_MENU

VRHTRPKT_MENU:	$(SRC)/VRhtrpkt.menu
	@\cp $(SRC)/VRhtrpkt.menu VRHTRPKT_MENU

VRPCOPKT_MENU:	$(SRC)/VRpcopkt.menu
	@\cp $(SRC)/VRpcopkt.menu VRPCOPKT_MENU

VRPELPKT_MENU:	$(SRC)/VRpelpkt.menu
	@\cp $(SRC)/VRpelpkt.menu VRPELPKT_MENU

VRPFLPKT_MENU:	$(SRC)/VRpflpkt.menu
	@\cp $(SRC)/VRpflpkt.menu VRPFLPKT_MENU

VRPINPKT_MENU:	$(SRC)/VRpinpkt.menu
	@\cp $(SRC)/VRpinpkt.menu VRPINPKT_MENU

VRPPEPKT_MENU:	$(SRC)/VRppepkt.menu
	@\cp $(SRC)/VRppepkt.menu VRPPEPKT_MENU

VRPRDPKT_MENU:	$(SRC)/VRprdpkt.menu
	@\cp $(SRC)/VRprdpkt.menu VRPRDPKT_MENU

VRPSPPKT_MENU:	$(SRC)/VRpsppkt.menu
	@\cp $(SRC)/VRpsppkt.menu VRPSPPKT_MENU

VRPTEPKT_MENU:	$(SRC)/VRptepkt.menu
	@\cp $(SRC)/VRptepkt.menu VRPTEPKT_MENU

VRPUSPKT_MENU:	$(SRC)/VRpuspkt.menu
	@\cp $(SRC)/VRpuspkt.menu VRPUSPKT_MENU

VRPVLPKT_MENU:	$(SRC)/VRpvlpkt.menu
	@\cp $(SRC)/VRpvlpkt.menu VRPVLPKT_MENU

clean:
	@(cd src; make clean)
	@\rm -f *.menu *.otl VR* IM* PAN*
