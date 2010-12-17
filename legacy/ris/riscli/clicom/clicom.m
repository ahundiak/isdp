SPECIAL
#if defined(unix)
SHELL=/bin/ksh
NONFUNCTIONS=$(RISDEVDIR)/riscli/internal/nonfuncs
#endif
#if defined(WIN32)
!include $(RISDEVDIR)\ristools\include\makeenv.nt

target: clicom.lib

clicom.lib: $(OBJECTS)
	@echo.
	@echo 	OBJECTS   -to-   $@
	@if exist $@ del $@
	@lib /out:$@ $**

#endif
END

SRC
$(RISDEVDIR)/riscli/clicom

INCLUDE
#if defined(sun) 
/usr/5include
#endif
#if defined(unix) 
/usr/include
#endif
#if defined(WIN32)
$(MSTOOLSDIR)\include
#endif
$(RISDEVDIR)/riscli/internal
$(RISDEVDIR)/riscom/internal
$(RISDEVDIR)/riscom/include
$(RISDEVDIR)/riscli/clicom/prt
$(RISDEVDIR)/riscom/common/prt

SOURCE
ccoclstm.c
ccocmpar.c
ccodb2.c
ccoos400.c
ccoeot.c
ccoerror.c
ccoinvid.c
ccooutpt.c
ccoren.c
ccoschid.c
ccosqlca.c
ccoss_id.c
ccostmgr.c
ccover.c

POST_SPECIAL
#if defined(unix)
include $(RISDEVDIR)/riscli/build/rules.c
#endif
#if defined(WIN32)
!include $(RISDEVDIR)\riscli\build\rulesc.nt
#endif
END
