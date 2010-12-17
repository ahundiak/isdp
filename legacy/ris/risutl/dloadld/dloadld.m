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
END_SPECIAL

SRC
$(RISDEVDIR)/risutl/dloadld

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
$(RISDEVDIR)/risutl/lod/prt
$(RISDEVDIR)/risutl/unlod/prt
$(RISDEVDIR)/risutl/ucommon/prt
$(RISDEVDIR)/riscom/common/prt
$(RISDEVDIR)/riscom/interface/prt
$(RISDEVDIR)/risutl/dloadld/prt

SOURCE
dldmain.rc
#if defined(WIN32)
dlddebug.c
dlderror.c
dldgtdir.c
#endif

POST_SPECIAL
#if defined(unix)
include $(RISDEVDIR)/risutl/build/rules.rc
#endif
#if defined(WIN32)
!include $(RISDEVDIR)\risutl\build\rulesrc.nt
!include $(RISDEVDIR)\risutl\build\rulesc.nt
#endif
#if defined(DOS)
!include $(RISDEVDIR)\risutl\build\rulesrc.dos
#endif
END_SPECIAL
