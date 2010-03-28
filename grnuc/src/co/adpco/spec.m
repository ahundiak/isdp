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

COPT
-ga

CC
acc -knr -O3

SPEC
$(EXNUC)/spec
$(GRNUC)/spec

SRC
$(GRNUC)/src/co/adpco

#ifndef IDRAW

#ifndef NT
LIB
$(GRLIB)/lib/adpcosp.o
#else
ARCHIVE
$(GRLIB)/lib/adpcosp.lib
#endif

#else

LIB
$GRMDS/lib/adpcosp.o

#endif

SOURCE
COsetadp.S
GRadp.S
