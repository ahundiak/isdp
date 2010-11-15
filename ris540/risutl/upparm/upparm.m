SPECIAL
#if defined(unix)
SHELL=/bin/ksh
NONFUNCTIONS=$(RISDEVDIR)/risutl/internal/nonfuncs
#endif
#if defined(WIN32) && !defined(WIN32S)
!include $(RISDEVDIR)\ristools\include\makeenv.nt
#endif
#if defined(WIN32S)
!include $(RISDEVDIR)\ristools\include\makeenv.32s
#endif
#if defined(DOS)
!include $(RISDEVDIR)\ristools\include\makeenv.dos
#endif
END

SRC
$(RISDEVDIR)/risutl/upparm

INCLUDE
#if defined(unix)
/usr/include
#endif
#if defined(sun)
/usr/5include
#endif
#if defined(WIN32) && !defined(WIN32S)
$(MSTOOLSDIR)\include
#endif
#if defined(WIN32S)
$(MSTOOLSDIR)\include
#endif
#if defined(DOS)
$(HIGHCDIR)\inc
#endif
$(RISDEVDIR)/risutl/include
$(RISDEVDIR)/risutl/internal
$(RISDEVDIR)/risapp/include
$(RISDEVDIR)/riscom/include
$(RISDEVDIR)/riscom/internal
$(RISDEVDIR)/riscom/common/prt
$(RISDEVDIR)/risutl/upparm/prt
$(RISDEVDIR)/risutl/ucommon/prt

SOURCE
uppmain.c

POST_SPECIAL
#if defined(unix)
include $(RISDEVDIR)/risutl/build/rules.c
#endif
#if defined(WIN32) && !defined(WIN32S)
!include $(RISDEVDIR)\risutl\build\rulesc.nt
#endif
#if defined(WIN32S)
!include $(RISDEVDIR)\risutl\build\rulesc.32s
#endif
#if defined(DOS)
!include $(RISDEVDIR)\risutl\build\rulesc.dos
#endif
END
