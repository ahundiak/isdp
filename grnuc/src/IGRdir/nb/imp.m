SRC
$(GRNUC)/src/IGRdir/nb

#ifndef NT
LIB
$(GRLIB)/lib/GRnb.o
#else
ARCHIVE
$(GRLIB)/lib/GRnb.lib
#endif


SOURCE
GRnbi.I

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
#if defined (XGL)
$(XGLHOME)/include
$(XGLHOME)/include/xgl
#endif
 
OPP
$(EXTARG)/bin/opp
 
OMCPP
$(EXTARG)/bin/omcpp
 
CC
acc -knr -O3
