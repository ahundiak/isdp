Do not alter this SPC information: $Revision: 1.4.21.1 $
SPECIAL
NONFUNCTIONS=$(RISDEVDIR)/risums/unix/srcc/nonfuncs
#if defined(unix)
SHELL=/bin/ksh
#endif
#if defined(WIN32)
!include $(RISDEVDIR)\ristools\include\makeenv.nt
#endif
#if defined(WIN16)
!include $(RISDEVDIR)\ristools\include\makeenv.16
#endif
END

#if defined(unix)
SRC
$(RISDEVDIR)/risums/unix/srcc
#else
SRC
$(UMSDIR)\srcc
#endif

INCLUDE

$(RISDEVDIR)/risums/unix/include
$(RISDEVDIR)/risums/unix/srcc/prt

#if defined(unix)
/usr/include
#endif
#if defined(sun)
/usr/5include
#endif
#if defined(WIN32)
$(MSTOOLSDIR)\include
#endif
#if defined(WIN16)
$(C700DIR)\include
#endif

$(RISDEVDIR)/riscom/internal
$(RISDEVDIR)/riscom/network/internal

SOURCE
umscomp.c

POST_SPECIAL
#if defined(unix)
include $(RISDEVDIR)/risums/unix/build/rules.c
#endif
#if defined(WIN32)
!include $(UMSDIR)\build\rulesc.nt
#endif
#if defined(WIN16)
!include $(UMSDIR)\build\rulesc.16
#endif
END

