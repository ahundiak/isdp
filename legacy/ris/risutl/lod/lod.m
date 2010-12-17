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
$(RISDEVDIR)/risutl/lod

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
$(RISDEVDIR)/risapp/include
$(RISDEVDIR)/riscom/include
$(RISDEVDIR)/riscom/internal
$(RISDEVDIR)/risutl/lod/prt
$(RISDEVDIR)/risutl/ucommon/prt
#if defined(WIN32S)
$(RISDEVDIR)/risutl/unlod/prt
$(RISDEVDIR)/risutl/batch/prt
#else
$(RISDEVDIR)/risutl/dloadld/prt
#endif
$(RISDEVDIR)/riscom/common/prt
$(RISDEVDIR)/riscom/interface/prt

SOURCE
lodbatch.rc
lodcmd.rc
loddbs.rc
loddatfl.rc
loddsind.rc
loddsprv.rc
loddsprt.rc
loddssch.rc
loddstab.rc
loddsvie.rc
loddmp.rc
lodermsg.rc
lodexdat.rc
lodflddf.rc
lodgtspc.rc
lodgtstm.rc
lodinxdf.rc
lodinsrt.rc
lodlogdp.rc
lodmisc.rc
lodprvdf.rc
lodprvls.rc
lodschdf.rc
lodschst.rc
lodstfld.rc
lodstspc.rc
lodtabda.rc
lodtabdf.rc
lodtime.rc
lodviedf.rc
#if defined(unix) || defined(DOS) || defined(WIN32) && !defined(WIN32S)
lodwhat.rc
main.rc
#endif
#if defined(WIN32S) && defined(ULD_EXE)
lodwhat.rc
main.rc
loddesch.rc
lodpaswd.rc
lod32s.rc
#endif
#if defined(WIN32S)
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
