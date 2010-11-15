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
$(RISDEVDIR)/risapp/intrface

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

$(RISDEVDIR)/risapp/intrface/prt
$(RISDEVDIR)/risapp/app/prt
$(RISDEVDIR)/riscom/common/prt
$(RISDEVDIR)/riscom/network/prt


SOURCE
intatod.c
intcksum.c
intclear.c
intclose.c
intdebug.c
intdscrb.c
intdtoa.c
interror.c
intexec.c
inteximm.c
intfetch.c
intgetss.c
intglerr.c
intglobs.c
intgtasy.c
intgtfil.c
intgtflg.c
intgtlng.c
intgtnme.c
intgtpcl.c
intgtprm.c
intgttrn.c
intgtver.c
intinit.c
intlocli.c
intlocfl.c
intparms.c
intprep.c
intrap.c
intrperr.c
intsmgr.c
intslct.c
intshapp.c
intshcli.c
intsserr.c
intterm.c
inttest.c
inttypes.c
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
