/* $Id: vdiunwrap.m,v 1.1.1.1 2001/01/04 21:09:31 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdunwrap/vdiunwrap.m
 *
 * Description: 
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vdiunwrap.m,v $
 *      Revision 1.1.1.1  2001/01/04 21:09:31  cvs
 *      Initial import to CVS
 *
# Revision 1.2  1999/12/08  16:34:40  pinnacle
# Moved bs to emsfixes
#
# Revision 1.1  1999/10/26  19:31:06  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 07/19/99  ah      creation
 * 12/08/99  ah      moved bs functions to emsfixes
 ***************************************************************************/

SOURCE
VDunwTools.I
VDunwTess.I
VDunwFem.I
VDunwSrf.I

INCLUDE
$BS/include
$BS/include/prototypes
$UMS/include
$FORMS/include
$EXNUC/include
$GRNUC/include
$GRNUC/ingrsys
$GRNUC/src/assoc/include_priv
$MODEL/include
$VDS/include
$VDS/include/prototypes
$VDS/vdinclude

SPEC
$EXNUC/spec
$GRNUC/spec
$MODEL/spec
$VDS/spec

LIB
$VDS/lib/vdiunwrap.o

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp

