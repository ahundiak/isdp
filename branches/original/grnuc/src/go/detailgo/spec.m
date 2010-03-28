INCLUDE
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
$(GRNUC)/src/go/detailgo

#ifndef IDRAW

#ifndef NT
LIB
$(GRLIB)/lib/detailgosp.o
#else
ARCHIVE
$(GRLIB)/lib/detailgosp.lib
#endif


#else

LIB
$GRMDS/lib/detailgosp.o

#endif

SOURCE
GRactownmgr.S
GRdrawsheet.S
GRdrawview.S
GRdsborder.S
GRdvalign.S
GRdvattach.S
GRdvcs.S
GRdvgrgrp.S
GRdvtext.S
