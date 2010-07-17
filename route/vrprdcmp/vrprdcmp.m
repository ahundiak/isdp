/* $Id: vrprdcmp.m,v 1.1.1.1 2001/01/04 21:13:05 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrprdcmp / vrprdcmp.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vrprdcmp.m,v $
 *	Revision 1.1.1.1  2001/01/04 21:13:05  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.5  1996/03/27  20:02:46  pinnacle
# Replaced: vrprdcmp/vrprdcmp.m for:  by hverstee for route240
#
# Revision 1.4  1996/01/17  19:31:16  pinnacle
# Replaced: vrprdcmp/vrprdcmp.m for:  by r240_int for route240
#
 *
 * History:
 *	01/17/96    tlb		Add BS, ROUTE prototypes
 *
 *************************************************************************/
LIB
$ROUTE/lib/vrprdcmp.o

SOURCE

VRPComp.S
VRPCinfo.I
VRPCgive.I
VRPCComp.S
VRPCCinfo.I
VRPCCgive.I
VRPNozz.S
VRPNinfo.I

VRHComp.S
VRHCinfo.I
VRHCgive.I
VRHCComp.S
VRHCCinfo.I
VRHCCgive.I
VRHNozz.S
VRHNinfo.I
VRPreDrop.I
VRSection.I
VRWriteRes.I

VRRComp.S
VRRCinfo.I
VRRCgive.I
VRRCComp.S
VRRCCinfo.I
VRRCCgive.I
VRRNozz.S
VRRNinfo.I

SPEC
$EXNUC/spec
$GRNUC/spec
$ROUTE/spec
$VDS/spec

INCLUDE
$ROUTE/include
$ROUTE/vrinclude
$EXNUC/include
$GRNUC/include
$VDS/include
$BS/include
$BS/include/prototypes
$ROUTE/vrinclude/prototypes

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp

