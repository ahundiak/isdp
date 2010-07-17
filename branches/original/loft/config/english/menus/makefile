#
# 22/07/93 - I/LOFT Version 02.04.00.00
#
CPP = ${CPP_COMP} -P -Dems
MENU= ${GENMENU}
LOFTSRC = $(LOFT)/config/english/menus/src

# target : IMLOFT
target : IMLOFT

IMLOFT : $(LOFTSRC)/VLpan.otl
	rm -f VL* 
	$(CPP) $(LOFTSRC)/VLpan.otl | \
		awk '{ if ($$0 != "") print $$0 }' > src/VLpan.cpp
	@if [ -f ${MENU} ] ; \
	then ${MENU} $(LOFTSRC)/VLpan.cpp IMLOFT ; \
	else echo "ERROR: ${MENU} not found ..." ; exit 0 ; \
	fi
	-rm -f src/VLpan.cpp
	cp IMLOFT PANEL_MENU
	./gen_pantbl
	./gen_getcmdpath
