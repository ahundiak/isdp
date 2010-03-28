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
$(GRNUC)/src/go/symbgo

#ifdef IDRAW

LIB
$GRMDS/lib/symbgosp.o

#else

#ifndef NT
LIB
$(GRLIB)/lib/symbgosp.o
#else
ARCHIVE
$(GRLIB)/lib/symbgosp.lib
#endif


#endif

SOURCE
GRclhdr.S
GRlslmgr.S
GRsmdfhdr.S
GRsmhdr.S
GRsymbol.S
