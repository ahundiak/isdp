/* $Id: vrnozzle.m,v 1.4 2002/05/18 23:27:27 anand Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrnozzle / vrnozzle.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vrnozzle.m,v $
 *	Revision 1.4  2002/05/18 23:27:27  anand
 *	Removed all the #if ISDP_MAKE_SP stuff (relating to source
 *	files only) - kind of preparing for the Service Pack cycle!
 *	
 *	Revision 1.3  2002/02/13 23:29:31  louis
 *	TR5889-Corrected nozzle status being Unknown
 *	
 *	Revision 1.2  2001/11/08 03:44:30  anand
 *	JTS TR MP 5557
 *	
 *	Revision 1.1.1.1  2001/01/04 21:13:00  cvs
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
# Revision 1.2  1996/01/17  00:13:12  pinnacle
# Replaced: vrnozzle/vrnozzle.m for:  by r240_int for route240
#
 *
 * History:
 *	01/16/96	tlb	Added BS, Route prototypes
 *
 *************************************************************************/
LIB
$ROUTE_PATH/lib/vrnozzle.o

SOURCE
VRNozzle.S
VRNozzOver.I
VRNozzInfo.I
VRNozzMod.I
VRNozzDel.I
VRNozHold.S
VRNozHoldi.I

SPEC
$EXNUC/spec
$GRNUC/spec
$ROUTE/spec
$VDS/spec

INCLUDE
#if ISDP_MAKE_SP
$SPXR/vrinclude
$SPXR/vrinclude/prototypes
$SPXR/include
$SPXV/include
$SPXV/vdinclude
#endif
$ROUTE/vrinclude
$ROUTE/include
$VDS/vdinclude
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

