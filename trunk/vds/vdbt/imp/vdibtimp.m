/* $Id: vdibtimp.m,v 1.1.1.1 2001/01/04 21:07:57 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdbt/imp/vdibtimp.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vdibtimp.m,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:57  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1998/04/02  21:22:22  pinnacle
# ah
#
# Revision 1.1  1998/03/29  14:14:12  pinnacle
# AssyTree
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/22/99  ah      creation
 *
 ***************************************************************************/

SOURCE
VDbtTest.I
VDbtBase.S
VDbtBasei.I
VDbtBase1.I
VDbtBase2.I

LIB
$VDS/lib/vdibtimp.o

SPEC
$EXNUC/spec
$GRNUC/spec
$VDS/spec

INCLUDE
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
