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
acc

COPT
-knr -O3

SRC
$(GRNUC)/src/go/csgo

#ifdef IDRAW

LIB
$GRMDS/lib/csgosp.o

#else
#ifndef NT
LIB
$(GRLIB)/lib/csgosp.o
#else
ARCHIVE
$(GRLIB)/lib/csgosp.lib
#endif


#endif

SOURCE
GRcoords.S
GRcsbase.S
GRcsmgr.S
GRgencs.S
