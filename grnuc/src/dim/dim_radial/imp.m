SOURCE

DMradial.S
DMradjog.S
compute_r.I
dimline_r.I
dimtext_r.I
dynamics_r.I


CC
acc -knr

SRC
$(GRNUC)/src/dim/dim_radial

#ifndef NT
LIB
$(GRLIB)/lib/dim_radial.o
#else
ARCHIVE
$(GRLIB)/lib/dim_radial.lib
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
