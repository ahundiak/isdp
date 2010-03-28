
SOURCE

DMlinear.S
compute_l.I
dimline_l.I
dimtext_l.I
dynamics_l.I
DMlincpx.S
lincpx.I
conv_l.I

CC
acc -knr

SRC
$(GRNUC)/src/dim/dim_linear

#ifndef NT
LIB
$(GRLIB)/lib/dim_linear.o
#else
ARCHIVE
$(GRLIB)/lib/dim_linear.lib
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
