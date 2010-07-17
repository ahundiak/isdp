SOURCE
#if ISDP_MAKE_SP
VLtoolsFunk.I
VLcheckFunk.I
#else
ck_store.C
VLtool1Funk.I
VLdevFunk.I
/*VLdbgFunk.I*/
VLtoolsFunk.I
VLnameFunk.I
VLcontAlgo.I
VLcontFunk.I
VLmiscFunk.I
gf_cirappi.I
VLrlocFunk.I
VLfilterFunk.I
VLcheckFunk.I
VLmiscMacro.I
VLhandlerVS.I
VLgeomFunk.I
VLevalFunk.I
VLoverFunk.I
VLedgeFunk.I
VLLnStrBSC.I
VLpathFunk.I
VLscaleSymb.I
#endif

LIB
#if ISDP_MAKE_SP
$(SPXL)/lib/VLtools.o
#else
$LOFT/lib/VLtools.o
#endif

SPEC
$EXNUC/spec
$GRNUC/spec
$MODEL/spec
$VDS/spec
$STRUCT/spec
$LOFT/spec

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
$BS/include
$BS/include/prototypes
$EXNUC/include
$GRNUC/include
$GRNUC/src/assoc/include_priv
$MODEL/include
$VDS/include
$VDS/include/prototypes
$VDS/vdinclude
$UMS/include
$STRUCT/include
$STRUCT/include/prototypes
$LOFT/include
$LOFT/include/private
$LOFT/include/prototypes

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
