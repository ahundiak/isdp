Do not alter this SPC information: $Revision: 1.6.22.1 $
SPECIAL
NONFUNCTIONS=$(RISDEVDIR)/riscom/internal/nonfuncs
#if defined(unix)
SHELL=/bin/ksh
#endif
#if defined(WIN32)
!include $(RISDEVDIR)\ristools\include\makeenv.nt
#endif
#if defined(DOS)
!include $(RISDEVDIR)\ristools\include\makeenv.dos
#endif
END

SRC
$(RISDEVDIR)/riscom/arch

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
$(RISDEVDIR)/riscom/include
$(RISDEVDIR)/riscom/internal
$(RISDEVDIR)/riscom/arch/prt
#if defined(sco)
$(RISDEVDIR)/riscom/common/prt
#endif /* sco */

SOURCE
arcgnerc.c
arcglobs.c
#if defined(unix) || defined(WIN32) || defined(DOS)
arcerrcd.c
#endif
#if defined(WIN32) || defined(unix) && !defined(sco)
arcebcdc.c
arcswap.c
#endif
#if defined(sco)
arcebcdc.c
arcswap.c
arcfc.c
arcdc.c
#endif

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
