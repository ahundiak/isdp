/* $Id: vrcableco.m,v 1.1.1.1 2001/01/04 21:12:41 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrcableco / vrcableco.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vrcableco.m,v $
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
# Revision 1.3  1996/03/04  22:55:50  pinnacle
# Replaced: vrcableco/vrcableco.m for:  by hverstee for route240
#
# Revision 1.2  1996/01/16  20:16:52  pinnacle
# Replaced: vrcableco/vrcableco.m for:  by r240_int for route240
#
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *
 *************************************************************************/
CC
acc -ansi -Atarg=c300

LIB
$ROUTE/lib/vrcableco.o

SOURCE
VRcableset.S
VRcablecon.S
VRcablerep.S
VRcablerad.S
VRcableseti.I
VRcableconi.I
VRcablerepi.I
VRcableradi.I
VRcable_msg.I
VRcable_dsp.I
VRcable_dyn.I
VRcable_fnc.I


SPEC
$EXNUC/spec
$GRNUC/spec
$MODEL/spec
$ROUTE/spec
$VDS/spec

INCLUDE
$ROUTE/vrinclude
$ROUTE/include
$VDS/include
$VDS/vdinclude
$MODEL/include
$GRNUC/include
$EXNUC/include
$BS/include
$BS/include/prototypes
$ROUTE/vrinclude/prototypes

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
