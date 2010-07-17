
/* $Id: vcapi.m,v 1.1 2001/01/26 17:51:52 anand Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:        api/vcapi.m
 *
 * Description:
 *        Automatic dynamic loadable analysis compile
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: vcapi.m,v $
 *        Revision 1.1  2001/01/26 17:51:52  anand
 *        *** empty log message ***
 *
 *        Revision 1.1.1.1  2001/01/04 21:12:00  cvs
 *        Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1997/11/01  21:43:26  pinnacle
# Replaced: api/vcapi.m for:  by r250_int for route
#
# Revision 1.1  1997/10/31  08:18:28  pinnacle
# Created by aharihar for route (from cabling)
#
# Revision 1.1  1997/03/20  21:22:02  pinnacle
# Created: api/vcapi.m by hverstee for cabling
#
 *
 * History:
 *        05/29/96        hv        Initial
 *
 *************************************************************************/

LIB
$ROUTE/config/dload/corrections/vcapi.o

SOURCE
VCAN_dyn.I

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

