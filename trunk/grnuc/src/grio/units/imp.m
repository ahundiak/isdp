SRC
$(GRNUC)/src/grio/units

#ifdef IDRAW

ARCHIVE
$(GRMDS)/lib/units.a

SOURCE
 
GRaddals.I     GRecvtalfn.I   GRgetdef.I     
GRchgdef.I     GRecvtwkfn.I   GRgetdeffn.I   GRicvtalfn.I
GRfindal.I     GRicvtwkfn.I
GRfltascfn.C   GRputdeffn.I
GRcvtvlvl.I    GRfltfrac.C    GRstprepnd.C
GRdelals.I     GRfmtoutfn.C   GRuprdspfn.I
COisunitsl.I   GRfltscifn.C   GRisunitsl.I   GRunitsi.I
GRengmet.C     GRrtnlst.I

#else

#ifndef NT
LIB
$(GRLIB)/lib/units.o
#else
ARCHIVE
$(GRLIB)/lib/units.lib
#endif

SOURCE
 
GRaddals.I     GRecvtalfn.I   GRgetdef.I     
GRchgdef.I     GRecvtwkfn.I   GRgetdeffn.I   GRicvtalfn.I
GRfindal.I     GRicvtwkfn.I
GRfltascfn.C   GRputdeffn.I
GRcvtvlvl.I    GRfltfrac.C    GRstprepnd.C
GRdelals.I     GRfmtoutfn.C   GRuprdspfn.I
COisunitsl.I   GRfltscifn.C   GRisunitsl.I   GRunitsi.I
GRengmet.C     GRrtnlst.I

#endif

SPEC
$(EXNUC)/spec
$(EXNUC)/icob/spec
$(EXNUC)/message/spec
$(EXNUC)/fi/spec
$(GRNUC)/spec
 
INCLUDE
$(INGRHOME)/include
$(XINC)
$(EXNUC)/include
$(GRNUC)/include
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
