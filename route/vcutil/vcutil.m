/* $Id: vcutil.m,v 1.1.1.1 2001/01/04 21:12:40 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	include / vcutil.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vcutil.m,v $
 *	Revision 1.1.1.1  2001/01/04 21:12:40  cvs
 *	Initial import to CVS
 *	
# Revision 1.2  1999/01/28  20:13:44  pinnacle
# Replaced: vcutil/vcutil.m for:  by lawaddel for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1998/04/20  15:08:36  pinnacle
# Created: vcutil/vcutil.m by kddinov for route
#
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *      01/27/99   law          CR179802489-add VRpost spec and methods
 *************************************************************************/
LIB
$ROUTE/lib/vcutil.o

SOURCE
VCDefaults.I
VRpostgvstr.I
VRpost.S

SPEC
$ROUTE/spec
$VDS/spec
$MODEL/spec
$GRNUC/spec
$EXNUC/spec

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

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp

