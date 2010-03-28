COPT =-g

OPPOPT =-l

SRC
$(GRNUC)/src/assoc/absg_graph

SOURCE

GMhcode.C
GMlist.C
GMgraph.C
GMigraph.C
GMloop.C
GMsyst.C
GMtools.C

#ifndef NT
LIB
$(GRLIB)/lib/absg_graph.o
#else
ARCHIVE
$(GRLIB)/lib/absg_graph.lib
#endif


SPEC

INCLUDE
$(INGRHOME)/include
$(EXNUC)/include
$(GRNUC)/include
$(GRNUC)/src/assoc/include_priv
$(BS)/include/prototypes
$(GRNUC)/proto_pub
$(GRNUC)/proto_priv

OPP
$(EXTARG)/bin/opp

OMCPP
$(EXTARG)/bin/omcpp
