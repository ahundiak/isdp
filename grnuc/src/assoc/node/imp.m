SRC
$(GRNUC)/src/assoc/node

CC
acc -knr

SOURCE

NDnode.S
NDnodei.I
NDnode_notif.I
NDdrawing.I

EMSpointerA.S
EMpointerA.I

NDmacro.S
NDmacroi.I 

NDgivestr.I
NDgm.I
graph.I
batch.I
fence.I
global.C

#ifndef NT
LIB
$(GRLIB)/lib/node.o
#else
ARCHIVE
$(GRLIB)/lib/node.lib
#endif

SPEC
$(EXNUC)/spec
$(GRNUC)/spec

INCLUDE
$(INGRHOME)/include
$(XINC)
$(GRNUC)/src/assoc/include_priv
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
