INCLUDE
$(INGRHOME)/include
$(EXNUC)/include
$(GRNUC)/include
$(BS)/include
$(BS)/include/prototypes
$(GRNUC)/proto_pub
$(GRNUC)/proto_priv

OPP
$(EXTARG)/bin/opp

OMCPP
$(EXTARG)/bin/omcpp

COPT
-ga

CC
acc -knr

SPEC
$(EXNUC)/spec
$(GRNUC)/spec

/*
DEPENDENCIES
om      4.0.5
opp     4.0.41
ige.o   0.8.6
*/

SRC
$(GRNUC)/src/go/textgo

#ifndef IDRAW

#ifndef NT
LIB
$(GRLIB)/lib/textgosp.o
#else
ARCHIVE
$(GRLIB)/lib/textgosp.lib
#endif


#else

LIB
$GRMDS/lib/textgosp.o

#endif

SOURCE
GR3dtext.S
GRtext.S
