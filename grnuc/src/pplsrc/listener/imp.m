SRC
$(GRNUC)/src/pplsrc/listener

SOURCE
ci_listener.S
ci_listeneri.I

#ifndef NT
LIB
$(GRLIB)/lib/ci_listener.o
#else
ARCHIVE
$(GRLIB)/lib/ci_listener.lib
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
