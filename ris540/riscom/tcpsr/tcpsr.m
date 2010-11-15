Do not alter this SPC information: $Revision: 1.4.21.1 $
SPECIAL
#if defined(unix)
SHELL=/bin/ksh
NONFUNCTIONS=$(RISDEVDIR)/riscom/internal/nonfuncs
#endif
#if defined(WIN32)
!include $(RISDEVDIR)\ristools\include\makeenv.nt
#endif
END

SRC
$(RISDEVDIR)/riscom/tcpsr

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
$(RISDEVDIR)/riscom/include
$(RISDEVDIR)/riscom/internal
$(RISDEVDIR)/riscom/tcpsr/prt
$(RISDEVDIR)/riscom/common/prt

SOURCE
tcpsr.c
#if defined(WIN32)
risinetd.c
risserv.c
#endif

POST_SPECIAL
#if defined(unix)
include $(RISDEVDIR)/riscom/build/rules.c
#endif
#if defined(WIN32)
!include $(RISDEVDIR)\riscom\build\rulesc.nt
#endif
END
