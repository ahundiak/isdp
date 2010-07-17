/* $Id: vrcomponent.m,v 1.3 2002/05/18 23:27:26 anand Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrcomponent / vrcomponent.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vrcomponent.m,v $
 *	Revision 1.3  2002/05/18 23:27:26  anand
 *	Removed all the #if ISDP_MAKE_SP stuff (relating to source
 *	files only) - kind of preparing for the Service Pack cycle!
 *	
 *	Revision 1.2  2001/09/02 19:38:42  ramarao
 *	Fixed TR# 5570.
 *	
 *	Revision 1.1.1.1  2001/01/04 21:12:45  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.2  1996/11/05  15:21:06  pinnacle
# Replaced: vrcomponent/vrcomponent.m for:  by r241_int for route
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.4  1996/01/16  21:47:28  pinnacle
# Replaced: vrcomponent/vrcomponent.m for:  by r240_int for route240
#
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *	11/05/96   adz/shankar	add VRCenterLine.I
 *
 *************************************************************************/
CC
acc -ansi -Atarg=c300

LIB
#if ISDP_MAKE_SP
$SPXR/lib/vrcomponent.o
#else
$ROUTE/lib/vrcomponent.o
#endif

SOURCE
VRComponent.S
VRCompOver.I
VRCompDel.I
VRCompLoc.I
VRCompInfo.I
VRCompMod.I
VRCompVerify.I
VRfunk.I
VRCenterLine.I

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
$ROUTE/vrinclude
$ROUTE/include
$EXNUC/include
$GRNUC/include
$GRNUC/src/assoc/include_priv
$VDS/include
$BS/include
$MODEL/include
$BS/include/prototypes
$ROUTE/vrinclude/prototypes

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp

