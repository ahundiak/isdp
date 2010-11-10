INCLUDE
$(INGRHOME)/include
$(FORMS)/include
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

LIB
$(GRLIB)/lib/utilmisc.o

SOURCE
GRgetprodata.c
GRlistref.c
/* GRconfirm.c defined elsewhere */
GRingrhome.c
