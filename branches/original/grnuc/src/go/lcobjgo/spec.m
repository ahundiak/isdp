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
$(GRNUC)/src/go/lcobjgo

#ifdef IDRAW

LIB
$GRMDS/lib/lcobjgosp.o

#else

#ifndef NT
LIB
$(GRLIB)/lib/lcobjgosp.o
#else
ARCHIVE
$(GRLIB)/lib/lcobjgosp.lib
#endif


#endif

SOURCE
LCcmd_iso.S
