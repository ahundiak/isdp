SPECIAL
#if defined(unix)
SHELL=/bin/ksh
NONFUNCTIONS=$(RISDEVDIR)/risutl/internal/nonfuncs
#endif
#if defined(WIN32)
!include $(RISDEVDIR)\ristools\include\makeenv.nt
#endif
END

SRC
$(RISDEVDIR)/risutl/gui

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

$(RISDEVDIR)/risutl/include
$(RISDEVDIR)/risutl/internal
$(RISDEVDIR)/risapp/include
$(RISDEVDIR)/riscom/include
$(RISDEVDIR)/riscom/internal

$(RISDEVDIR)/risutl/gui/prt
$(RISDEVDIR)/risutl/ucommon/prt
$(RISDEVDIR)/riscom/common/prt

SOURCE
guiabou.c
guicfrm.c
guidbg.c
guifile.c
#if defined(WIN32)
guihelp.c
#endif
guiin.c
guiinit.c
guimsg.c
guintfy.c
guiosusr.c
guiopts.c
guiparm.c
guipswd.c
guiset.c
guishow.c
guishtr.c
guisrch.c
guistack.c
guitran.c
guiuspw.c
guiutil.c
guiutls.c

guierror.rc
guiquery.rc
guiexec.rc
#if defined(BUILD_ENV5) || defined(WIN32)
event.c
main.rc
#endif
#if defined(BUILD_X)
xevent.c
xmain.rc
#endif

POST_SPECIAL
#if defined(unix)
include $(RISDEVDIR)/risutl/build/rules.rc
include $(RISDEVDIR)/risutl/build/rules.c
#endif

#if defined(WIN32)
!include $(RISDEVDIR)\risutl\build\rulesrc.nt
!include $(RISDEVDIR)\risutl\build\rulesc.nt
#endif
END
