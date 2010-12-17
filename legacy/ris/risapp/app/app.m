SPECIAL
#if defined(unix)
SHELL=/bin/ksh
NONFUNCTIONS=$(RISDEVDIR)/risapp/internal/nonfuncs
#endif
#if defined(WIN32)
!include $(RISDEVDIR)\ristools\include\makeenv.nt
#endif
#if defined(DOS)
!include $(RISDEVDIR)\ristools\include\makeenv.dos
#endif
END

SRC
$(RISDEVDIR)/risapp/app

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
$(RISDEVDIR)/risapp/include
$(RISDEVDIR)/risapp/internal
$(RISDEVDIR)/riscom/include
$(RISDEVDIR)/riscom/internal
$(RISDEVDIR)/risapp/app/prt
$(RISDEVDIR)/riscom/arch/prt
$(RISDEVDIR)/riscom/common/prt
$(RISDEVDIR)/riscom/network/prt

SOURCE
appasync.c
appbufto.c
appblob.c
appclear.c
appcli.c
appclose.c
appcnv.c
appcrsr.c
appdcml.c
#if defined(WIN32)
appdtype.c
appnmric.c
appep.c
#endif
appgetfl.c
appglobs.c
appid.c
appinit.c
appmisc.c
appparmf.c
appparms.c
appschf.c
appsndrc.c
appsig.c
appsqlca.c
appterm.c
apptobuf.c
appver.c

POST_SPECIAL
#if defined(unix)
include $(RISDEVDIR)/risapp/build/rules.c
#endif
#if defined(WIN32)
!include $(RISDEVDIR)\risapp\build\rulesc.nt
#endif
#if defined(DOS)
!include $(RISDEVDIR)\risapp\build\rulesc.dos
#endif
END
