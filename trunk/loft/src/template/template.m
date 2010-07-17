SOURCE
VLtpl2dCmd.S
VLtpl2dCmdi.I
VLtpl3dCmd.S
VLtpl3dCmdi.I
VLprjTplCmd.S
VLprjTplCmdi.I
VLmodTplCmd.S
VLmodTplCmdi.I
VLchtTplCmd.S
VLchtTplCmdi.I
VLheiTplCmd.S
VLheiTplCmdi.I
VLtplMgr.S
VLtplMgri.I
VLtplObj.S
VLtplObji.I
VLtplSpi.S
VLmacroFunk.I
VLtemplFunk.I
/*	VLsnachFunk.I	:	ACH development abort	*/
VLspineFunk.I
VLtplBox.S
VLtplBoxi.I

INCLUDE
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
$LOFT/lib/VLtemplate.o

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp

CC
acc

COPT
$COMPOPT
