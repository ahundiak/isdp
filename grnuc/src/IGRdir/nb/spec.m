SRC
$(GRNUC)/src/IGRdir/nb

#ifndef NT
LIB
$(GRLIB)/lib/GRnbspec.o
#else
ARCHIVE
$(GRLIB)/lib/GRnbspec.lib
#endif


SOURCE
GRnb.S

SPEC
$(EXNUC)/spec
$(GRNUC)/spec
 
INCLUDE
$(INGRHOME)/include
$(XINC)
$(EXNUC)/include
$(GRNUC)/include
$(GRNUC)/ingrsys
$(BS)/include
 
OPP
$(EXTARG)/bin/opp
 
OMCPP
$(EXTARG)/bin/omcpp
 
CC
acc -knr -O3
