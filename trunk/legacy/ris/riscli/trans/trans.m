SPECIAL
#if defined(unix)
SHELL=/bin/ksh
NONFUNCTIONS=$(RISDEVDIR)/riscli/internal/nonfuncs
#endif
#if defined(WIN32)
!include $(RISDEVDIR)\ristools\include\makeenv.nt

target: trans.lib

trans.lib: $(OBJECTS)
	@echo.
	@echo 	OBJECTS   -to-   $@
	@if exist $@ del $@
	@lib /out:$@ $**

#endif
END

SRC
$(RISDEVDIR)/riscli/trans

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
$(RISDEVDIR)/riscom/include
$(RISDEVDIR)/riscom/internal

$(RISDEVDIR)/riscli/trans/prt
$(RISDEVDIR)/riscom/network/prt
$(RISDEVDIR)/riscom/parse/prt
$(RISDEVDIR)/riscom/common/prt
$(RISDEVDIR)/riscli/clicom/prt
$(RISDEVDIR)/riscli/dict/prt

SOURCE
trnalias.c
trncheck.c
trncptyp.c
trncrsch.c
trndel.c
trndrive.c
trnexec.c
trnfrom.c
trngroup.c
trnhving.c
trnindex.c
trninsrt.c
trnkeywd.c
trnlock.c
trnorder.c
trnparms.c
trnparse.c
trnpaths.c
trnsch.c
trnselct.c
trnshare.c
trntable.c
trntrans.c
trntypsz.c
trnupdt.c
trnview.c
trnwhere.c
trnpriv.c

POST_SPECIAL
#if defined(unix)
include $(RISDEVDIR)/riscli/build/rules.c
#endif
#if defined(WIN32)
!include $(RISDEVDIR)\riscli\build\rulesc.nt
#endif
END
