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
$(GRNUC)/src/go/ownergo

#ifdef IDRAW

LIB
$GRMDS/lib/ownergosp.o

#else

#ifndef NT
LIB
$(GRLIB)/lib/ownergosp.o
#else
ARCHIVE
$(GRLIB)/lib/ownergosp.lib
#endif


#endif

SOURCE
GRcmpowner.S
GRflxown.S
GRowner.S
