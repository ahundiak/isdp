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
$(RISDEVDIR)/risutl/dloadfrm

INCLUDE
#if defined(unix)
/usr/include
/usr/include/X11
/usr/openwin/include
/usr/ip32/xformsdp/xfi/include
#endif
#if defined(sun)
/usr/5include
#endif
#if defined(__Sol2__) || defined(Soli)
$(INGRHOME)/xformsdp/xfi/include
#endif
#if defined(WIN32)
$(MSTOOLSDIR)\include
$(SHAMROCKDIR)\include
#endif
#if defined(DOS)
$(HIGHCDIR)\inc
#endif

$(RISDEVDIR)/risutl/include
$(RISDEVDIR)/risutl/internal
$(RISDEVDIR)/risapp/include
$(RISDEVDIR)/riscom/include
$(RISDEVDIR)/riscom/internal

$(RISDEVDIR)/risutl/forms/prt
$(RISDEVDIR)/risutl/ucommon/prt
$(RISDEVDIR)/riscom/common/prt
$(RISDEVDIR)/risutl/dloadfrm/prt


SOURCE
dldmain.c
#if defined(WIN32)
dlddebug.c
dlderror.c
dldgtdir.c
#endif

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
END_SPECIAL
