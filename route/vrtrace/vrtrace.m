/* $Id: vrtrace.m,v 1.3 2002/05/18 23:27:27 anand Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrtrace / vrtrace.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vrtrace.m,v $
 *	Revision 1.3  2002/05/18 23:27:27  anand
 *	Removed all the #if ISDP_MAKE_SP stuff (relating to source
 *	files only) - kind of preparing for the Service Pack cycle!
 *	
 *	Revision 1.2  2001/05/09 23:44:55  louis
 *	TR5100-avoid mode was not performing correctly on 3D hvac PID files.
 *	
 *	Revision 1.1.1.1  2001/01/04 21:13:13  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.2  1997/02/13  19:40:54  pinnacle
# Replaced: vrtrace/vrtrace.m for:  by lawaddel for route
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.2  1996/01/17  23:33:34  pinnacle
# Replaced: vrtrace/vrtrace.m for:  by r240_int for route240
#
 *
 * History:
 *	01/17/96  tlb	Add BS, ROUTE prototype includes
 *      05/09/01  law   Added SP protocol
 *************************************************************************/
CC
acc -ansi -Atarg=c300

LIB
#if ISDP_MAKE_SP
$SPXR/lib/vrtrace.o
#else
$ROUTE/lib/vrtrace.o
#endif

SOURCE
VRnettrace.I
GMndg.C
VRtrace.I

SPEC
$VDS/spec
$EXNUC/spec
$GRNUC/spec
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
$BS/include
$BS/include/prototypes
$ROUTE/vrinclude/prototypes

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
