/* $Id: vdibro.m,v 1.1.1.1 2001/01/04 21:07:57 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdbro/imp/vdibro.m
 *
 * Description: Makes some of the browser routines
 * callable by other functions
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vdibro.m,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:57  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/11/25  14:15:20  pinnacle
# ah
#
# Revision 1.1  1997/10/29  17:14:18  pinnacle
# ah Creation
#
 *
 * History:
 *      MM/DD/YY  AUTHOR  DESCRIPTION
 *      10/29/97  ah      added header
 *      11/30/97  ah      VDmaster changes
 ***************************************************************************/

SOURCE
VDbro.I

INCLUDE
$BS/include
$EXNUC/include
$GRNUC/include
$GRNUC/ingrsys
$GRNUC/src/assoc/include_priv
$FORMS/include
$PDU/include
$NFMDP/include
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
$VDS/lib/vdibro.o

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp

