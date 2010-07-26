SRC
$(GRNUC)/src/pplsrc/cinotify

OPP
$(EXTARG)/bin/opp

OMCPP
$(EXTARG)/bin/omcpp

INCLUDE
$(INGRHOME)/include
$(GRNUC)/include
$(EXNUC)/include
$(BS)/include/prototypes
$(GRNUC)/proto_pub
$(GRNUC)/proto_priv

SPEC
$(GRNUC)/spec
$(EXNUC)/spec

SOURCE
cinotifyi.I

#ifndef NT
LIB
$(GRLIB)/lib/cinotify.o
#else
ARCHIVE
$(GRLIB)/lib/cinotify.lib
#endif
