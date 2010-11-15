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
$(RISDEVDIR)/risutl/clnup

INCLUDE
#if defined(unix)
/usr/include
#endif
#if defined(sun)
/usr/5include
#endif
#if defined(WIN32)
$(MSTOOLSDIR)\h
#endif
#if defined(DOS)
\highc\inc
#endif
$(RISDEVDIR)/risutl/internal
$(RISDEVDIR)/riscom/internal
$(RISDEVDIR)/risutl/clnup/prt
$(RISDEVDIR)/risutl/ucommon/prt
$(RISDEVDIR)/riscom/common/prt

SOURCE
clumain.c

POST_SPECIAL
#if defined(unix)
include $(RISDEVDIR)/risutl/build/rules.c
#endif
#if defined(WIN32)
!include $(RISDEVDIR)\risutl\build\rulesc.nt
#endif
#if defined(DOS)
!include $(RISDEVDIR)\risutl\build\rulesc.dos
#endif
END
