INCLUDE
$(INGRHOME)/include
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

CC
acc -knr

COPT
-ga

SRC
$(GRNUC)/src/go/ptngo

#ifndef NT
LIB
$(GRLIB)/lib/ptngosp.o
#else
ARCHIVE
$(GRLIB)/lib/ptngosp.lib
#endif


SOURCE
GRareaptn.S
GRedgeptn.S
GRpa.S
