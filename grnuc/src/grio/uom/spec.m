SRC
$(GRNUC)/src/grio/uom

SOURCE
UOMsuper.S
COedtuom.S

INCLUDE
$(INGRHOME)/include
$(EXNUC)/include
$(GRNUC)/include
$(BS)/include/prototypes
$(GRNUC)/proto_pub
$(GRNUC)/proto_priv

SPEC
$(EXNUC)/spec
$(GRNUC)/spec

#ifndef NT
LIB
$(GRLIB)/lib/uomsp.o
#else
ARCHIVE
$(GRLIB)/lib/uomsp.lib
#endif

CC
acc

COPT
-ga -knr -O3

OPP
$(EXTARG)/bin/opp

OMCPP
$(EXTARG)/bin/omcpp

