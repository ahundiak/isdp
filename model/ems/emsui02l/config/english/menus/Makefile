CPP = cpp -P -Dems -Di386

EMS: IMMODEL IMDETAIL IMASSY IMPW\
     POCKET_MENU POCKET_DETAIL \
     BAR_MODEL BAR_DETAIL 


POCKET_MENU:$(MODEL)/ems/emsui02l/config/english/menus/src/IMMDpkt.otl
	$(CPP) $(MODEL)/ems/emsui02l/config/english/menus/src/IMMDpkt.otl | \
		awk '{ if ($$0 != "") print $$0 }' >src/IMMDpkt.cpp
	@if [ -f $(INGRHOME)/bin/xgenmenu ] ; \
	then xgenmenu $(MDTARG)/ems/emsui02l/config/english/menus/src/IMMDpkt.cpp POCKET_MENU ; \
	else /usr/ip32/forms_s/bin/genmenu $(MDTARG)/ems/emsui02l/config/english/menus/src/IMMDpkt.cpp POCKET_MENU ; \
	fi

POCKET_DETAIL:$(MODEL)/ems/emsui02l/config/english/menus/src/IMDEpkt.otl
	$(CPP) $(MODEL)/ems/emsui02l/config/english/menus/src/IMDEpkt.otl | \
		awk '{ if ($$0 != "") print $$0 }' >src/IMDEpkt.cpp
	@if [ -f $(INGRHOME)/bin/xgenmenu ] ; \
	then xgenmenu $(MDTARG)/ems/emsui02l/config/english/menus/src/IMDEpkt.cpp POCKET_DETAIL ; \
	else /usr/ip32/forms_s/bin/genmenu $(MDTARG)/ems/emsui02l/config/english/menus/src/IMDEpkt.cpp POCKET_DETAIL ; \
	fi

IMMODEL:$(MODEL)/ems/emsui02l/config/english/menus/src/IMMDpan.otl
	rm -f M?MD*  
	$(CPP) $(MODEL)/ems/emsui02l/config/english/menus/src/IMMDpan.otl | \
		awk '{ if ($$0 != "") print $$0 }' >src/IMMDpan.cpp
	@if [ -f $(INGRHOME)/bin/xgenmenu ] ; \
	then xgenmenu -h 692 $(MDTARG)/ems/emsui02l/config/english/menus/src/IMMDpan.cpp IMMODEL ; \
	else /usr/ip32/forms_s/bin/genmenu $(MDTARG)/ems/emsui02l/config/english/menus/src/IMMDpan.cpp IMMODEL ; \
	fi
	cp IMMODEL PANEL_MENU

IMASSY:$(MODEL)/ems/emsui02l/config/english/menus/src/IMAYpan.otl
	rm -f M?AY*  
	$(CPP) $(MODEL)/ems/emsui02l/config/english/menus/src/IMAYpan.otl | \
		awk '{ if ($$0 != "") print $$0 }' >src/IMAYpan.cpp
	@if [ -f $(INGRHOME)/bin/xgenmenu ] ; \
	then xgenmenu -h 692 $(MDTARG)/ems/emsui02l/config/english/menus/src/IMAYpan.cpp IMASSY ; \
	else /usr/ip32/forms_s/bin/genmenu $(MDTARG)/ems/emsui02l/config/english/menus/src/IMAYpan.cpp IMASSY ;\
	fi

IMDETAIL:$(MODEL)/ems/emsui02l/config/english/menus/src/IMDEpan.otl
	rm -f M?DE* 
	$(CPP) $(MODEL)/ems/emsui02l/config/english/menus/src/IMDEpan.otl | \
		awk '{ if ($$0 != "") print $$0 }' >src/IMDEpan.cpp
	@if [ -f $(INGRHOME)/bin/xgenmenu ] ; \
	then xgenmenu -h 692 $(MDTARG)/ems/emsui02l/config/english/menus/src/IMDEpan.cpp IMDETAIL ; \
	else /usr/ip32/forms_s/bin/genmenu $(MDTARG)/ems/emsui02l/config/english/menus/src/IMDEpan.cpp IMDETAIL ; \
	fi

IMPW:$(MODEL)/ems/emsui02l/config/english/menus/src/IMPWpan.otl
	rm -f M?PW* 
	$(CPP) $(MODEL)/ems/emsui02l/config/english/menus/src/IMPWpan.otl | \
		awk '{ if ($$0 != "") print $$0 }' >src/IMPWpan.cpp
	@if [ -f $(INGRHOME)/bin/xgenmenu ] ; \
	then xgenmenu $(MDTARG)/ems/emsui02l/config/english/menus/src/IMPWpan.cpp IMPW ; \
	else /usr/ip32/forms_s/bin/genmenu $(MDTARG)/ems/emsui02l/config/english/menus/src/IMPWpan.cpp IMPW ; \
	fi

BAR_MODEL:$(MODEL)/ems/emsui02l/config/english/menus/src/IMMDbar.otl 
	$(CPP) $(MODEL)/ems/emsui02l/config/english/menus/src/IMMDbar.otl | \
		awk '{ if ($$0 != "") print $$0 }' >src/IMMDbar.cpp
	genbarmenu -n src/IMMDbar.cpp BAR_MENU
	cp BAR_MENU BAR_MODEL
	-rm -f src/IMMDbar.cpp

BAR_DETAIL:$(MODEL)/ems/emsui02l/config/english/menus/src/IMDEbar.otl 
	$(CPP) $(MODEL)/ems/emsui02l/config/english/menus/src/IMDEbar.otl | \
		awk '{ if ($$0 != "") print $$0 }' >src/IMDEbar.cpp
	genbarmenu -n src/IMDEbar.cpp BAR_DETAIL
	-rm -f src/IMDEbar.cpp
