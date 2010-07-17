/* $Id: vrconsco.m,v 1.3 2002/05/18 23:27:26 anand Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrconsco / vrconsco.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vrconsco.m,v $
 *	Revision 1.3  2002/05/18 23:27:26  anand
 *	Removed all the #if ISDP_MAKE_SP stuff (relating to source
 *	files only) - kind of preparing for the Service Pack cycle!
 *	
 *	Revision 1.2  2001/05/23 00:34:50  anand
 *	*** empty log message ***
 *	
 *	Revision 1.1.1.1  2001/01/04 21:12:47  cvs
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
# Revision 1.3  1996/03/04  20:54:46  pinnacle
# Replaced: vrconsco/vrconsco.m for:  by hverstee for route240
#
# Revision 1.2  1996/01/16  21:54:46  pinnacle
# Replaced: vrconsco/vrconsco.m for:  by r240_int for route240
#
 *
 * History:
 *	01/15/96	tlb	Add BS, ROUTE prototypes
 *
 *************************************************************************/
CC
acc -ansi -Atarg=c300

LIB
$ROUTE_PATH/lib/vrconsco.o

SOURCE


VRDisplayThem.I

VRDisplFit.S
VRDisplFiti.I
VRSetDelFit.S
VRSetDelFiti.I

VRDisFixPl.S
VRDisFixPli.I
VRFixFreePl.S
VRFixFreePli.I
VRFreeFixPl.S
VRFreeFixPli.I

VRsplitnet.S
VRsplitneti.I

SPEC
$VDS/spec
$ROUTE/spec
$EXNUC/spec
$GRNUC/spec
$EMS/spec
$MODEL/spec


INCLUDE
#if ISDP_MAKE_SP
$SPXR/vrinclude/prototypes
$SPXR/vrinclude
$SPXR/include
$SPXV/include
$SPXV/vdinclude
#endif
$ROUTE/vrinclude
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

