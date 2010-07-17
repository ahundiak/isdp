SOURCE
#if ISDP_MAKE_SP
VLpinAlgo.I
VLpinFunk.I
#else
VLbalCmd.S
VLbalCmdi.I
VLbalance.S
VLbalancei.I
VLbalLstCmd.S
VLbalLstCmdi.I
VLmapCmd.S
VLmapCmdi.I
VLmodMapCmd.S
VLmodMapCmdi.I
VLlayout.S
VLlayouti.I
VLevalCmd.S
VLevalCmdi.I
VLpinjig.S
VLpinjigi.I
VLpinLstCmd.S
VLpinLstCmdi.I
VLgrdFunk.I
VLpinFunk.I
VLpinAlgo.I
VLsbPlace.I
VLklPlace.I
VLklStrLines.I
#endif

INCLUDE
#if ISDP_MAKE_SP
$(SPXV)/include
$(SPXV)/include/prototypes
$(SPXV)/vdinclude
$(SPXS)/include
$(SPXS)/include/prototypes
$(SPXL)/include
$(SPXL)/include/prototypes
#endif
/usr/ip32/forms/include
$BS/include
$BS/include/prototypes
$EXNUC/include
$GRNUC/include
$GRNUC/ingrsys
$MODEL/include
$VDS/include
$VDS/vdinclude
$STRUCT/include
$LOFT/include
$LOFT/include/private
$LOFT/include/prototypes

SPEC
$EXNUC/spec
$GRNUC/spec
$MODEL/spec
$VDS/spec
$STRUCT/spec
$LOFT/spec

LIB
#if ISDP_MAKE_SP
$(SPXL)/lib/VLpin_jig.o
#else
$LOFT/lib/VLpin_jig.o
#endif

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp

CC
acc
