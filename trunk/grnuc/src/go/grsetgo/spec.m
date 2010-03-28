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
$(GRNUC)/src/go/grsetgo

#ifdef IDRAW

LIB
$GRMDS/lib/grsetgosp.o

#else

#ifndef NT
LIB
$(GRLIB)/lib/grsetgosp.o
#else
ARCHIVE
$(GRLIB)/lib/grsetgosp.lib
#endif


#endif

SOURCE
GRfcset.S
GRgrset.S
GRsvset.S
