SOURCE
#if ISDP_MAKE_SP
VLglobMethod.I
#else
VLlocateCmd.S
VLlocateCmdi.I
VLglobMethod.I
VLglobalFunk.C
VLpathMethod.I
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
$GRNUC/src/assoc/include_priv
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
$(SPXL)/lib/VLlocate.o
#else
$LOFT/lib/VLlocate.o
#endif

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp

CC
acc
