CC
acc

COPT
-O3

SRC
$(GRNUC)/cc

INCLUDE
$(INGRHOME)/include
$(EXNUC)/include
$(GRNUC)/include
$(BS)/proto_include
$(GRNUC)/proto_pub
$(GRNUC)/proto_priv

SPEC
$(EXNUC)/spec
$(GRNUC)/spec

OPP
$(EXTARG)/bin/opp

OMCPP
$(EXTARG)/bin/omcpp

#ifndef NT
LIB
$(GRLIB)/lib/COcc.o
#else
ARCHIVE
$(GRLIB)/lib/COcc.lib
#endif

SOURCE
COcc.S
COcci.I
