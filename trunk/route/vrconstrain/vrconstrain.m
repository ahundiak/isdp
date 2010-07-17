/* $Id: vrconstrain.m,v 1.2 2001/02/20 00:43:34 anand Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrconstrain / vrconstrain.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vrconstrain.m,v $
 *	Revision 1.2  2001/02/20 00:43:34  anand
 *	Added $ROUTE/include
 *	
 *	Revision 1.1.1.1  2001/01/04 21:12:48  cvs
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
# Revision 1.2  1996/01/16  22:12:40  pinnacle
# Replaced: vrconstrain/vrconstrain.m for:  by r240_int for route240
#
 *
 * History:
 *	01/16/96	tlb	Add BS, ROUTE prototypes
 *
 *************************************************************************/
LIB
$ROUTE/lib/vrconstrain.o

SOURCE

VRconc.S
VRconci.I

VRcompoint.S
VRcompointi.I

VRconsdist.S
VRconsdisti.I

VRcons.S
VRconsi.I
VRcons_node.I
VRcons_solve.I
VRsimplex.C
VRsimp_old.C

SPEC
$VDS/spec
$EXNUC/spec
$GRNUC/spec
$ROUTE/spec

INCLUDE
$ROUTE/include
$ROUTE/vrinclude
$ROUTE/vrinclude/prototypes
$VDS/include
$EXNUC/include
$GRNUC/include
$BS/include
$BS/include/prototypes

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
