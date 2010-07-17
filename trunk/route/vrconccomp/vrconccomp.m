/* $Id: vrconccomp.m,v 1.3 2002/05/18 23:27:26 anand Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrconccomp / vrconccomp.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vrconccomp.m,v $
 *	Revision 1.3  2002/05/18 23:27:26  anand
 *	Removed all the #if ISDP_MAKE_SP stuff (relating to source
 *	files only) - kind of preparing for the Service Pack cycle!
 *	
 *	Revision 1.2  2001/08/28 18:51:44  louis
 *	Fix the bad planes in construction of offset elbows for tr4724
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
# Revision 1.5  1996/01/16  21:52:36  pinnacle
# Replaced: vrconccomp/vrconccomp.m for:  by r240_int for route240
#
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *	01/16/96   tlb		Add BS, ROUTE prototypes
 *
 *************************************************************************/
COPT
-Atarg=c300

LIB
#if ISDP_MAKE_SP
$SPXR/lib/vrconccomp.o
#else
$ROUTE/lib/vrconccomp.o
#endif

SOURCE
VRConcComp.S
VRCCompInfo.I
VRCCompMod.I
VRCCompOver.I
VRCConcLoc.I
VRCCompCons.I
VRCCVerify.I
VRCCompfunk.I

SPEC
$VDS/spec
$EXNUC/spec
$GRNUC/spec
$ROUTE/spec
$MODEL/spec

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
$MODEL/include
$BS/include/prototypes
$ROUTE/vrinclude/prototypes

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp

