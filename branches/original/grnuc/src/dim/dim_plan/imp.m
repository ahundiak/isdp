
SOURCE
dim_plan.S
dim_plani.I
DMplan.S
DMplani.I

CC
acc -knr

SRC
$(GRNUC)/src/dim/dim_plan

#ifndef NT
LIB
$(GRLIB)/lib/dim_plan.o
#else
ARCHIVE
$(GRLIB)/lib/dim_plan.lib
#endif

SPEC
$(EXNUC)/spec
$(GRNUC)/spec

INCLUDE
$(INGRHOME)/include
$(XINC)
$(EXNUC)/include
$(GRNUC)/include
$(GRNUC)/assoc/include_priv
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
