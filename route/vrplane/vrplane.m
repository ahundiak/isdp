/* $Id: vrplane.m,v 1.3 2002/05/18 23:27:27 anand Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrplane / vrplane.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vrplane.m,v $
 *	Revision 1.3  2002/05/18 23:27:27  anand
 *	Removed all the #if ISDP_MAKE_SP stuff (relating to source
 *	files only) - kind of preparing for the Service Pack cycle!
 *	
 *	Revision 1.2  2001/12/05 16:01:57  louis
 *	tr5611-geometry of some corrections adjacent to nozzles were collapsing
 *	
 *	Revision 1.1.1.1  2001/01/04 21:13:02  cvs
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
# Revision 1.4  1996/01/17  17:33:28  pinnacle
# Replaced: vrplane/vrplane.m for:  by r240_int for route240
#
 *
 * History:
 *	01/15/96	tlb	Add BS, ROUTE prototypes
 *      12/05/01        law     Added SP protocol
 *
 *************************************************************************/
LIB
#if ISDP_MAKE_SP
$SPXR/lib/vrplane.o
#else
$ROUTE/lib/vrplane.o
#endif

SOURCE
VRplane.S
VRplanei.I
VRplanetmp.I
VRDepPlane.S
VRDepPlanei.I
VRplaneVer.I

SPEC
$VDS/spec
$EXNUC/spec
$GRNUC/spec
$EMS/spec
$ROUTE/spec

INCLUDE
#if ISDP_MAKE_SP
$SPXR/include
$SPXR/vrinclude
$SPXV/include
$SPXV/vdinclude
$SPXR/vrinclude/prototypes
#endif
.
$ROUTE/vrinclude
$ROUTE/include
$VDS/include
$EXNUC/include
$GRNUC/include
$GRNUC/src/assoc/include_priv
$BS/include
$EMS/include
$MODEL/include
$BS/include/prototypes
$ROUTE/vrinclude/prototypes

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
