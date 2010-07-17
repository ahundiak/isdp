SOURCE
#if ISDP_MAKE_SP
VLGetWebPrji.I
VLmrkAConFi.I
#else
VLmrkAConFi.I  
VLmrkFdSbCv.I
VLmrkMisFni.I  
VLmrkPlVrLn.I
VLplMarkCmdi.I
VLmrkLine.S
VLmrkObjInf.I
VLmrkWhSidei.I
VLGetBmIsosi.I 
VLGetStObjCl.I
VLmrkGeomFn.I
VLmrkLinei.I
VLctrLine.S
VLctrLinei.I
VLctrMethod.I
VLplCntrCmd.S
VLplCntrCmdi.I
VLplMarkCmd.S
VLrolLine.S
VLrolLinei.I
VLrolMethod.I
VLplRollCmd.S
VLplRollCmdi.I
VLtrace.S
VLtracei.I
VLGetWebPrji.I

#endif

INCLUDE
#if ISDP_MAKE_SP
$(SPXV)/include
$(SPXV)/include/prototypes
$(SPXS)/include
$(SPXS)/include/prototypes
$(SPXL)/include
$(SPXL)/include/prototypes
#endif
/usr/ip32/forms/include
$BS/include
$BS/include/prototypes
$BS/include/igr_include
$EXNUC/include
$GRNUC/include
$GRNUC/ingrsys
$GRNUC/src/assoc/include_priv
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
$(SPXL)/lib/mrkLine.o
#else
$(LOFT)/lib/mrkLine.o
#endif

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp

CC
acc

COPT
$COMPOPT
