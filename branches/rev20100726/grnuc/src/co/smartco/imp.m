SRC
$(GRNUC)/src/co/smartco

#ifdef NT
ARCHIVE
$(GRLIB)/lib/smartco.lib
#else
LIB
$(GRLIB)/lib/smartco.o
#endif

SOURCE
SSActive.I
SSAddObject.I
SSCheckEvent.I
SSChkCndt.I
SSChkDir.I
SSChkHzVt.I
SSChkObjects.I
SSChkOnEle.I
SSChkTg.I
SSDispCnstr.I
SSDispIcon.I
SSEnter.I
SSExit.I
SSFindObject.I
SSGetRtree.I
SSGetType.C
SSGetWinTol.I
SSGlob.C
SSHasMoved.I
SSHiCnstr.I
SSLisAdd.I
SSLstMbr.C
SSLstRm.C
SSLstkpact.C
SSOptions.C
SSOrder.I
SSSetNewEle.I
SSSvLstCnstr.I
SSUpdtNew.C
SStest.I

SPEC
$(EXNUC)/spec
$(GRNUC)/spec
 
INCLUDE
$(INGRHOME)/include
$(XINC)
$(EXNUC)/include
$(GRNUC)/include
$(GRNUC)/ingrsys
$(BS)/include
$(BS)/include/prototypes
$(GRNUC)/proto_pub
$(GRNUC)/proto_priv
#if defined (XGL)
$(XGLHOME)/include
$(XGLHOME)/include/xgl
#endif
 
OPP
$(EXTARG)/bin/opp
 
OMCPP
$(EXTARG)/bin/omcpp

CC
acc -knr -O3
