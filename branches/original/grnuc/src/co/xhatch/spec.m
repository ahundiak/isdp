
SRC
$(GRNUC)/src/co/xhatch

#ifdef IDRAW

LIB
$GRMDS/lib/xhatch_sp.o

SOURCE
 
GRcoxhatch.S   GRxhgg.S
 
#else

#ifndef NT
LIB
$(GRLIB)/lib/xhatch_sp.o
#else
ARCHIVE
$(GRLIB)/lib/xhatch_sp.lib
#endif

SOURCE
 
GRcoxhatch.S   GRxhgg.S
 
#endif

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
 
OPP
$(EXTARG)/bin/opp
 
OMCPP
$(EXTARG)/bin/omcpp
 
CC
acc -knr
