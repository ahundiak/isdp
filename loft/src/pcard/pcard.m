SOURCE
#if ISDP_MAKE_SP
VLpcCompute.I
VLpcUserFunk.I
VLpcMcInfo.I
#else
VLpcAbst.S
VLpcAbsti.I
VLpcView.S
VLpcViewi.I
VLpcCompute.I
VLpcUserFunk.I
VLpcBendFk.I
VLpcGrUserF.I
VLpcText.S
VLpcTexti.I
VLcsFitElem.S
VLcsFitElemi.I
VLpcPlace.I
VLpcMcInfo.I
VLpcCmd.S
VLpcMethCmd.I
VLprocMgr.I
VLstfMark.I
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
$LOFT/include/prototypes
$LOFT/include/private

SPEC
$EXNUC/spec
$GRNUC/spec
$MODEL/spec
$VDS/spec
$STRUCT/spec
$LOFT/spec

LIB
#if ISDP_MAKE_SP
$(SPXL)/lib/vlpcard.o
#else
$LOFT/lib/vlpcard.o
#endif

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp

CC
acc

COPT 
$COMPOPT
