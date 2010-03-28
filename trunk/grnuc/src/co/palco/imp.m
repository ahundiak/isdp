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
acc -knr

COPT
-ga

SRC
$(GRNUC)/src/co/palco

#ifndef NT
LIB
$(GRLIB)/lib/palco.o
#else
ARCHIVE
$(GRLIB)/lib/palco.lib
#endif

SOURCE
COpali.I
COpallib.I
COpalfrm.I
