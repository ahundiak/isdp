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
$(RISDEVDIR)/risutl/batch

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
$(RISDEVDIR)/riscom/include
$(RISDEVDIR)/riscom/internal
$(RISDEVDIR)/risapp/include
$(RISDEVDIR)/risutl/util/prt
$(RISDEVDIR)/risutl/batch/prt
$(RISDEVDIR)/risutl/ucommon/prt
$(RISDEVDIR)/riscom/common/prt

SOURCE
btcmain.c
btccmd.c
btcdcode.c
btceximm.rc
btcgtcmd.c
btcinit.c
btcloccl.c
btclocfl.c
btcprep.c
btcterm.c
#if defined(WIN32S)
btcpaswd.c
btcerrbx.c
#endif

POST_SPECIAL
#if defined(unix)
include $(RISDEVDIR)/risutl/build/rules.c
include $(RISDEVDIR)/risutl/build/rules.rc
#endif
#if defined(WIN32)
!include $(RISDEVDIR)\risutl\build\rulesc.32
!include $(RISDEVDIR)\risutl\build\rulesrc.32
#endif
#if defined(DOS)
!include $(RISDEVDIR)\risutl\build\rulesc.dos
!include $(RISDEVDIR)\risutl\build\rulesrc.dos
#endif
END
