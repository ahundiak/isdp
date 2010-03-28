SRC
$(GRNUC)/src/grdpb/grdpb

CC
acc -knr

SOURCE
GRdpb.S

SRC
$(GRNUC)/src/grdpb/grdpb

#ifndef NT
LIB
$(GRLIB)/lib/grdpbsp.o
#else
ARCHIVE
$(GRLIB)/lib/grdpbsp.lib
#endif


SPEC
$(GRNUC)/spec
$(EXNUC)/spec

INCLUDE
$(INGRHOME)/include
$(INGRHOME)/include
$(GRNUC)/include
$(EXNUC)/include
$(BS)/include
$(BS)/include/prototypes
$(GRNUC)/proto_pub
$(GRNUC)/proto_priv

OPP
$(EXTARG)/bin/opp

OMCPP
$(EXTARG)/bin/omcpp
