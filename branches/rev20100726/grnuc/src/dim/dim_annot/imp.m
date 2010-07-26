
SOURCE

DMannot.S
annot.I
DMtxldr.S
txldr.I
dyn_txldr.I
DMleader.S
leader.I
dyn_leader.I
DMtxbln.S
txbln.I
dyn_txbln.I
DMframe.S
frame.I
dyn_gt.I
modify.I
DMweld.S
weld.I
weldtxt.I
dyn_weld.I
DMsurf.S
surf.I
dyn_surf.I

CC
acc -knr

SRC
$(GRNUC)/src/dim/dim_annot

#ifndef NT
LIB
$(GRLIB)/lib/dim_annot.o
#else
ARCHIVE
$(GRLIB)/lib/dim_annot.lib
#endif

SPEC
$(EXNUC)/spec
$(GRNUC)/spec

INCLUDE
$(INGRHOME)/include
$(XINC)
$(BS)/include
$(EXNUC)/include
$(GRNUC)/include
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
