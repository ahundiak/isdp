SRC 
$(GRNUC)/src/pplsrc/ciexpr

SOURCE
ciexpr.S
ciexpri.I

#ifndef NT
LIB
$(GRLIB)/lib/ciexpr.o
#else
ARCHIVE
$(GRLIB)/lib/ciexpr.lib
#endif

SPEC
$(EXNUC)/spec
$(GRNUC)/spec

INCLUDE
$(INGRHOME)/include
$(EXNUC)/include
$(GRNUC)/include
$(BS)/include
$(BS)/include/prototypes
$(GRNUC)/proto_pub
$(GRNUC)/proto_priv

OPP
$(EXTARG)/bin/opp

OMCPP
$(EXTARG)/bin/omcpp
