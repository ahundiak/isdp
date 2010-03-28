SRC
$(GRNUC)/src/co/coglobal

#ifdef IDRAW
LIB
$GRMDS/lib/coglobal.o

SOURCE
coglobal.C

#else

#ifndef NT
LIB
$(GRLIB)/lib/coglobal.o
#else
ARCHIVE
$(GRLIB)/lib/coglobal.lib
#endif

SOURCE 
coglobal.C

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
