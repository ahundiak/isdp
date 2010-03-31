CPP = cpp -P -Dems

EMS: IMMODEL IMPW\
     POCKET_MENU\
     BAR_MODEL  


POCKET_MENU:$(MODEL)/ems/emsuiul/config/english/menus/src/IMMDpkt.otl
	$(CPP) $(MODEL)/ems/emsuiul/config/english/menus/src/IMMDpkt.otl | \
		awk '{ if ($$0 != "") print $$0 }' >src/IMMDpkt.cpp
	@if [ -f $(INGRHOME)/bin/xgenmenu ] ; \
	then xgenmenu -v $(MDTARG)/ems/emsuiul/config/english/menus/src/IMMDpkt.cpp POCKET_MENU ; \
	else /usr/ip32/forms_s/bin/genmenu $(MDTARG)/ems/emsuiul/config/english/menus/src/IMMDpkt.cpp POCKET_MENU ; \
	fi

IMMODEL:$(MODEL)/ems/emsuiul/config/english/menus/src/IMMDpan.otl
	rm -f M?MD*  
	$(CPP) $(MODEL)/ems/emsuiul/config/english/menus/src/IMMDpan.otl | \
		awk '{ if ($$0 != "") print $$0 }' >src/IMMDpan.cpp
	@if [ -f $(INGRHOME)/bin/xgenmenu ] ; \
	then xgenmenu -h 692 $(MDTARG)/ems/emsuiul/config/english/menus/src/IMMDpan.cpp IMMODEL ; \
	else /usr/ip32/forms_s/bin/genmenu $(MDTARG)/ems/emsuiul/config/english/menus/src/IMMDpan.cpp IMMODEL ; \
	fi
	cp IMMODEL PANEL_MENU

IMPW:$(MODEL)/ems/emsuiul/config/english/menus/src/IMPWpan.otl
	rm -f M?PW* 
	$(CPP) $(MODEL)/ems/emsuiul/config/english/menus/src/IMPWpan.otl | \
		awk '{ if ($$0 != "") print $$0 }' >src/IMPWpan.cpp
	@if [ -f $(INGRHOME)/bin/xgenmenu ] ; \
	then xgenmenu $(MDTARG)/ems/emsuiul/config/english/menus/src/IMPWpan.cpp IMPW ; \
	else /usr/ip32/forms_s/bin/genmenu $(MDTARG)/ems/emsuiul/config/english/menus/src/IMPWpan.cpp IMPW ; \
	fi

BAR_MODEL:$(MODEL)/ems/emsuiul/config/english/menus/src/IMMDbar.otl 
	$(CPP) $(MODEL)/ems/emsuiul/config/english/menus/src/IMMDbar.otl | \
		awk '{ if ($$0 != "") print $$0 }' >src/IMMDbar.cpp
	genbarmenu -n src/IMMDbar.cpp BAR_MENU
	cp BAR_MENU BAR_MODEL
	-rm -f src/IMMDbar.cpp
