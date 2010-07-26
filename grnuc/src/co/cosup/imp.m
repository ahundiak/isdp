INCLUDE
$(INGRHOME)/include
$(EXNUC)/include
$(GRNUC)/include
$(GRNUC)/ingrsys
$(BS)/include
#ifdef X11
$(XINC)
#endif
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
$(GRNUC)/src/co/cosup

#ifndef NT
LIB
$(GRLIB)/lib/cosup.o
#else
ARCHIVE
$(GRLIB)/lib/cosup.lib
#endif

SOURCE
GRpuldwnlst.c
