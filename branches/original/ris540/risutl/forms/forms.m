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
$(RISDEVDIR)/risutl/forms

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

$(RISDEVDIR)/risutl/forms/prt
$(RISDEVDIR)/risutl/dloadfrm/prt
$(RISDEVDIR)/risutl/ucommon/prt
$(RISDEVDIR)/risutl/dloadfrm/prt
$(RISDEVDIR)/riscom/common/prt

SOURCE
frmaltab.c
frmcrsch.c
frmcrtab.c
frmdicac.c
frmdadef.c
frmdb2ps.c
frmdbs.c
frmdebug.c
frmdrsch.c
frmdrtab.c
frmexcl.c
frmfile.c
frmincl.c
frminit.c
frmlocli.c
frmmsg.c
frmnodin.c
frmntfy.c
frmosusr.c
frmpswd.c
frmschac.c
frmschdf.c
frmschfl.c
frmschin.c
frmschmg.c
frmschps.c
frmset.c
frmtabin.c
frmuspw.c
frmutil.c

frmacusr.rc
frmcolmn.rc
frmdbcol.rc
frmdbobj.rc
frmdbusr.rc
frmerror.rc
frmexec.rc
frmobj.rc
frmusers.rc
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
