/* $Id: vdicvg.m,v 1.2 2001/01/11 19:18:53 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdcvg/vdicvg.m
 *
 * Description: CAD Vector Graphic Routines
 *
 * Dependencies:
 *
 * Revision History:
 * $Log: vdicvg.m,v $
 * Revision 1.2  2001/01/11 19:18:53  art
 * sp merge
 *
# Revision 1.1  2000/04/14  17:06:04  pinnacle
# ah
#
# Revision 1.1  2000/02/22  20:15:30  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 01/26/00  ah      Creation
 * 01/11/01  ah      sp merge
 ***************************************************************************/

SOURCE
VDcvgOut.I
VDcvgGeom.I
VDcvgPath.I

LIB
#if ISDP_MAKE_SP
$SPXV/lib/vdicvg.o
#else
$VDS/lib/vdicvg.o
#endif

INCLUDE
#if ISDP_MAKE_SP
$SPXV/include
#endif
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

SPEC
$EXNUC/spec
$GRNUC/spec
$MODEL/spec
$VDS/spec

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp




