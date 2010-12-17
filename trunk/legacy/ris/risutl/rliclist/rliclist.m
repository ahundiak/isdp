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
$(RISDEVDIR)/risutl/rliclist

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
$(HIGHDIR)\include
#endif
$(RISDEVDIR)/risutl/internal
$(RISDEVDIR)/riscom/internal
$(RISDEVDIR)/riscom/include
$(RISDEVDIR)/risutl/rliclist/prt
$(RISDEVDIR)/risutl/ucommon/prt
$(RISDEVDIR)/riscom/common/prt

SOURCE
rliclist.c

POST_SPECIAL
#if defined(unix)
include $(RISDEVDIR)/risutl/build/rules.c
#endif
#if defined(WIN32)
!include $(RISDEVDIR)\risutl\build\rulesc.nt
    @copy ..\rliclist.ico
    @copy ..\3dcheck.bmp
    @copy ..\rislist.rtf
    @copy ..\rislist.hpj
    @copy ..\rliclist.bmp
    @hc31 rislist.hpj
    @copy rislist.hlp ..\..\config\english\help
#endif
#if defined(DOS)
!include $(RISDEVDIR)\risutl\build\rulesc.dos
#endif
END
