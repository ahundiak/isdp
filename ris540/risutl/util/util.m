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
END_SPECIAL

SRC
$(RISDEVDIR)/risutl/util

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
$(HIGHCDIR)/inc
#endif
$(RISDEVDIR)/risutl/include
$(RISDEVDIR)/risutl/internal
$(RISDEVDIR)/riscom/include
$(RISDEVDIR)/riscom/internal
$(RISDEVDIR)/risapp/include
$(RISDEVDIR)/risutl/util/prt
$(RISDEVDIR)/risutl/edit/prt
$(RISDEVDIR)/risutl/ucommon/prt
$(RISDEVDIR)/riscom/common/prt

SOURCE
utlclear.rc
utlcli.c
utlclose.c
utldebug.c
utlerror.rc
utlexec.c
utlfetch.c
utlglobs.c
utlid.c
utlmisc.c
utloutpt.c
utlparm.c
#if !defined(WIN32S)
utlpaswd.rc
#endif /* !WIN32S */
utlprint.c
utlquery.rc
utlread.c
utlreprt.rc
utlshasy.c
utlshfil.c
utlshflg.c
utlshmem.c
utlshnam.c
utlshprm.c
utlshss.c
utlshstm.c
utlshtrn.c
utltest.rc
#if defined(unix) || defined(DOS)
utlcmd.c
utldcode.c
utleximm.rc
utlinit.c
utlintrp.c
utlloccl.c
utllocfl.c
utlmain.c      
utlprep.c
utlterm.c
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
!include $(RISDEVDIR)/risutl/build/rulesc.dos
!include $(RISDEVDIR)/risutl/build/rulesrc.dos
#endif
END
