
SRC
$(GRNUC)/src/co/lineterm

#ifdef IDRAW
ARCHIVE
$GRMDS/lib/lineterm.a

#else

#ifndef NT
LIB
$(GRLIB)/lib/lineterm.o
#else
ARCHIVE/lib/lineterm.lib
#endif

#endif
 
SOURCE

COnilnterm.I
GRlntinit.I

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
