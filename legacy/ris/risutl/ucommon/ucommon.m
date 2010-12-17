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
END

SRC
$(RISDEVDIR)/risutl/ucommon

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
$(RISDEVDIR)/risutl/internal
$(RISDEVDIR)/risutl/include
$(RISDEVDIR)/riscom/internal
$(RISDEVDIR)/riscom/include
$(RISDEVDIR)/riscom/common/prt
$(RISDEVDIR)/risapp/include
$(RISDEVDIR)/risutl/ucommon/prt

SOURCE
ucoblob.rc
ucocmd.c
ucodcode.c
ucodebug.c
ucoerrbx.c
ucofgets.c
ucoglobs.c
ucopath.c
ucosqlca.c
ucoshfil.c
ucoshprm.c
ucostrng.c
#if !defined(WIN32S)
ucoanyky.c
ucopaswd.c
ucoterm.c
ucodesch.rc
#endif
ucoumsg.c
#if defined(WIN32) && !defined(WIN32S)
ucowinsz.c
#endif
#if defined(WIN32) || defined(WIN32S)
ucoio.c
#endif
#if defined(WIN32) || defined(DOS) || defined(WIN32S)
ucogtopt.c
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
