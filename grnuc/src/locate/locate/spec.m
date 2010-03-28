SPEC
$(EXNUC)/spec
$(GRNUC)/spec

INCLUDE
$(INGRHOME)/include
$(INGRHOME)/include
$(EXNUC)/include
$(GRNUC)/include
$(GRNUC)/ingrsys
$(BS)/include/prototypes
$(GRNUC)/proto_pub
$(GRNUC)/proto_priv

SRC
$(GRNUC)/src/locate/locate

CC 
acc -knr

#ifdef IDRAW

LIB
$GRMDS/lib/locatesp.o

#else

#ifndef NT
LIB
$(GRLIB)/lib/locatesp.o
#else
ARCHIVE
$(GRLIB)/lib/locatesp.lib
#endif

#endif

OPP
$(EXTARG)/bin/opp

OMCPP
$(EXTARG)/bin/omcpp

SOURCE
GRrtree.S
