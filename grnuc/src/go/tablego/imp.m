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
acc -knr -O3

COPT
-ga

SRC
$(GRNUC)/src/go/tablego

#ifdef IDRAW

ARCHIVE
$(GRMDS)/lib/tablego.a

#else
#ifndef NT
LIB
$(GRLIB)/lib/tablego.o
#else
ARCHIVE
$(GRLIB)/lib/tablego.lib
#endif

#endif

SOURCE
GRtablei.I
GRtblfunk.I
