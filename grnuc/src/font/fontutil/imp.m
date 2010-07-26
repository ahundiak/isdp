INCLUDE
$(INGRHOME)/include
$(INGRHOME)/include
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
acc -knr

COPT
-ga

SRC
$(GRNUC)/src/font/fontutil

#ifndef IDRAW

#ifndef NT
LIB
$(GRLIB)/lib/fontutil.o
#else
ARCHIVE
$(GRLIB)/lib/fontutil.lib
#endif

#else

ARCHIVE
$GRMDS/lib/fontutil.a

#endif

SOURCE
GRgetfntchar.C
GRfntutil.C
