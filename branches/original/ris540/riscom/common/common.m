Do not alter this PINNACLE information: $Revision: 1.5.22.1 $
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
$(RISDEVDIR)/riscom/common

INCLUDE
#if defined(unix)
$(RISDEVDIR)/risums/unix/include
/usr/include
#endif
#if defined(sun)
$(RISDEVDIR)/risums/unix/include
/usr/5include
#endif
#if defined(WIN32)
$(RISDEVDIR)\risums\nt\include
$(MSTOOLSDIR)\include
#endif
#if defined(DOS)
$(HIGHCDIR)\inc
$(UMSDIR)\include
#endif

$(RISDEVDIR)/riscom/include
$(RISDEVDIR)/riscom/internal

$(RISDEVDIR)/riscom/common/prt
$(RISDEVDIR)/riscom/arch/prt
$(RISDEVDIR)/riscom/network/prt

SOURCE
comaccss.c
comalloc.c
comarch.c
comauth.c
comdate.c
comdebug.c
comdcml.c
comdict.c
comdll.c
comexmod.c
comfree.c
comgtdir.c
comgtnme.c
comglobs.c
#if defined(DOS)
comhsrch.c
#endif
#if defined(WIN32)
comgtver.c
comhsrch.c
comparcl.c
complat.c
#endif
comisfn.c
comjmp.c
comlang.c
commem.c
comoutpt.c
compath.c
compd.c
comprtcl.c
#if defined(unix) || defined(WIN32) || defined(DOS)
comqryht.c
comrap.c
#endif
comrealc.c
comsqlca.c
comsqlms.c
comstmt.c
comsttyp.c
comstcmi.c
comstrcp.c
comstrng.c
comsusti.c
comswmem.c
comsyser.c
comtime.c
comtree.c
comumsg.c
comver.c
comwrap.c
comuni.c
#if defined(unix)
comc2pw.c
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

