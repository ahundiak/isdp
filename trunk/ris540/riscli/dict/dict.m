SPECIAL
#if defined(unix) 
SHELL=/bin/ksh
NONFUNCTIONS=$(RISDEVDIR)/riscli/internal/nonfuncs
#endif
#if defined(WIN32)
!include $(RISDEVDIR)\ristools\include\makeenv.nt

target: dict.lib

dict.lib: $(OBJECTS)
	@echo.
	@echo 	OBJECTS   -to-   $@
	@if exist $@ del $@
	@lib /out:$@ $**

#endif
END

SRC
$(RISDEVDIR)/riscli/dict

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

$(RISDEVDIR)/riscli/dict/prt
$(RISDEVDIR)/riscli/client/prt
$(RISDEVDIR)/riscom/common/prt
$(RISDEVDIR)/riscom/parse/prt
$(RISDEVDIR)/riscli/clicom/prt
$(RISDEVDIR)/riscli/file/prt
$(RISDEVDIR)/riscli/user/prt

SOURCE
dicacc.c
dicadd.c
dicalsch.c
dicclsch.c
diccrsch.c
dicdcsch.c
dicdecss.c
dicdrsch.c
dicgrant.c
dicgrnte.c
dicindex.c
dicload.c
diclook.c
dicmisc.c
dicopsch.c
dicrem.c
dicrdcss.c
dicrevk.c
dictable.c
dictrans.c
dicundss.c
dicview.c

POST_SPECIAL
#if defined(unix) 
include $(RISDEVDIR)/riscli/build/rules.c
#endif
#if defined(WIN32)
!include $(RISDEVDIR)\riscli\build\rulesc.nt
#endif
END
