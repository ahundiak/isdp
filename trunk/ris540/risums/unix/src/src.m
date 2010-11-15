Do not alter this SPC information: $Revision: 1.4.21.1 $
SPECIAL
NONFUNCTIONS=$(RISDEVDIR)/risums/unix/src/nonfuncs
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

SRC
$(RISDEVDIR)/risums/unix/src

INCLUDE

$(RISDEVDIR)/risums/unix/include
$(RISDEVDIR)/risums/unix/src/prt

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
$(WINDEV)\include
#endif


SOURCE
compcall.c
compmsg.c
compread.c
compwrit.c
umsfile.c
umsgbkey.c
umsgbnum.c
umsgetop.c
umsinitm.c
umskeyby.c
umsmsgco.c
umsmsgfm.c
umsnumby.c
umsrbkey.c
umsrbnum.c

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

