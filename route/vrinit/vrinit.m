/* $Id: vrinit.m,v 1.4 2002/05/18 23:27:26 anand Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrinit / vrinit.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vrinit.m,v $
 *	Revision 1.4  2002/05/18 23:27:26  anand
 *	Removed all the #if ISDP_MAKE_SP stuff (relating to source
 *	files only) - kind of preparing for the Service Pack cycle!
 *	
 *	Revision 1.3  2001/09/21 17:26:09  ahundiak
 *	*** empty log message ***
 *	
 *	Revision 1.2  2001/09/18 19:10:38  anand
 *	JTS TR MP5586 - Caching of hvac_material_list table to
 *	include caching of cage, mino and descr fields as well.
 *	
 *	Revision 1.1.1.1  2001/01/04 21:12:57  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.4  1997/11/03  21:42:10  pinnacle
# Replaced: vrinit/vrinit.m for:  by impd for route
#
# Revision 1.3  1997/11/03  17:05:58  pinnacle
# Replaced: vrinit/vrinit.m for:  by impd for route
#
# Revision 1.2  1997/10/31  21:25:04  pinnacle
# Replaced: vrinit/vrinit.m for:  by impd for route
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.2  1996/01/17  00:06:52  pinnacle
# Replaced: vrinit/vrinit.m for:  by r240_int for route240
#
 *
 * History:
 *	01/16/96	tlb	Add BS, ROUTE prototypes
 *
 *************************************************************************/
CC
acc -ansi -Atarg=c300

LIB
$ROUTE_PATH/lib/vrinit.o

SOURCE

VRinit.S
VRiniti.I

VRInitFunk.I
VRPocketInit.C

VCSYS.S
VCSYSi.I

SPEC
$EXNUC/spec
$GRNUC/spec
$VDS/spec
$ROUTE/spec

INCLUDE
#if ISDP_MAKE_SP
$SPXR/include
$SPXR/vrinclude
$SPXR/vrinclude/prototypes
$SPXR/vcinclude
$SPXV/include
#endif
$ROUTE/include
$ROUTE/vrinclude
$ROUTE/vcinclude
$VDS/include
$EXNUC/include
$GRNUC/include
$BS/include
$BS/include/prototypes
$ROUTE/vrinclude/prototypes
$PDU/include


OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
