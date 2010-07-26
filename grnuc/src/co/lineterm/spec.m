
SRC
$(GRNUC)/src/co/lineterm

#ifdef IDRAW
LIB
$GRMDS/lib/lineterm_sp.o

SOURCE

GRlnterm.S

#else

#ifndef NT
LIB
$(GRLIB)/lib/lineterm_sp.o
#else
ARCHIVE
$(GRLIB)/lib/lineterm_sp.lib
#endif

SOURCE

GRlnterm.S

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
acc -knr -O3
