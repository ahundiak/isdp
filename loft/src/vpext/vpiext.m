/* $Id: vpiext.m,v 1.1.1.1 2001/01/04 21:11:58 cvs Exp $  */

/***************************************************************************
 * I/EFP
 *
 * File:        vpext/vpiext.m
 *
 * Description: 
 *
 * Dependencies:
 *
 * Revision History:
 * $Log: vpiext.m,v $
 * Revision 1.1.1.1  2001/01/04 21:11:58  cvs
 * Initial import to CVS
 *
# Revision 1.1  1999/05/24  18:39:42  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 05/24/99  ah      Creation
 *
 ***************************************************************************/

SOURCE
VPextMain.I
VPextMisc.I
VPextTree.I
VPextBeam.I

VPextProd.I
VPextEdge.I
VPextHole.I
VPextMark.I
VPextPlate.I
VPextBevel.I
VPextLabel.I
VPextDatum.I
VPextMaster.I

LIB
$LOFT/lib/vpiext.o

SPEC
$EXNUC/spec
$GRNUC/spec
$MODEL/spec
$VDS/spec
$STRUCT/spec
$LOFT/spec

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
$STRUCT/include
$LOFT/include
$LOFT/include/prototypes
$LOFT/include/private

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp




