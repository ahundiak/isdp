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
acc

COPT
-knr -O3

SRC
$(GRNUC)/src/go/tablego

#ifdef IDRAW

LIB
$GRMDS/lib/tablegosp.o

#else
#ifndef NT
LIB
$(GRLIB)/lib/tablegosp.o
#else
ARCHIVE
$(GRLIB)/lib/tablegosp.lib
#endif


#endif

SOURCE
GRtable.S
