#NOW EMSver.o is dyn loaded ... include $(EMS)/emsmakelib
include $(MODEL)/src_lib/ris/rismakelib
#include $(MODEL)/modelmakelib_DYN
include $(MODEL)/modelmakelib
include $(MODEL)/hsurfmakelib
include $(MODEL)/vemakelib
include $(GRNUC)/grnucmakelib
#include $(PDU)/pdumakelib
include $(EXNUC)/exnucmakelib
include $(BS)/lib/bsmakelib

PRODUCT = I/MODEL 03.04.00.11

EXECUTABLE = $(MDTARG)/bin/Model
APP=.
APP_PRE_ACTION = @make dummy_target exlink_stubs
APP_POST_ACTION = @make clean_dummy exfp_stubs

DEBUGLIBRARIES =

GRSTUBS = $(GRTARG)/lib/$(CPUTYPE)/stub.a \
          $(GRTARG)/lib/$(CPUTYPE)/libGRstub.a \
          $(GRTARG)/lib/$(CPUTYPE)/tempGRstub.a

MODELLIBRARIES = \
        $(MODELEMSLIBS) \
        $(MDTARG)/src_lib/$(CPUTYPE)/PWlib.o

LIBRARIES = \
$(DEBUGLIBRARIES) \
$(EMSLIBRARIES) \
$(RISLIBS) \
$(MODELLIBRARIES) \
$(HSURFLIBRARIES) \
$(VELIBRARIES) \
$(GRNUCLIBRARIES) \
$(PDULIBRARIES) \
$(BSLIBRARIES) \
$(EXNUCLIBRARIES)

final_target:
	$(APP_PRE_ACTION)
	@make $(EXECUTABLE)
	$(APP_POST_ACTION)

dummy_target:
	if [ $(CPUTYPE) = "c100" ]; \
	then \
		echo "#ifndef _PWapi_include\n#define _PWapi_include" > \
			$(MODEL)/include/PWapi.h; \
		cat $(MODEL)/include/PWapi/*.h > /tmp/_pwapi.h; \
		awk '$$1 !~ /#/ && $$1 !~ /{/ && $$1 !~ /}/ && $$2 !~ /"C"/' \
			/tmp/_pwapi.h >> $(MODEL)/include/PWapi.h; \
		rm /tmp/_pwapi.h; \
		echo "#endif" >> $(MODEL)/include/PWapi.h; \
	fi

	ld -r -o $(MDTARG)/src_lib/$(CPUTYPE)/PWlib.o $(MODELPWLIBS)

clean_dummy:
	@rm $(MDTARG)/src_lib/$(CPUTYPE)/PWlib.o

exlink_stubs:
	if [ $(CPUTYPE) = "isl" -o $(CPUTYPE) = "sun5" -o $(CPUTYPE) = "sunzx" ]; \
	then \
		echo "Making Exnuc link time stubs"; \
		cd $(EXTARG)/lib; \
		make -f linkstub.mk; \
	fi

exfp_stubs:
	if [ $(CPUTYPE) = "isl" -o $(CPUTYPE) = "sun5" -o $(CPUTYPE) = "sunzx" ]; \
	then \
		echo "Making Exnuc run time stubs"; \
		cd $(EXTARG)/lib; \
		make -f fpstub.mk; \
	fi

include $(GRNUC)/mkexecutable
