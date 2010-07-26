INCLUDE
$(INGRHOME)/include
$(XINC)
$(EXNUC)/include
$(GRNUC)/include
$(BS)/include
$(BS)/include/prototypes
$(GRNUC)/proto_pub
$(GRNUC)/proto_priv

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
$(GRNUC)/src/util/misc

#ifndef NT
ARCHIVE
$(GRLIB)/lib/utilmisc.a
#else
ARCHIVE
$(GRLIB)/lib/utilmisc.lib
#endif

SOURCE
GRgetprodata.c
GRlistref.c
GRconfirm.c
GRingrhome.c
