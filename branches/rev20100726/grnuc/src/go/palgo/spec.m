INCLUDE
$(INGRHOME)/include
$(XINC)
./priv
$(EXNUC)/include
$(GRNUC)/include
$(GRNUC)/ingrsys
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
acc -knr

COPT
-ga

SRC
$(GRNUC)/src/go/palgo

#ifndef NT
LIB
$(GRLIB)/lib/palgosp.o
#else
ARCHIVE
$(GRLIB)/lib/palgosp.lib
#endif


SOURCE
GRpalmgr.S
