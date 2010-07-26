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
$(GRNUC)/src/go/fencego

#ifndef IDRAW

#ifndef NT
LIB
$(GRLIB)/lib/fencegosp.o
#else
ARCHIVE
$(GRLIB)/lib/fencegosp.lib
#endif


#else

LIB
$GRMDS/lib/fencegosp.o

#endif

SOURCE
GRgsmgr.S
