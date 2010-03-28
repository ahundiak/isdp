SOURCE

dim_src.S
dim_srci.I
DMsrc.S
DMsrci.I
compute.I

SRC
$(GRNUC)/src/dim/dim_src

#ifndef NT
LIB
$(GRLIB)/lib/dim_src.o
#else
ARCHIVE
$(GRLIB)/lib/dim_src.lib
#endif

CC
acc -knr

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
