/* $Id: vrcopy.m,v 1.1.1.1 2001/01/04 21:12:48 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrcopy / vrcopy.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vrcopy.m,v $
 *	Revision 1.1.1.1  2001/01/04 21:12:48  cvs
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
# Revision 1.4  1996/03/27  14:43:28  pinnacle
# Replaced: vrcopy/vrcopy.m for:  by azuurhou for route240
#
# Revision 1.3  1996/03/01  23:46:52  pinnacle
# Replaced: vrcopy/vrcopy.m for:  by hverstee for route240
#
# Revision 1.2  1996/01/16  22:39:18  pinnacle
# Replaced: vrcopy/vrcopy.m for:  by r240_int for route240
#
 *
 * History:
 *	01/16/96	tlb		Add BR, ROUTE prototypes
 *
 *************************************************************************/
LIB
$ROUTE/lib/vrcopy.o

SOURCE
VRcopy.S
VRcopyi.I
VRaddplane.I

SPEC
$VDS/spec
$ROUTE/spec
$EXNUC/spec
$GRNUC/spec
$EMS/spec
$MODEL/spec


INCLUDE
$ROUTE/vrinclude
$ROUTE/include
$EXNUC/include
$GRNUC/include
$GRNUC/src/assoc/include_priv
$EMS/include
$MODEL/include
$BS/include
$VDS/include
$VDS/vdinclude
$OPENWINHOME/share/include
$VDS/spec
$BS/include/prototypes
$ROUTE/vrinclude/prototypes

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
