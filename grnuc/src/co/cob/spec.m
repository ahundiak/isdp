
SRC
$(GRNUC)/src/co/cob

#ifdef IDRAW
LIB
$GRMDS/lib/cob_sp.o

SOURCE
COexp.S
COconst.S
COcoord.S
COmeasure.S
COnpt.S
COroot.S

#else

#ifndef NT
LIB
$(GRLIB)/lib/cob_sp.o
#else
ARCHIVE
$(GRLIB)/lib/cob_sp.lib
#endif

SOURCE
COexp.S
COconst.S
COcoord.S
COmeasure.S
COnpt.S
COroot.S
DEnpt.S
#endif

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

SPEC
$(EXNUC)/spec
$(GRNUC)/spec

OPP
$(EXTARG)/bin/opp

OMCPP
$(EXTARG)/bin/omcpp

CC
acc -knr -O3
