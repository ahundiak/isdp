/* $Id: vrflow.m,v 1.3 2002/05/18 23:27:26 anand Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrflow / vrflow.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vrflow.m,v $
 *	Revision 1.3  2002/05/18 23:27:26  anand
 *	Removed all the #if ISDP_MAKE_SP stuff (relating to source
 *	files only) - kind of preparing for the Service Pack cycle!
 *	
 *	Revision 1.2  2001/05/09 23:47:04  louis
 *	TR5100-meaningful error message with incorrect select of component
 *	
 *	Revision 1.1.1.1  2001/01/04 21:12:51  cvs
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
# Revision 1.3  1996/05/21  15:23:48  pinnacle
# Replaced: vrflow/vrflow.m for:  by ashankar for route240
#
# Revision 1.2  1996/01/16  23:56:10  pinnacle
# Replaced: vrflow/vrflow.m for:  by r240_int for route240
#
 *
 * History:
 *	01/15/96	tlb	Add BS ROUTE prototypes
 *      05/09/01        law     Add SP protocol
 *************************************************************************/
CC
acc -ansi -Atarg=c300

LIB
#if ISDP_MAKE_SP
$SPXR/lib/vrflow.o
#else
$ROUTE/lib/vrflow.o
#endif

SOURCE
VRflow.I
VRinterf.I
VRsize.I
VRsolve.I
VRExpKludge.I
VRExpFunk.I
VRWriteHdTl.C

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
