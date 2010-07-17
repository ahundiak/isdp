/* $Id: vrsegment.m,v 1.3 2002/05/18 23:27:27 anand Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrsegment / vrsegment.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vrsegment.m,v $
 *	Revision 1.3  2002/05/18 23:27:27  anand
 *	Removed all the #if ISDP_MAKE_SP stuff (relating to source
 *	files only) - kind of preparing for the Service Pack cycle!
 *	
 *	Revision 1.2  2001/09/24 18:52:40  anand
 *	JTS TR 5468.
 *	
 *	Revision 1.1.1.1  2001/01/04 21:13:09  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.4  1997/06/26  13:58:46  pinnacle
# Replaced: vrsegment/vrsegment.m for:  by lawaddel for route
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.5  1996/01/17  23:26:32  pinnacle
# Replaced: vrsegment/vrsegment.m for:  by r240_int for route240
#
 *
 * History:
 *	01/17/96   tlb	Add BS, ROUTE prototypes
 *
 *************************************************************************/

LIB

$ROUTE_PATH/lib/vrsegment.o


SOURCE


VRCnrlSeg.S
VRCnrlSegi.I
VRassocover.I
VRgraph_over.I
VRcsfunk.I
VRCSVerify.I


SPEC
$EXNUC/spec
$GRNUC/spec
$ROUTE/spec
$EMS/spec
$VDS/spec

INCLUDE
#if ISDP_MAKE_SP
$SPXR/vrinclude
$SPXR/include
$SPXR/vrinclude/prototypes
$SPXV/include
#endif
$ROUTE/vrinclude
$ROUTE/include
$VDS/include
$EXNUC/include
$BS/include
$GRNUC/include
$GRNUC/src/assoc/include_priv
$EMS/include
$BS/include/prototypes
$ROUTE/vrinclude/prototypes

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp

