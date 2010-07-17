/* $Id: vrequip.m,v 1.1.1.1 2001/01/04 21:12:51 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrequip / vrequip.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vrequip.m,v $
 *	Revision 1.1.1.1  2001/01/04 21:12:51  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.6  1998/01/03  15:28:28  pinnacle
# Replaced: vrequip/vrequip.m for:  by impd for route
#
# Revision 1.5  1997/12/29  22:19:06  pinnacle
# Replaced: vrequip/vrequip.m for:  by kddinov for route
#
# Revision 1.4  1997/10/25  17:48:32  pinnacle
# Replaced: vrequip/vrequip.m for:  by onayragu for route
#
# Revision 1.3  1997/10/20  15:36:00  pinnacle
# Replaced: vrequip/vrequip.m for:  by kddinov for route
#
# Revision 1.6  1997/09/17  20:46:16  pinnacle
# Replaced: vrequip/vrequip.m for:  by kddinov for route
#
# Revision 1.3  1997/06/04  20:44:16  pinnacle
# Replaced: vrequip/vrequip.m for:  by kddinov for route
#
# Revision 1.2  1997/05/21  14:05:30  pinnacle
# Replaced: vrequip/vrequip.m for:  by kddinov for route
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.2  1996/01/16  23:47:20  pinnacle
# Replaced: vrequip/vrequip.m for:  by r240_int for route240
#
 *
 * History:
 *	01/16/96	tlb		Add BS, ROUTE prototypes
 *	12-97		kdd		VCPidGetTerm.I to get terminal children
 *					Cable now is folded inside Route. 
 *
 *************************************************************************/

LIB
$ROUTE/lib/vrequip.o

SOURCE
VRPidGetNoz.I
VRPlEquipi.I
VRPidEqpRpl.I
VREquipOver.I
VRTestPid25.I
VREquipInfo.I
VREquipFun.C
VRPlEquip.S
VRPutQueue.S
VRPutQueuei.I
VREquipment.S

VCPidGetTerm.I

/**
VRCmdUpdEq.S
VRCmdUpdEqi.I
VRUpdEq.I
**/

SPEC
$VDS/spec
$ROUTE/spec
$EXNUC/spec
$GRNUC/spec
$EMS/spec
$MODEL/spec
$VDS/spec

INCLUDE
$ROUTE/vrinclude
$ROUTE/vcinclude
$ROUTE/include
$EXNUC/include
$GRNUC/include
$EMS/include
$MODEL/include
$BS/include
$VDS/include
$VDS/vdinclude
$BS/include/prototypes
$ROUTE/vrinclude/prototypes

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp


