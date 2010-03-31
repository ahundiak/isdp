CPP = cpp -P -Dems

EMS: IMMODEL IMDETAIL IMASSY \
     BAR_MODEL BAR_DETAIL 


IMMODEL:$(MODEL)/ems/emsuilt/config/english/menus/src/IMMDpan.otl
	rm -f M?MD*  
	$(CPP) $(MODEL)/ems/emsuilt/config/english/menus/src/IMMDpan.otl | \
		awk '{ if ($$0 != "") print $$0 }' >src/IMMDpan.cpp
	@if [ -f $(INGRHOME)/bin/xgenmenu ] ; \
	then xgenmenu $(MDTARG)/ems/emsuilt/config/english/menus/src/IMMDpan.cpp IMMODEL ; \
	else /usr/ip32/forms_s/bin/genmenu $(MDTARG)/ems/emsuilt/config/english/menus/src/IMMDpan.cpp IMMODEL ; \
	fi
	cp IMMODEL PANEL_MENU

IMASSY:$(MODEL)/ems/emsuilt/config/english/menus/src/IMAYpan.otl
	rm -f M?AY*
	$(CPP) $(MODEL)/ems/emsuilt/config/english/menus/src/IMAYpan.otl | \
		awk '{ if ($$0 != "") print $$0 }' >src/IMAYpan.cpp
	@if [ -f $(INGRHOME)/bin/xgenmenu ] ; \
	then xgenmenu $(MDTARG)/ems/emsuilt/config/english/menus/src/IMAYpan.cpp IMASSY ; \
	else /usr/ip32/forms_s/bin/genmenu $(MDTARG)/ems/emsuilt/config/english/menus/src/IMAYpan.cpp IMASSY ;\
	fi

IMDETAIL:$(MODEL)/ems/emsuilt/config/english/menus/src/IMDEpan.otl
	rm -f M?DE* 
	$(CPP) $(MODEL)/ems/emsuilt/config/english/menus/src/IMDEpan.otl | \
		awk '{ if ($$0 != "") print $$0 }' >src/IMDEpan.cpp
	@if [ -f $(INGRHOME)/bin/xgenmenu ] ; \
	then xgenmenu $(MDTARG)/ems/emsuilt/config/english/menus/src/IMDEpan.cpp IMDETAIL ; \
	else /usr/ip32/forms_s/bin/genmenu $(MDTARG)/ems/emsuilt/config/english/menus/src/IMDEpan.cpp IMDETAIL ; \
	fi

BAR_MODEL:$(MODEL)/ems/emsuilt/config/english/menus/src/IMMDbar.otl 
	$(CPP) $(MODEL)/ems/emsuilt/config/english/menus/src/IMMDbar.otl | \
		awk '{ if ($$0 != "") print $$0 }' >src/IMMDbar.cpp
	genbarmenu -n src/IMMDbar.cpp BAR_MENU
	cp BAR_MENU BAR_MODEL
	-rm -f src/IMMDbar.cpp

BAR_DETAIL:$(MODEL)/ems/emsuilt/config/english/menus/src/IMDEbar.otl 
	$(CPP) $(MODEL)/ems/emsuilt/config/english/menus/src/IMDEbar.otl | \
		awk '{ if ($$0 != "") print $$0 }' >src/IMDEbar.cpp
	genbarmenu -n src/IMDEbar.cpp BAR_DETAIL
	-rm -f src/IMDEbar.cpp
