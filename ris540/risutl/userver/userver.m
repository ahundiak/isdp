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
$(RISDEVDIR)/risutl/userver

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
$(RISDEVDIR)/risutl/internal
$(RISDEVDIR)/risapp/include
$(RISDEVDIR)/riscom/include
$(RISDEVDIR)/riscom/internal
$(RISDEVDIR)/risutl/userver/prt
$(RISDEVDIR)/risutl/ucommon/prt
$(RISDEVDIR)/riscom/common/prt

SOURCE
usvclnsr.rc
usvdtype.rc
usvgetdb.c
usvglobs.c

POST_SPECIAL
#if defined(unix)
include $(RISDEVDIR)/risutl/build/rules.c
include $(RISDEVDIR)/risutl/build/rules.rc
#endif
#if defined(WIN32)
!include $(RISDEVDIR)\risutl\build\rulesc.32
!include $(RISDEVDIR)\risutl\build\rulesrc.32
#endif
#if defined(DOS)
!include $(RISDEVDIR)\risutl\build\rulesc.dos
!include $(RISDEVDIR)\risutl\build\rulesrc.dos
#endif
END
