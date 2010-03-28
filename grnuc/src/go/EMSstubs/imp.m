SRC
$(GRNUC)/src/go/EMSstubs

#ifndef IDRAW

#ifndef NT
ARCHIVE
$(GRLIB)/lib/stub.a
#else
ARCHIVE
$(GRLIB)/lib/stub.lib
#endif

#else

ARCHIVE
$GRMDS/lib/stub.a
#endif

SOURCE

EMSbcstubs.I
EMScvstubs.I
COcvtype8788.I
RASTERstubs.c
EMgetacdtm.c
FIconfbox.c
FIfsetorig.c
ASemsdrawing.I

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

OPP
$(EXTARG)/bin/opp

OMCPP
$(EXTARG)/bin/omcpp
