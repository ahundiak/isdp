#
# 22/07/93 - I/LOFT Version 02.04.00.00
#
# 20 Jul 2010 - Need to hardcode some paths
# Not sure if VSpan.otl needs to end up in menus like on Solaris 8

CPP = ${CPP_COMP} -P -Dems
MENU= ${GENMENU}

CPP = /usr/lib/cpp -P -Dems
MENU= /opt/ingr/bin/xgenmenu

STRUCTSRC = $(STRUCT)/config/english/menus/src
STRUCTSRC = src

target : IMVS

IMVS : $(STRUCTSRC)/VSpan.otl
	rm -f VS* VD* EM*
	$(CPP) $(STRUCTSRC)/VSpan.otl | \
		awk '{ if ($$0 != "") print $$0 }' > src/VSpan.cpp
	@if [ -f ${MENU} ] ; \
	then ${MENU} $(STRUCTSRC)/VSpan.cpp IMVS ; \
	else echo "ERROR: ${MENU} not found ..." ; exit 0 ; \
	fi
	-rm -f src/VSpan.cpp
	cp IMVS PANEL_MENU
	./gen_pantbl
	./gen_getcmdpath
