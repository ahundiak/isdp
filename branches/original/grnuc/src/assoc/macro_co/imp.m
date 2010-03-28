SRC
$(GRNUC)/src/assoc/macro_co

CC
acc -knr

INCLUDE
$(INGRHOME)/include
$(GRNUC)/src/assoc/include_priv
$(EXNUC)/include
$(GRNUC)/include
$(BS)/include
$(BS)/include/prototypes
$(GRNUC)/proto_pub
$(GRNUC)/proto_priv

SPEC
$(EXNUC)/spec
$(GRNUC)/spec

OPP
$(EXTARG)/bin/opp

OMCPP
$(EXTARG)/bin/omcpp

SOURCE
COm_del.S
COm_edit.S

COm_deli.I
COm_editi.I

#ifndef NT
LIB
$(GRLIB)/lib/macro_co.o
#else
ARCHIVE
$(GRLIB)/lib/macro_co.lib
#endif
