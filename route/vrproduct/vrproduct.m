/* $Id: vrproduct.m,v 1.1.1.1 2001/01/04 21:13:06 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vROUTE / vrproduct.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vrproduct.m,v $
 *	Revision 1.1.1.1  2001/01/04 21:13:06  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1997/08/15  20:13:58  pinnacle
# Replaced: vrproduct for:  by hverstee for route
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.2  1996/01/17  19:37:16  pinnacle
# Replaced: vrproduct/vrproduct.m for:  by r240_int for route240
#
 *
 * History:
 *	01/17/96  tlb	Add BS, ROUTE prototypes
 *
 *************************************************************************/
LIB
$ROUTE/lib/vrproduct.o

SOURCE


VRProduct.S
VRTables.I

VRPiping.S
VRPinfo.I

VRHvac.S
VRHinfo.I

VRRway.S
VRRinfo.I

SPEC
$EXNUC/spec
$GRNUC/spec
$ROUTE/spec
$VDS/spec

INCLUDE
$ROUTE/include
$ROUTE/vrinclude
$VDS/include
$GRNUC/include
$EXNUC/include
$BS/include
$BS/include/prototypes
$ROUTE/vrinclude/prototypes

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp

