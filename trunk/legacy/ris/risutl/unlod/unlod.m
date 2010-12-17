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
$(RISDEVDIR)/risutl/unlod

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
$(RISDEVDIR)/risutl/include
$(RISDEVDIR)/risutl/internal
$(RISDEVDIR)/riscom/include
$(RISDEVDIR)/riscom/internal
$(RISDEVDIR)/risapp/include
$(RISDEVDIR)/risutl/unlod/prt
$(RISDEVDIR)/risutl/ucommon/prt
$(RISDEVDIR)/risutl/dloadld/prt
$(RISDEVDIR)/riscom/common/prt
#if defined(WIN32S)
$(RISDEVDIR)/risutl/batch/prt
#endif

SOURCE
uldbatch.rc
uldcmd.rc
ulddsind.rc
ulddsprv.rc
ulddsprt.rc
ulddssch.rc
ulddstab.rc
ulddsvie.rc
uldermsg.rc
uldfmsch.rc
uldgtind.rc
uldgtprv.rc
uldgtsch.rc
uldgtspc.rc
uldgttab.rc
uldgtvie.rc
uldinddf.rc
uldindqy.rc
uldmisc.rc
uldprvdf.rc
uldprvfm.rc
uldprvqy.rc
uldschdf.rc
uldsecur.rc
uldsmind.rc
uldsmprv.rc
uldstspc.rc
uldtabda.rc
uldtabhr.rc
uldtabin.rc
uldtime.rc
uldusdec.rc
uldviedf.rc
uldwhere.rc
#if defined(unix) || defined(DOS) || defined(WIN32) && !defined(WIN32S)
uldinter.rc
uldenter.rc
uldwhat.rc
main.rc
#endif
#if defined(WIN32S) && defined(ULD_EXE)
uldinter.rc
uldenter.rc
uldwhat.rc
main.rc
ulddesch.rc
uldpaswd.rc
#endif
#if defined(WIN32S)
uld32s.rc
#endif

POST_SPECIAL
#if defined(unix)
include $(RISDEVDIR)/risutl/build/rules.rc
#endif
#if defined(WIN32)
!include $(RISDEVDIR)\risutl\build\lurc.32
#endif
#if defined(DOS)
!include $(RISDEVDIR)\risutl\build\rulesrc.dos
#endif
END
