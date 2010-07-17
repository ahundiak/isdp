/* $Id: vrchgattr.m,v 1.3 2002/05/18 23:27:26 anand Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrchgattr / vrchgattr.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vrchgattr.m,v $
 *	Revision 1.3  2002/05/18 23:27:26  anand
 *	Removed all the #if ISDP_MAKE_SP stuff (relating to source
 *	files only) - kind of preparing for the Service Pack cycle!
 *	
 *	Revision 1.2  2001/04/03 20:32:09  anand
 *	TR JTS 4485
 *	
 *	Revision 1.1.1.1  2001/01/04 21:12:41  cvs
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
# Revision 1.4  1996/04/09  19:31:34  pinnacle
# Replaced: vrchgattr/vrchgattr.m for:  by hverstee for route240
#
# Revision 1.3  1996/03/04  21:29:54  pinnacle
# Replaced: vrchgattr/vrchgattr.m for:  by hverstee for route240
#
# Revision 1.2  1996/01/16  20:47:26  pinnacle
# Replaced: vrchgattr/vrchgattr.m for:  by r240_int for route240
#
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *
 *************************************************************************/
CC
acc -ansi -Atarg=c300

LIB
#if ISDP_MAKE_SP
$SPXR/lib/vrchgattr.o
#else
$ROUTE/lib/vrchgattr.o
#endif

SOURCE
VRchgattr.S
VRchgattri.I
VRchgComp.I
VRform.I
VRchgfunk.I

SPEC
$VDS/spec
$ROUTE/spec
$EXNUC/spec
$GRNUC/spec
$EMS/spec
$MODEL/spec


INCLUDE
#if ISDP_MAKE_SP
$SPXR/include
$SPXR/vrinclude
$SPXV/include
$SPXV/vdinclude
$SPXR/vrinclude/prototypes
#endif
$ROUTE/include
$ROUTE/vrinclude
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
