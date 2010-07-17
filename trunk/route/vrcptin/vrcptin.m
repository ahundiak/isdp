/* $Id: vrcptin.m,v 1.1.1.1 2001/01/04 21:12:50 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrcptin / vrcptin.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vrcptin.m,v $
 *	Revision 1.1.1.1  2001/01/04 21:12:50  cvs
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
# Revision 1.2  1996/01/16  23:13:42  pinnacle
# Replaced: vrcptin/vrcptin.m for:  by r240_int for route240
#
 *
 * History:
 *	01/16/96	tlb	Add BS, ROUTE prototypes
 *
 *************************************************************************/
LIB
$ROUTE/lib/vrcptin.o

SOURCE
VRCptIn.S
VRCptAssoc.I
VRCptGraph.I
VRCptNet.I

SPEC
$VDS/spec
$EXNUC/spec
$GRNUC/spec
$ROUTE/spec

INCLUDE
$ROUTE/vrinclude
$ROUTE/include
$EXNUC/include
$GRNUC/include
$BS/include
$VDS/include
$BS/include/prototypes
$ROUTE/vrinclude/prototypes

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp

