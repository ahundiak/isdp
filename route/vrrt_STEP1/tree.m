/* $Id: tree.m,v 1.1.1.1 2001/01/04 21:13:08 cvs Exp $ */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrrt_STEP1/tree.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: tree.m,v $
 *	Revision 1.1.1.1  2001/01/04 21:13:08  cvs
 *	Initial import to CVS
 *	
# Revision 1.2  1998/12/14  21:01:32  pinnacle
# Replaced: vrrt_STEP1/tree.m for:  by apazhani for route
#
# Revision 1.1  1998/11/06  20:15:02  pinnacle
# Alwin
#
 *
 * History:
 *	 Date		Author	 Description
 *	11/06/98	Alwin	Creation date.
 *	12/14/98	Alwin	Added the file tree_func.C
 *
 *************************************************************************/
LIB
$ROUTE/lib/Steptree.o

SOURCE
tree_func.C
tree.C

SPEC
$VDS/spec
$ROUTE/spec
$EXNUC/spec
$GRNUC/spec
$EMS/spec
$MODEL/spec


INCLUDE
.
$ROUTE/vrrt_STEP
$ROUTE/include
$ROUTE/vrinclude
$ROUTE/vrrt
$EXNUC/include
$GRNUC/include
$GRNUC/src/assoc/include_priv
$EMS/include
$MODEL/include
$BS/include
$VDS/include
$BS/include/prototypes
$ROUTE/vrinclude/prototypes
$VDS/include
$VDS/vdinclude
.


OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp


