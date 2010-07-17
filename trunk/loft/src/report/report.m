SOURCE
#if ISDP_MAKE_SP
VLrpToolFunk.I
VLreportXml.I
#else
VLsdlContext.I
VLrpExecFunk.I
VLrpDataFunk.I
VLrpUserFunk.I
VLrpToolFunk.I
VLreportXml.I
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
$STRUCT/include/prototypes
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
$(SPXL)/lib/VLreport.o
#else
$LOFT/lib/VLreport.o
#endif

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp

CC
acc
