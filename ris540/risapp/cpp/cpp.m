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
END_SPECIAL

SRC
$(RISDEVDIR)/risapp/cpp

INCLUDE
#if defined(unix)
/usr/include
#endif
#if defined(sun)
/usr/5include
#endif
#if defined(WIN32)
$(MSTOOLSDIR)\include
$(SETUPSDK_DIR)\licapi
#endif
#if defined(DOS)
$(HIGHCDIR)\inc
$(INSTALITDIR)\LICAPI
#endif

$(RISDEVDIR)/risapp/include
$(RISDEVDIR)/risapp/internal
$(RISDEVDIR)/riscom/include
$(RISDEVDIR)/riscom/internal

$(RISDEVDIR)/risapp/cpp/prt
$(RISDEVDIR)/risapp/app/prt
$(RISDEVDIR)/risapp/intrface/prt
$(RISDEVDIR)/riscom/parse/prt
$(RISDEVDIR)/riscom/common/prt


SOURCE
cppclear.c
cppclose.c
cppcursr.c
cppdecl.c
cppdesc.c
cpperror.c
cppexec.c
cppfetch.c
cppfopen.c
cppmacro.c
cppmain.c
cppmisc.c
cppopen.c
cppparm.c
cppprep.c
cppproc.c
cpprprt.c
cppslct.c
cppsqlst.c
cppstmid.c
cpptest.c
cpptrans.c
cpptrstr.c
cppupdte.c
cppvar.c

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
END_SPECIAL
