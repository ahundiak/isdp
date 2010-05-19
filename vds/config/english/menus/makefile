# $Id: makefile,v 1.1.1.1 2001/01/04 21:07:25 cvs Exp $
#***********************************************************************
# I/VDS
#
# File:		config/english/menus/makefile
#
# Description:
#
# Dependencies:
#
# Revision History
#	$Log: makefile,v $
#	Revision 1.1.1.1  2001/01/04 21:07:25  cvs
#	Initial import to CVS
#	
# Revision 1.1  1997/05/08  15:52:48  pinnacle
# rep bin w/txt
#
# Revision 1.4  1996/03/23  17:53:58  pinnacle
# Replaced: ./config/english/menus/makefile for:  by azuurhou for vds.240
#
# Revision 1.3  1996/01/29  22:09:20  pinnacle
# Replaced: ./config/english/menus/makefile for:  by azuurhou for vds.240
#
# Revision 1.2  1995/12/21  18:11:50  pinnacle
# Replaced: ./config/english/menus/makefile for:  by azuurhou for vds.240
#
#
# History:
#	MM/DD/YY	AUTHOR		DESCRIPTION
# 	06/05/93 			Version 02.02.00.00
#	12/12/95	adz		Changed for Solaris
#	01/29/96	adz		Check for VDS Lite script.
#
#***********************************************************************
#
CPP = ${CPP_COMP} -P -Dems
MENU= ${GENMENU}
VDSSRC = $(VDS)/config/english/menus/src
VDSLITE = $(VDS)/vdlite/bin/vdlite.sh

target : BAR_VDS IMVDS 

IMVDS : $(VDSSRC)/VDpan.otl
	rm -f VD* SM* EM*
	$(CPP) $(VDSSRC)/VDpan.otl | \
		awk '{ if ($$0 != "") print $$0 }' > src/VDpan.cpp
	@if [ -f ${MENU} ] ; \
	then ${MENU} $(VDSSRC)/VDpan.cpp IMVDS ; \
	else echo "ERROR: ${MENU} not found ..." ; exit 1 ; \
	fi
	-rm -f src/VDpan.cpp
	cp IMVDS PANEL_MENU
	./gen_pantbl
	./gen_getcmdpath
	@if [ -x ${VDSLITE} ] ; then ${VDSLITE} ; fi 

BAR_VDS : $(VDSSRC)/VDbar.otl
	$(CPP) $(VDSSRC)/VDbar.otl | \
		awk '{ if ($$0 != "") print $$0 }' >src/VDbar.cpp
	genbarmenu -n src/VDbar.cpp BAR_VDS
	cp BAR_VDS BAR_MENU
	-rm -f src/VDbar.cpp
