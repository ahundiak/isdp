CC
acc -knr

SRC
$(GRNUC)/src/assoc/exec_node

SOURCE

ASnode.S
ASnodei.I
GRgraph_over.I
GRvg_over.I
ASfunksupp.I
GRinstread.I
ASnode_other.I
GRown_over.I
ACmacro_over.I
NDtrans_over.I
NDdegraded.I
ASmultigo.I
ASdrawing.I

ASbspline.S
ASbsplinei.I

ASlinear.S
ASlineari.I

ASconic.S
ASconici.I

ASgencs.S
ASgencsi.I

ASline.S
ASlinei.I

ASpoint.S
ASpointi.I

ASgroup.S
ASgroupi.I
ASnodeanal.I

#ifndef NT
LIB
$(GRLIB)/lib/exec_node.o
#else
ARCHIVE
$(GRLIB)/lib/exec_node.lib
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
