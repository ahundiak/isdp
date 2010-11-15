SPECIAL
#if defined(unix)
SHELL=/bin/ksh
NONFUNCTIONS=$(RISDEVDIR)/risapp/internal/nonfuncs
#endif
#if defined(WIN32)
!include $(RISDEVDIR)\ristools\include\makeenv.nt
#endif
#if defined(DOS)
!include $(RISDEVDIR)\ristools\include\makeenv.dos
#endif
END_SPECIAL

SRC
$(RISDEVDIR)/risapp/dload

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

$(RISDEVDIR)/risapp/include
$(RISDEVDIR)/risapp/internal
$(RISDEVDIR)/risapp/dload/prt
$(RISDEVDIR)/risapp/intrface/prt
$(RISDEVDIR)/riscom/include
$(RISDEVDIR)/riscom/internal
$(RISDEVDIR)/riscom/common/prt

SOURCE
dldint.c
dldrap.c
#if defined(WIN32)
dldmain.c
dldcom.c
dlddebug.c
dlderror.c
dldgtdir.c
#endif

POST_SPECIAL
#if defined(unix)
include $(RISDEVDIR)/risapp/build/rules.c
#endif
#if defined(WIN32)
!include $(RISDEVDIR)\risapp\build\rulesc.nt
#endif
#if defined(DOS)
!include $(RISDEVDIR)\risapp\build\rulesc.dos
#endif
END_SPECIAL
