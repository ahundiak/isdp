include $(GRNUC)/grnucmakelib
include $(EXTARG)/exnucmakelib
include $(BS)/lib/bsmakelib
include $(GRNUC)/versfile

EXECUTABLE=$(GRTARG)/bin/Grnuc

APP=.
APP_PRE_ACTION = @make exlink_stubs
APP_POST_ACTION = @make exfp_stubs
DEBUGLIBRARIES =

GRSTUBS = $(GRTARG)/lib/$(CPUTYPE)/stub.a $(GRTARG)/lib/$(CPUTYPE)/libGRstub.a $(GRTARG)/lib/$(CPUTYPE)/tempGRstub.a

LIBRARIES = \
$(DEBUGLIBRARIES) \
$(GRNUCLIBRARIES) \
$(EXNUCLIBRARIES) \
$(BSLIBRARIES)

final_target:
	$(APP_PRE_ACTION)
	@make $(EXECUTABLE)
	$(APP_POST_ACTION)

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
