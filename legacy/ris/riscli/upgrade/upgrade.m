SPECIAL
#if defined(unix)
SHELL=/bin/ksh
NONFUNCTIONS=$(RISDEVDIR)/riscli/internal/nonfuncs
#endif
#if defined(WIN32)
!include $(RISDEVDIR)\ristools\include\makeenv.nt
#endif
#if defined(DOS)
!include $(RISDEVDIR)\ristools\include\makeenv.dos
#endif
END_SPECIAL

SRC
$(RISDEVDIR)/riscli/upgrade

INCLUDE
#if defined(unix)
/usr/include
#endif
#if defined(sun)
/usr/5include
#endif
#if defined(WIN32)
$(MSTOOLSDIR)\include
#endif
#if defined(DOS)
$(HIGHCDIR)\inc
#endif

$(RISDEVDIR)/riscli/internal
$(RISDEVDIR)/riscom/include
$(RISDEVDIR)/riscom/internal
$(RISDEVDIR)/risapp/include

$(RISDEVDIR)/riscli/file/prt
$(RISDEVDIR)/riscli/upgrade/prt
$(RISDEVDIR)/riscom/common/prt
$(RISDEVDIR)/riscom/network/prt

SOURCE
#if defined(unix) || defined(WIN32)
cnvschfl.rc
upgmain.rc
upgbldsc.rc
upgmisc.rc
upgschem.rc
upgdictx.rc
upgtable.rc
upgview.rc
upgcolmn.rc
upgprvdf.rc
upgprvqy.rc
upgterm.c
upgpaswd.c
#endif

POST_SPECIAL
#if defined(unix)
include $(RISDEVDIR)/riscli/build/rules.c
include $(RISDEVDIR)/riscli/build/rules.rc
#endif
#if defined(WIN32)
!include $(RISDEVDIR)\riscli\build\rulesc.nt
!include $(RISDEVDIR)\riscli\build\rulesrc.nt
#endif
END
