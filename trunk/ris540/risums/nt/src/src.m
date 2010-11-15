Do not alter this SPC information: $Revision: 1.1.38.1 $
SPECIAL
#if defined(__clipper__) || defined(sun) || defined(sco)
NONFUNCTIONS=$(RISDEVDIR)/risums/unix/src/nonfuncs
SHELL=/bin/ksh
#endif
#if defined(WIN32)
!include $(RISDEVDIR)\ristools\include\makeenv.nt
NONFUNCTIONS=$(RISDEVDIR)\risums\nt\src\nonfuncs
#endif
#if defined(WIN16)
!include $(RISDEVDIR)\ristools\include\makeenv.16
#endif
END

SRC
#if defined(WIN32)
$(RISDEVDIR)\risums\nt\src
#endif
#if defined(__clipper__) || defined(sun) || defined(sco)
$(RISDEVDIR)/risums/unix/src
#endif

INCLUDE
#if defined(__clipper__) || defined (sco)
/usr/include
$(RISDEVDIR)/risums/unix/include
$(RISDEVDIR)/risums/unix/src/prt
#endif
#if defined(sun)
/usr/5include
/usr/include
#endif
#if defined(WIN32)
$(MSTOOLSDIR)\include
$(RISDEVDIR)\risums\nt\include
$(RISDEVDIR)\risums\nt\src/prt
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
#if defined(__clipper__) || defined(sun) || defined(sco)
include $(RISDEVDIR)/risums/unix/build/rulesc
#endif
#if defined(WIN32)
!include $(RISDEVDIR)\risums\nt\build\rulesc.nt
#endif
#if defined(WIN16)
!include $(RISDEVDIR)\risums\nt\build\rulesc.16
#endif
END

