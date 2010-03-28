SOURCE

dim_param.S
dim_parami.I

CC
acc -knr

SRC
$(GRNUC)/src/dim/dim_param

#ifndef NT
LIB
$(GRLIB)/lib/dim_param.o
#else
ARCHIVE
$(GRLIB)/lib/dim_param.lib
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
