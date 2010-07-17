
/* $Id: vrutil.m,v 1.1.1.1 2001/01/04 21:13:15 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:        vrutil/vrutil.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: vrutil.m,v $
 *        Revision 1.1.1.1  2001/01/04 21:13:15  cvs
 *        Initial import to CVS
 *
# Revision 1.1  2000/03/15  19:03:48  pinnacle
# added for CR179900493
#
 *
 * History:
 *        03/14/2000		Alwin        	Creation
 *
 *************************************************************************/

LIB
$ROUTE/lib/vrutil.o

SOURCE

VRDelPlane.S
VRDelPlanei.I

SPEC
$ROUTE/spec
$VDS/spec
$GRNUC/spec
$EXNUC/spec
$MODEL/spec

INCLUDE
$ROUTE/vcinclude
$ROUTE/vrinclude
$ROUTE/vrinclude/prototypes
$ROUTE/include
$VDS/vdinclude
$VDS/include
$VDS/include/prototypes
$MODEL/include
$GRNUC/include
$GRNUC/src/assoc/include_priv
$BS/include
$BS/include/prototypes
$EXNUC/include
$UMS/include
$FORMS/include

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
