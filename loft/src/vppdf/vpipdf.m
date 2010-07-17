/* $Id: vpipdf.m,v 1.1.1.1 2001/01/04 21:12:00 cvs Exp $  */

/***************************************************************************
 * I/LOFT
 *
 * File:        src/vppdf/vpipdf.m
 *
 * Description: 
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vpipdf.m,v $
 *      Revision 1.1.1.1  2001/01/04 21:12:00  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1999/05/24  18:35:20  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 05/24/99  ah      creation
 *
 ***************************************************************************/
SOURCE
VPpdf1.I
VPpdf2.I
VPpdf3.I
VPpdfSrf.I
VPpdfCrv.I
VPpdfVerify.I

INCLUDE
$BS/include
$BS/include/prototypes
$EXNUC/include
$GRNUC/include
$GRNUC/ingrsys
$GRNUC/src/assoc/include_priv
$MODEL/include
$VDS/include
$VDS/vdinclude
$STRUCT/include
$STRUCT/include/prototypes
$LOFT/include
$LOFT/include/private
$LOFT/include/prototypes

SPEC
$EXNUC/spec
$GRNUC/spec
$MODEL/spec
$VDS/spec
$STRUCT/spec
$LOFT/spec

LIB
$LOFT/lib/vpipdf.o

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp

CC
acc

COPT 
$COMPOPT
