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
$(RISDEVDIR)/risutl/dtype

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
$(RISDEVDIR)/risapp/include
$(RISDEVDIR)/riscom/include
$(RISDEVDIR)/riscom/internal
$(RISDEVDIR)/riscom/common/prt
$(RISDEVDIR)/risutl/dtype/prt
$(RISDEVDIR)/risutl/userver/prt
$(RISDEVDIR)/risutl/ucommon/prt
#if defined(WIN32S)
$(RISDEVDIR)/risutl/batch/prt
#endif

SOURCE
dtymain.rc
#if defined(WIN32S)
dtyanyky.c
#endif

POST_SPECIAL
#if defined(unix)
include $(RISDEVDIR)/risutl/build/rules.rc
#endif
#if defined(WIN32)
!include $(RISDEVDIR)\risutl\build\rulesrc.32
#if defined(WIN32S)
!include $(RISDEVDIR)\risutl\build\rulesc.32
#endif
#endif
#if defined(DOS)
!include $(RISDEVDIR)\risutl\build\rulesrc.dos
#endif
END
