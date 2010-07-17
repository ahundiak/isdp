/* $Id: vrgeneric.m,v 1.5 2002/05/18 23:27:26 anand Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrgeneric / vrgeneric.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vrgeneric.m,v $
 *	Revision 1.5  2002/05/18 23:27:26  anand
 *	Removed all the #if ISDP_MAKE_SP stuff (relating to source
 *	files only) - kind of preparing for the Service Pack cycle!
 *	
 *	Revision 1.4  2002/01/17 21:12:49  louis
 *	TR5959-modify assoc. symbology for better performance
 *	
 *	Revision 1.3  2001/09/14 15:20:25  anand
 *	JTS TR MP 4843
 *	
 *	Revision 1.2  2001/04/30 18:53:05  louis
 *	tr4464-vrgeneric
 *	
 *	Revision 1.1.1.1  2001/01/04 21:12:52  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1998/03/08  23:09:02  pinnacle
# Replaced: vrgeneric/vrgeneric.m for:  by kddinov for route
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.6  1996/01/17  00:02:26  pinnacle
# Replaced: vrgeneric/vrgeneric.m for:  by r240_int for route240
#
 *
 * History:
 *	01/16/96	tlb	Add BS, ROUTE protoypes
 *	04/30/01	law	add to service pack environment
 *
 *************************************************************************/
LIB
#if ISDP_MAKE_SP
$SPXR/lib/vrgeneric.o
#else
$ROUTE/lib/vrgeneric.o
#endif

SOURCE
VRGeneric.S
VRplace.I
VRConnInfo.I
VRGraphInfo.I
VRGenOver.I
VRcompute.I
VRmod.I
VRinfo.I
VRError.I
VRGenVdsOver.I
VRGenVerify.I
VRFlowBal.I

SPEC
$EXNUC/spec
$GRNUC/spec
$VDS/spec
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
$EXNUC/include
$GRNUC/include
$GRNUC/src/assoc/include_priv
$BS/include
$ROUTE/vrinclude
$ROUTE/include
$VDS/include
$VDS/include/prototypes
$BS/include/prototypes
$ROUTE/vrinclude/prototypes

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp


