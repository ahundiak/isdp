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
$(GRNUC)/src/go/grgrpgo

#ifdef IDRAW

LIB
$GRMDS/lib/grgrpgosp.o

#else

#ifndef NT
LIB
$(GRLIB)/lib/grgrpgosp.o
#else
ARCHIVE
$(GRLIB)/lib/grgrpgosp.lib
#endif


#endif

SOURCE
GRgrgrp.S
