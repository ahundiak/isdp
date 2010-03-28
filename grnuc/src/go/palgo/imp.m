INCLUDE
$(INGRHOME)/include
#ifdef X11
$(XINC)
#endif
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
$(GRLIB)/lib/palgo.o
#else
ARCHIVE
$(GRLIB)/lib/palgo.lib
#endif


SOURCE
GRpalmgri.I
GRpallib.I
GRpopup.I
GRasfmscrn.C
