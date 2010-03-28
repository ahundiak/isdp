CC
acc -knr

SOURCE

DEso.S

SRC
$(GRNUC)/src/go/so

#ifndef NT
LIB
$(GRLIB)/lib/DEso_spec.o
#else
ARCHIVE
$(GRLIB)/lib/DEso_spec.lib
#endif


SPEC
$(EXNUC)/spec
$(GRNUC)/spec

INCLUDE
$(INGRHOME)/include
$(EXNUC)/include
$(GRNUC)/include
$(GRNUC)/ingrsys
$(BS)/include
$(BS)/include/prototypes
$(GRNUC)/proto_pub
$(GRNUC)/proto_priv

OPP
$(EXTARG)/bin/opp

OMCPP
$(EXTARG)/bin/omcpp
