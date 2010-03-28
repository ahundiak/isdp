CC
acc -knr

SOURCE

GRvg.S
GRconnector.S
GRnotify.S
GRlistener.S
EMSmigrator.S

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
$(GRNUC)/src/go/vg

#ifndef IDRAW

#ifndef NT
LIB
$(GRLIB)/lib/vg_S.o
#else
ARCHIVE
$(GRLIB)/lib/vg_S.lib
#endif


#else

LIB
$GRMDS/lib/vg_S.o

#endif	

OPP
$(EXTARG)/bin/opp
