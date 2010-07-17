SOURCE
VDPostCmd.c

LIB
$AIM_PATH/src/lib/PostCmd.o

SPEC
$EXNUC/spec
$GRNUC/spec
$MODEL/spec
$VDS/spec

INCLUDE
#if ISDP_MAKE_SP
$SPXV/include
$SPXV/vdinclude
#endif
$BS/include
$BS/include/prototypes
$EXNUC/include
$GRNUC/include
$MODEL/include
$PDU/include
$NFMDP/include
$AIM/include
$VDS/include
$VDS/include/prototypes
$VDS/vdinclude
$VDS/vdpinclude

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
