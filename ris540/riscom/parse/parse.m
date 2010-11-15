SPECIAL
#if defined(unix)
SHELL=/bin/ksh
NONFUNCTIONS=$(RISDEVDIR)/riscom/internal/nonfuncs
#endif
#if defined(WIN32)
!include $(RISDEVDIR)\ristools\include\makeenv.nt
#endif
#if defined(DOS)
!include $(RISDEVDIR)\ristools\include\makeenv.dos
#endif

END

SRC
$(RISDEVDIR)/riscom/parse

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
#if defined(DOS)
$(HIGHCDIR)\inc
#endif
$(RISDEVDIR)/riscom/include
$(RISDEVDIR)/riscom/internal
$(RISDEVDIR)/riscom/parse/prt
$(RISDEVDIR)/riscom/common/prt

SOURCE
pardate.c
pardrive.c
parexpr.c
parlex.c
parmatch.c
parstack.c
partree.c
parutil.c

POST_SPECIAL
#if defined(unix)
include $(RISDEVDIR)/riscom/build/rules.c
#endif
#if defined(WIN32)
!include $(RISDEVDIR)\riscom\build\rulesc.nt
#endif
#if defined(DOS)
!include $(RISDEVDIR)\riscom\build\rulesc.dos
#endif
END
