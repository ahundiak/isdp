/* $Id: vrnetworkco.m,v 1.1.1.1 2001/01/04 21:12:58 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrnetworkco / vrnetworkco.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vrnetworkco.m,v $
 *	Revision 1.1.1.1  2001/01/04 21:12:58  cvs
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
# Revision 1.5  1996/03/04  20:48:28  pinnacle
# Replaced: vrnetworkco/vrnetworkco.m for:  by hverstee for route240
#
# Revision 1.4  1996/01/17  00:10:16  pinnacle
# Replaced: vrnetworkco/vrnetworkco.m for:  by r240_int for route240
#
 *
 * History:
 *	01/15/96	tlb	Add BS, ROUTE prototypes
 *
 *************************************************************************/
LIB
$ROUTE/lib/vrnetworkco.o

SOURCE
VRGenRepCmd.S
VRhvfrrpCmd.S
VRrwfrrpCmd.S
VRppfrrpCmd.S
VRVerify.S
VRVerNet.S
VRVerGlob.S
VRGenRepCmdi.I
VRhvfrrpCmdi.I
VRrwfrrpCmdi.I
VRppfrrpCmdi.I
VRVerifyi.I
VRVerNeti.I
VRVerGlobi.I
VRstringUtil.C

SPEC
$EXNUC/spec
$GRNUC/spec
$MODEL/spec
$EMS/spec
$ROUTE/spec
$VDS/spec

INCLUDE
$EXNUC/include
$GRNUC/include
$BS/include
$MODEL/include
$EMS/include
$ROUTE/include
$ROUTE/vrinclude
$VDS/include
$VDS/vdinclude
$GRNUC/src/assoc/include_priv
$BS/include/prototypes
$ROUTE/vrinclude/prototypes

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp

