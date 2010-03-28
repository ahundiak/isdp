SRC
$(GRNUC)/src/pplsrc/user_data

SOURCE
user_data.S
user_datai.I

#ifndef NT
LIB
$(GRLIB)/lib/user_data.o
#else
ARCHIVE
$(GRLIB)/lib/user_data.lib
#endif

SPEC
$(GRNUC)/spec
$(EXNUC)/spec

INCLUDE
$(INGRHOME)/include
$(EXNUC)/include
$(GRNUC)/include
$(BS)/include/prototypes
$(GRNUC)/proto_pub
$(GRNUC)/proto_priv

OPP
$(EXTARG)/bin/opp

OMCPP
$(EXTARG)/bin/omcpp
