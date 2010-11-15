SPECIAL
#if defined(unix)
SHELL=/bin/ksh
NONFUNCTIONS=$(RISDEVDIR)/risutl/internal/nonfuncs
#endif
#if defined(WIN32)
!include $(RISDEVDIR)\ristools\include\makeenv.nt
#endif
#if defined(DOS)
!include $(RISDEVDIR)/ristools/include/makeenv.dos
#endif
END

SRC
$(RISDEVDIR)/risutl/edit

INCLUDE
#if defined(unix)
/usr/include
#endif
#if defined(sun)
/usr/5include
#endif
#if defined(WIN32)
$(MSTOOLSDIR)\h
#endif
#if defined (DOS)
$(HIGHCDIR)\inc
#endif
$(RISDEVDIR)/risutl/include
$(RISDEVDIR)/risutl/internal
$(RISDEVDIR)/riscom/include
$(RISDEVDIR)/riscom/internal
$(RISDEVDIR)/risutl/edit/prt
$(RISDEVDIR)/risutl/ucommon/prt
$(RISDEVDIR)/riscom/common/prt

SOURCE
edtgtcmd.c
edtgets.c
#if defined(WIN32)
edtwin32.c
#endif

POST_SPECIAL
#if defined(unix)
include $(RISDEVDIR)/risutl/build/rules.c
#endif
#if defined(WIN32)
!include $(RISDEVDIR)\risutl\build\rulesc.nt
#endif
#if defined (DOS)
!include $(RISDEVDIR)\risutl\build\rulesc.dos
#endif
END
