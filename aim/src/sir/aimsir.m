SOURCE
VDgenOver.I
VDCmdChkIni.I
VDPCmdEnabi.I  
VDPquerydm2.I
VDPCmdPMDefi.I
VDPtrTbli.I
VDPenabUtil.I
VDPCmdShEni.I
VDPutil.I
VDSirCheckin.I

LIB
${AIM_PATH}/src/lib/AimSir.o

SPEC
$EXNUC/spec
$GRNUC/spec
$MODEL/spec
$EMS/spec
$VDS/spec

INCLUDE
#if ISDP_MAKE_SP
$SPXA/include
$SPXV/include
$SPXV/vdinclude
#endif
$BS/include
$UMS/include
$PDU/include
$PDUDP/include
$NFM/include
$NFMDP/include
$FORMS/include
$EXNUC/include
$GRNUC/include
$GRNUC/ingrsys
$GRNUC/src/assoc/include_priv
$MODEL/include
$AIM/include
$VDS/include
$VDS/include/prototypes
$VDS/vdinclude

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp

