INCLUDE
$(INGRHOME)/include
$(XINC)
./priv
$(EXNUC)/include
$(GRNUC)/include
$(BS)/include
$(BS)/include/prototypes
$(GRNUC)/proto_pub
$(GRNUC)/proto_priv
#if defined (XGL)
$(XGLHOME)/include
$(XGLHOME)/include/xgl
#endif

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
$(GRNUC)/src/co/ptnco

#ifndef NT
LIB
$(GRLIB)/lib/ptnco.o
#else
ARCHIVE
$(GRLIB)/lib/ptnco.lib
#endif

SOURCE
COpatterni.I

