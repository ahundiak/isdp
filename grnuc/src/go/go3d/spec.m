CC
acc -knr

SOURCE

GR3dcirarc.S
GR3dcircle.S
GR3dellarc.S
GR3dellipse.S
GR3dinfline.S
GR3dlineseg.S
GR3dlinestr.S
GR3dorthlnst.S
GR3dorthpoly.S
GR3dpllnstr.S
GR3dpoint.S
GR3dpolygon.S

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
$(GRNUC)/src/go/go3d

#ifndef IDRAW

#ifndef NT
LIB
$(GRLIB)/lib/go3d_S.o
#else
ARCHIVE
$(GRLIB)/lib/go3d_S.lib
#endif


#else

LIB
$GRMDS/lib/go3d_S.o

#endif

OPP
$(EXTARG)/bin/opp
