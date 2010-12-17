Do not alter this SPC information: $Revision: 1.1.38.1 $
SPECIAL
#if defined(__clipper__) || defined(sun) || defined(sco)
NONFUNCTIONS=$(RISDEVDIR)/risums/unix/srcc/nonfuncs
SHELL=/bin/ksh
#endif
#if defined(WIN32)
NONFUNCTIONS=$(RISDEVDIR)\risums\nt\srcc\nonfuncs
!include $(RISDEVDIR)\ristools\include\makeenv.nt
#endif
#if defined(WIN16)
NONFUNCTIONS=$(RISDEVDIR)\risums\nt\srcc\nonfuncs
!include $(RISDEVDIR)\ristools\include\makeenv.16
#endif
END

#if defined(__clipper__) || defined(sun) || defined(sco)
SRC
$(RISDEVDIR)/risums/nt/srcc
#else
SRC
$(RISDEVDIR)\risums\nt\srcc
#endif

INCLUDE
#if defined(__clipper__) || defined (sco)
/usr/include
$(RISDEVDIR)/risums/unix/srcc/prt
$(RISDEVDIR)/risums/unix/include
#endif
#if defined(sun)
/usr/5include
/usr/include
#endif
#if defined(WIN32)
$(MSTOOLSDIR)\include
$(RISDEVDIR)\risums\nt\srcc\prt
$(RISDEVDIR)\risums\nt\include
#endif
#if defined(WIN16)
$(C700DIR)\include
#endif

$(RISDEVDIR)/riscom/internal
$(RISDEVDIR)/riscom/network/internal

SOURCE
umscomp.c

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

