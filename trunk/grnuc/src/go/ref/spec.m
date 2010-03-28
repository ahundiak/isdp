SOURCE

GRclippoly.S
GRcontext.S     
GRreffile.S
Super_rfmgr.S

SPEC
$(GRNUC)/spec
$(EXNUC)/spec

INCLUDE
$(INGRHOME)/include
$(GRNUC)/include
$(BS)/include
$(EXNUC)/include
$(BS)/include/prototypes
$(GRNUC)/proto_pub
$(GRNUC)/proto_priv

OPP
$(EXTARG)/bin/opp

OMCPP
$(EXTARG)/bin/omcpp

SRC
$(GRNUC)/src/go/ref

#ifndef IDRAW

#ifndef NT
LIB
$(GRLIB)/lib/ref_S.o
#else
ARCHIVE
$(GRLIB)/lib/ref_S.lib
#endif


#else

LIB
$GRMDS/lib/ref_S.o

#endif	
