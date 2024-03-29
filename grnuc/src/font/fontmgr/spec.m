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
$(GRNUC)/src/font/fontmgr

#ifndef IDRAW

#ifndef NT
LIB
$(GRLIB)/lib/fontmgrsp.o
#else
ARCHIVE
$(GRLIB)/lib/fontmgrsp.lib
#endif

#else

LIB
$GRMDS/lib/fontmgrsp.o

#endif

SOURCE
GRfm.S

