SOURCE
GRwindow.S

SPEC
$(EXNUC)/spec
$(GRNUC)/spec

INCLUDE
$(INGRHOME)/include
$(EXNUC)/include
$(GRNUC)/include
$(BS)/include/prototypes
$(GRNUC)/proto_pub
$(GRNUC)/proto_priv

SRC
$(GRNUC)/src/display/grwindow

#ifndef IDRAW

#ifndef NT
LIB
$(GRLIB)/lib/grwindowsp.o
#else
ARCHIVE
$(GRLIB)/lib/grwindowsp.lib
#endif

#else

LIB
$GRMDS/lib/grwindowsp.o

#endif

OPP
$(EXTARG)/bin/opp

OMCPP
$(EXTARG)/bin/omcpp

CC
acc -knr

COPT
-ga

