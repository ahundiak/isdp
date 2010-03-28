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

SRC
$(GRNUC)/src/co/transco

#ifndef IDRAW

#ifndef NT
LIB
$(GRLIB)/lib/transcosp.o
#else
ARCHIVE
$(GRLIB)/lib/transcosp.lib
#endif

#else

LIB
$GRMDS/lib/transcosp.o

#endif

OPP
$(EXTARG)/bin/opp

OMCPP
$(EXTARG)/bin/omcpp

CC
acc -knr

SOURCE
COcvigeigds.S
COcvigdsige.S
COcvtclsl.S
