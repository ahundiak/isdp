CC
acc -knr

SOURCE

GRgraphics.S

SPEC
$(EXNUC)/spec
$(GRNUC)/spec

INCLUDE
$(INGRHOME)/include
$(GRNUC)/include
$(EXNUC)/include
$(BS)/include
$(BS)/include/prototypes
$(GRNUC)/proto_pub
$(GRNUC)/proto_priv

SRC
$(GRNUC)/src/go/graphics

#ifndef IDRAW

#ifndef NT
LIB
$(GRLIB)/lib/graphics_S.o
#else
ARCHIVE
$(GRLIB)/lib/graphics_S.lib
#endif


#else

LIB
$GRMDS/lib/graphics_S.o

#endif	

OPP
$(EXTARG)/bin/opp
