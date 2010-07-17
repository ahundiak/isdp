/* $Id: vrcable.m,v 1.2 2001/02/19 23:57:55 anand Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrcable / vrcable.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vrcable.m,v $
 *	Revision 1.2  2001/02/19 23:57:55  anand
 *	Added $ROUTE/include under INCLUDE atom.
 *	
 *	Revision 1.1.1.1  2001/01/04 21:12:40  cvs
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
# Revision 1.4  1996/04/03  23:56:28  pinnacle
# Replaced: vrcable/vrcable.m for:  by msmanem for route240
#
# Revision 1.3  1996/01/16  20:05:26  pinnacle
# Replaced: vrcable/vrcable.m for:  by r240_int for route240
#
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *
 *************************************************************************/
CC
acc -ansi -Atarg=c300

LIB
$ROUTE/lib/vrcable.o

SOURCE
VRcable.S
VRcablei.I
VRcable_gr.I
VRcabgetprop.I
VRcabdelbrad.I
VRcabinsbrad.I
VRcabchabrad.I

SPEC
$VDS/spec
$ROUTE/spec
$EXNUC/spec
$GRNUC/spec
$MODEL/spec

INCLUDE
$ROUTE/include
$ROUTE/vrinclude
$ROUTE/vrinclude/prototypes
$VDS/include
$BS/include
$EXNUC/include
$GRNUC/include
$MODEL/include
$BS/include/prototypes

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
