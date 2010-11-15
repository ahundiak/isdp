SPECIAL
#if defined(unix)
SHELL=/bin/ksh
NONFUNCTIONS=$(RISDEVDIR)/risutl/internal/nonfuncs
#endif
#if defined(WIN32)
!include $(RISDEVDIR)\ristools\include\makeenv.nt
#endif
#if defined(DOS)
!include $(RISDEVDIR)\ristools\include\makeenv.dos
#endif
END

SRC
$(RISDEVDIR)/risutl/plbck

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

$(RISDEVDIR)/risutl/include
$(RISDEVDIR)/risutl/internal
$(RISDEVDIR)/riscom/include
$(RISDEVDIR)/riscom/internal
$(RISDEVDIR)/risapp/include
$(RISDEVDIR)/risutl/plbck/prt
$(RISDEVDIR)/risutl/ucommon/prt
$(RISDEVDIR)/riscom/common/prt
$(RISDEVDIR)/risapp/intrface/prt
#if defined(WIN32S)
$(RISDEVDIR)/risutl/batch/prt
#endif

SOURCE
plbexec.c
plbfree.c
plbids.c
plbmain.c
plbmisc.c
plbprint.c
plbread.c

POST_SPECIAL
#if defined(unix)
include $(RISDEVDIR)/risutl/build/rules.c
#endif
#if defined(WIN32)
!include $(RISDEVDIR)\risutl\build\rulesc.32
#endif
#if defined(DOS)
!include $(RISDEVDIR)\risutl\build\rulesc.dos
#endif
END
