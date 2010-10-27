/* $Id: vdibtcmd.m,v 1.1.1.1 2001/01/04 21:07:57 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdbt/cmd/vdibtcmd.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vdibtcmd.m,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:57  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1998/04/05  13:34:26  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 04/04/98  ah      Creation
 *
 ***************************************************************************/

SOURCE
VDbtMgr.I

LIB
$VDS/lib/vdibtcmd.o

SPEC
.
$EXNUC/spec
$GRNUC/spec
$VDS/spec

INCLUDE
.
$BS/include
$BS/include/prototypes
$EXNUC/include
$GRNUC/include
$GRNUC/src/assoc/include_priv
$FORMS/include
$PDU/include
$NFMDP/include
$MODEL/include
$UMS/include
$VDS/include
$VDS/include/prototypes
$VDS/vdinclude

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
