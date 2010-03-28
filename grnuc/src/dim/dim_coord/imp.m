
SOURCE

DMcoord.S
DMcoordj.S
compute_c.I
dimline_c.I
dimtext_c.I
dynamics_c.I

CC  
acc -knr

SRC
$(GRNUC)/src/dim/dim_coord 

#ifndef NT
LIB
$(GRLIB)/lib/dim_coord.o
#else
ARCHIVE
$(GRLIB)/lib/dim_coord.lib
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
