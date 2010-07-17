/* $Id: vrhanger.m,v 1.1.1.1 2001/01/04 21:12:53 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrhanger / vrhanger.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vrhanger.m,v $
 *	Revision 1.1.1.1  2001/01/04 21:12:53  cvs
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
# Revision 1.2  1996/01/17  00:03:30  pinnacle
# Replaced: vrhanger/vrhanger.m for:  by r240_int for route240
#
 *
 * History:
 *	01/16/96	tlb	Add BS, ROUTE prototypes
 *
 *************************************************************************/
LIB
$ROUTE/lib/vrhanger.o

SOURCE
VRHanger.S
VRHanInfo.I
VRHanMod.I
VRHanOver.I

SPEC
$EXNUC/spec
$GRNUC/spec
$ROUTE/spec
$VDS/spec

INCLUDE
$ROUTE/include
$ROUTE/vrinclude
$VDS/include
$BS/include
$EXNUC/include
$GRNUC/include
$BS/include/prototypes
$ROUTE/vrinclude/prototypes

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp

