
SOURCE

DMangular.S
compute_a.I
dimline_a.I
dimtext_a.I
place_a.I
cpx_a.I
DMsglarc.S
sglarc.I

SRC
$(GRNUC)/src/dim/dim_angular

#ifndef NT
LIB
$(GRLIB)/lib/dim_angular.o
#else
ARCHIVE
$(GRLIB)/lib/dim_angular.lib
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
