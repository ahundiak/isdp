SPECIAL
#if defined(unix)
SHELL=/bin/ksh
NONFUNCTIONS=$(RISDEVDIR)/riscli/internal/nonfuncs
#endif
#if defined(WIN32)
!include $(RISDEVDIR)\ristools\include\makeenv.nt

target: file.lib

file.lib: $(OBJECTS)
	@echo.
	@echo 	OBJECTS   -to-   $@
	@if exist $@ del $@
	@lib /out:$@ $**

#endif
END

SRC
$(RISDEVDIR)/riscli/file

INCLUDE
#if defined(unix) 
/usr/include
#endif
#if defined(WIN32)
$(MSTOOLSDIR)\include
#endif

$(RISDEVDIR)/riscli/internal
$(RISDEVDIR)/riscom/include
$(RISDEVDIR)/riscom/internal

$(RISDEVDIR)/riscli/file/prt
$(RISDEVDIR)/riscli/clicom/prt
$(RISDEVDIR)/riscom/common/prt
$(RISDEVDIR)/riscom/network/prt
$(RISDEVDIR)/riscom/arch/prt

SOURCE
filcksum.c
fildb.c
filglob.c
fillist.c
filread.c
filsch.c
filshare.c
filtrans.c
filwrite.c

POST_SPECIAL
#if defined(unix) 
include $(RISDEVDIR)/riscli/build/rules.c
#endif
#if defined(WIN32)
!include $(RISDEVDIR)\riscli\build\rulesc.nt
#endif
