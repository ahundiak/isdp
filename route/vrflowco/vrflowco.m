/* $Id: vrflowco.m,v 1.1.1.1 2001/01/04 21:12:52 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrflowco / vrflowco.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vrflowco.m,v $
 *	Revision 1.1.1.1  2001/01/04 21:12:52  cvs
 *	Initial import to CVS
 *	
# Revision 1.2  1999/04/19  19:29:12  pinnacle
# Replaced: vrflowco/vrflowco.m for: TR 179900287 by aharihar for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1998/03/08  23:40:52  pinnacle
# Replaced: vrflowco/vrflowco.m for:  by kddinov for route
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.3  1996/03/04  21:53:18  pinnacle
# Replaced: vrflowco/vrflowco.m for:  by hverstee for route240
#
# Revision 1.2  1996/01/16  23:58:10  pinnacle
# Replaced: vrflowco/vrflowco.m for:  by r240_int for route240
#
 *
 * History:
 *	01/16/96	tlb	Add prototypes
 *	Apr 20, 99	Anand	Removed VRflowsum* entries. The Sum Air Flow
 *				Command now is implemented thru a PPL.
 *
 *************************************************************************/
LIB
$ROUTE/lib/vrflowco.o

SOURCE

VRflowdir.S
VRflowdiri.I
VRFlowFun.I

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

