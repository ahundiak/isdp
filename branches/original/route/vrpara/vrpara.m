/* $Id: vrpara.m,v 1.3 2002/05/18 23:27:27 anand Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrpara / vrpara.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vrpara.m,v $
 *	Revision 1.3  2002/05/18 23:27:27  anand
 *	Removed all the #if ISDP_MAKE_SP stuff (relating to source
 *	files only) - kind of preparing for the Service Pack cycle!
 *	
 *	Revision 1.2  2001/04/03 20:32:09  anand
 *	TR JTS 4485
 *	
 *	Revision 1.1.1.1  2001/01/04 21:13:00  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.4  1998/01/14  18:55:04  pinnacle
# Replaced: vrpara/vrpara.m for:  by lawaddel for route
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.3  1996/03/01  23:22:18  pinnacle
# Replaced: vrpara/vrpara.m for:  by hverstee for route240
#
# Revision 1.2  1996/01/17  14:47:52  pinnacle
# Replaced: vrpara/vrpara.m for:  by r240_int for route240
#
 *
 * History:
 *	01/17/96	tlb	Add BS, ROUTE prototype includes
 *
 *************************************************************************/

LIB
#if ISDP_MAKE_SP
$SPXR/lib/vrpara.o
#else
$ROUTE/lib/vrpara.o
#endif

SOURCE

VRclsymb.S
VRclsymbi.I

VRActParam.S
VRActParami.I

VRPppara.S
VRPpparai.I

VRHvpara.S
VRHvparai.I
VRRwpara.S
VRRwparai.I

VRRevAttr.S
VRRevAttri.I
VRRevForm.I
VRRevSetup.I
VRHsizcomp.c
VRHvupdwd.c

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
$EXNUC/include
$GRNUC/include
$BS/include
$VDS/include
$VDS/vdinclude
$ROUTE/include
$ROUTE/vrinclude
$GRNUC/src/assoc/include_priv
$BS/include/prototypes
$ROUTE/vrinclude/prototypes

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
