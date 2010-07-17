/* $Id: vrcorrection.m,v 1.6 2002/05/18 23:27:26 anand Exp $  */

/*************************************************************************
* I/ROUTE
*
* File:	vrcorrection / vrcorrection.m
*
* Description:
*
* Dependencies:
*
* Revision History:
*	$Log: vrcorrection.m,v $
*	Revision 1.6  2002/05/18 23:27:26  anand
*	Removed all the #if ISDP_MAKE_SP stuff (relating to source
*	files only) - kind of preparing for the Service Pack cycle!
*	
*	Revision 1.5  2001/09/24 15:17:49  anand
*	TR 5468
*	
*	Revision 1.4  2001/09/21 21:15:06  anand
*	JTS TR MP 5468
*	
*	Revision 1.3  2001/05/18 17:34:57  anand
*	Added VRcor_funk.I
*	
*	Revision 1.2  2001/05/07 20:37:26  anand
*	JTS CR 5177
*	
*	Revision 1.1.1.1  2001/01/04 21:12:50  cvs
*	Initial import to CVS
*	
# Revision 1.2  1999/02/18  10:26:22  pinnacle
# Replaced: vrcorrection/vrcorrection.m for:  by sbilla for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.2  1997/02/24  00:20:20  pinnacle
# Replaced: vrcorrection/vrcorrection.m for:  by kddinov for route
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.4  1996/01/16  23:27:08  pinnacle
# Replaced: vrcorrection/vrcorrection.m for:  by r240_int for route240
#
*
* History:
*	01/15/96  tlb         Add BS ROUTE prototypes
*	Feb/97	  kdd	      VRCorrInfo.I, VRCorrCommon.C
*       Feb/99    Reddy       VRCorrCommon.C file renamed as VRCorrCommon.I
*************************************************************************/

LIB
$ROUTE_PATH/lib/vrcorrection.o


SOURCE
VRCorrection.S
VRPCorentity.S
VRHCorentity.S
VRRCorentity.S

VRCorrecti.I
VRPCorentiti.I
VRHCorentiti.I
VRRCorentiti.I

VRassoc_over.I
VRgraph_over.I
VRcor_funk.I
VRCorrVerify.I

VRCorrInfo.I
VRCorrCommon.I

SPEC
$VDS/spec
$EXNUC/spec
$GRNUC/spec
$ROUTE/spec
$EMS/spec

INCLUDE
#if ISDP_MAKE_SP
$SPXR/include
$SPXR/vrinclude
$SPXV/include
$SPXV/vdinclude
$SPXR/vrinclude/prototypes
#endif
$ROUTE/include
$ROUTE/vrinclude
$EXNUC/include
$BS/include
$GRNUC/include
$GRNUC/src/assoc/include_priv
$EMS/include
$VDS/include
$VDS/vdinclude
$BS/include/prototypes
$ROUTE/vrinclude/prototypes

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
