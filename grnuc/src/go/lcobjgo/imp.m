CC 
acc -knr

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

SRC
$(GRNUC)/src/go/lcobjgo

#ifndef IDRAW

#ifndef NT
LIB
$(GRLIB)/lib/lcobjgo.o
#else
ARCHIVE
$(GRLIB)/lib/lcobjgo.lib
#endif


#else

ARCHIVE
$GRMDS/lib/lcobjgo.a

#endif

SOURCE
LCcmd_isofun.I
LCcmd_isomul.I
